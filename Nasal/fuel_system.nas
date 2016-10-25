# MD-11 fuel system, John Williams, April 2014

var fuelsys = {
    new : func {
	m = {parents : [fuelsys] };

	m.Ltank_controls = props.globals.getNode("controls/fuel/tank[0]",1);
	m.Ctank_controls = props.globals.getNode("controls/fuel/tank[1]",1);
	m.Rtank_controls = props.globals.getNode("controls/fuel/tank[2]",1);
	m.Auxtank_controls = props.globals.getNode("controls/fuel/tank[3]",1);
	m.Tailtank_controls = props.globals.getNode("controls/fuel/tank[4]",1);

	m.Ltank = props.globals.getNode("consumables/fuel/tank[0]",1);
	m.Ctank = props.globals.getNode("consumables/fuel/tank[1]",1);
	m.Rtank = props.globals.getNode("consumables/fuel/tank[2]",1);
	m.Auxtank = props.globals.getNode("consumables/fuel/tank[3]",1);
	m.Tailtank = props.globals.getNode("consumables/fuel/tank[4]",1);

	m.pump = [ m.Ltank_controls.initNode("pump-eng",0,"BOOL"),
		   m.Ctank_controls.initNode("pump-eng",0,"BOOL"),
		   m.Rtank_controls.initNode("pump-eng",0,"BOOL") ];
	m.altpump = m.Tailtank_controls.initNode("alt-pump-eng",0,"BOOL");

	m.xfeed = [ m.Ltank_controls.initNode("x-feed",0,"BOOL"),
		    m.Ctank_controls.initNode("x-feed",0,"BOOL"),
		    m.Rtank_controls.initNode("x-feed",0,"BOOL") ];

	m.xfer = [ m.Ltank_controls.initNode("pump-xfer",0,"BOOL"),
		   m.Ctank_controls.initNode("pump-xfer",0,"BOOL"),
		   m.Rtank_controls.initNode("pump-xfer",0,"BOOL"),
		   m.Auxtank_controls.initNode("pump-xfer",0,"BOOL"),
		   m.Tailtank_controls.initNode("pump-xfer",0,"BOOL") ];

	m.fill_arm = [ m.Ltank_controls.initNode("fill-valve-arm",0,"BOOL"),
		       m.Ctank_controls.initNode("fill-valve-arm",0,"BOOL"),
		       m.Rtank_controls.initNode("fill-valve-arm",0,"BOOL"),
		       m.Auxtank_controls.initNode("fill-valve-arm",0,"BOOL"),
		       m.Tailtank_controls.initNode("fill-valve-arm",0,"BOOL") ];

	m.fill = [ m.Ltank.initNode("fill-valve",0,"BOOL"),
		   m.Ctank.initNode("fill-valve",0,"BOOL"),
		   m.Rtank.initNode("fill-valve",0,"BOOL"),
		   m.Auxtank.initNode("fill-valve",0,"BOOL"),
		   m.Tailtank.initNode("fill-valve",0,"BOOL") ];

	m.fill_status = [ 0, 0, 0, 0, 0 ];

	m.sel = [ m.Ltank.getNode("selected",1),
		  m.Ctank.getNode("selected",1),
		  m.Rtank.getNode("selected",1),
		  m.Auxtank.getNode("selected",1),
		  m.Tailtank.getNode("selected",1) ];

	m.lev = [ m.Ltank.getNode("level-lbs",1),
		  m.Ctank.getNode("level-lbs",1),
		  m.Rtank.getNode("level-lbs",1),
		  m.Auxtank.getNode("level-lbs",1),
		  m.Tailtank.getNode("level-lbs",1) ];

	m.empty = [ m.Ltank.getNode("empty",1),
		    m.Ctank.getNode("empty",1),
		    m.Rtank.getNode("empty",1),
		    m.Auxtank.getNode("empty",1),
		    m.Tailtank.getNode("empty",1) ];

	m.cap = [ m.Ltank.getNode("capacity-gal_us",1),
		  m.Ctank.getNode("capacity-gal_us",1),
		  m.Rtank.getNode("capacity-gal_us",1),
		  m.Auxtank.getNode("capacity-gal_us",1),
		  m.Tailtank.getNode("capacity-gal_us",1) ];
	
	m.density = m.Ctank.getNode("density-ppg",1);
	m.total = props.globals.getNode("consumables/fuel/total-fuel-lbs",1);

	m.auto_manage = props.globals.initNode("controls/fuel/auto-manage",0,"BOOL");
	m.jett_sw_cvr = props.globals.initNode("controls/switches/jettison-cover",0,"BOOL");

	m.tail_mgm_enable = 0;
	m.ticks = 0;
	m.tail_filled = 0;

	return m;
    },

    update : func {
	var select = [ 0, 0, 0, 0, 0 ];
	var thru_flow = [ 0, 0, 0 ];
	var electric = getprop("systems/electrical/AC_TIE_BUS") >= 98;

	me.fill_arm[3].setBoolValue(1);
	me.fill_arm[4].setBoolValue(1);

	# Fill valve status:
	for (var i=0; i<5; i+=1) {
	    if (!me.fill_arm[i].getBoolValue()) {
		me.fill[i].setBoolValue(0);
	    }
	    if (me.fill[i].getBoolValue()) {
		me.fill_status[i] = 1;
	    } else {
		me.fill_status[i] = 0;
	    }
	}

	# Run the FSC
	if (me.auto_manage.getBoolValue() and electric) me.fsc();

	# Fuel Jettison
	if (getprop("controls/fuel/dump-valve") and electric) {
	    for (var i=0; i<5; i+=1) {
		if (i == 3) {
		    me.fill_arm[i].setBoolValue(1);
		    me.fill[i].setBoolValue(1);
		    me.fill_status[i] = 0;
		} else {
		    me.fill[i].setBoolValue(0);
		    me.fill_status[i] = 0;
		}
		if (i < 3 and me.lev[i].getValue() < 11500) {
		    me.xfer[i].setBoolValue(0);
		} else {
		    me.xfer[i].setBoolValue(1);
		}
	    }
	}

	# Cut out pumps on empty tanks:
	for (var i=0; i<5; i+=1) {
	    if (me.empty[i].getBoolValue()) {
		me.xfer[i].setBoolValue(0);
		if (i < 3) me.pump[i].setBoolValue(0);
		if (i == 4) me.altpump.setBoolValue(0);
	    }
	}

	# Cut the pumps when there's no power:
	if (getprop("systems/electrical/AC_TIE_BUS") < 98) {
	    me.auto_manage.setBoolValue(0);
	    for (var i=0; i<5; i+=1) {
		me.xfer[i].setBoolValue(0);
		if (i < 3) me.pump[i].setBoolValue(0);
		if (i == 4) me.altpump.setBoolValue(0);
	    }
	}

	# Fuel manifold status:
	var manifold_p = me.xfer[0].getBoolValue()
		      or me.xfer[1].getBoolValue()
		      or me.xfer[2].getBoolValue()
		      or me.xfer[3].getBoolValue()
		      or me.xfer[4].getBoolValue()
		      or (me.pump[0].getBoolValue() and me.xfeed[0].getValue())
		      or (me.pump[1].getBoolValue() and me.xfeed[1].getValue())
		      or (me.pump[2].getBoolValue() and me.xfeed[2].getValue());

	if (!me.auto_manage.getBoolValue()) {
	    for (var i=0; i<5; i+=1) {
		if (me.fill_arm[i].getBoolValue() and !me.xfer[i].getBoolValue() and manifold_p) {
		    me.fill[i].setBoolValue(1);
		} else {
		    me.fill[i].setBoolValue(0);
		}
		if (i == 3 and getprop("controls/fuel/dump-valve"))
		    me.fill[i].setBoolValue(1);
	    }
	}

	var manifold_o = me.fill[0].getBoolValue()
		      or me.fill[1].getBoolValue()
		      or me.fill[2].getBoolValue()
		      or me.fill[3].getBoolValue()
		      or me.fill[4].getBoolValue();

	var main_manifold_o = me.fill[0].getBoolValue()
			  or  me.fill[1].getBoolValue()
			  or  me.fill[2].getBoolValue()
			  or  me.xfeed[0].getBoolValue()
			  or  me.xfeed[1].getBoolValue()
			  or  me.xfeed[2].getBoolValue();

	# Pump status:
	for (var i=0; i<5; i+=1) {
	    if (me.xfer[i].getBoolValue() and main_manifold_o) select[i] = 1;
	    if (i < 3) {
		if (me.pump[i].getBoolValue()) select[i] = 1;
	    }
	}
	if (me.altpump.getBoolValue()) select[4] = 1;

	# Logic:
	#     Aux tank feeding mains with thru-flow to engines
	if (select[3] == 1 and me.lev[3].getValue() > 55) {
	    for (var i=0; i<3; i+=1) {
		if (me.fill_status[i] == 1) {
		    select[i] = 0;
		    thru_flow[i] = 1;
		}
	    }
	}
	#     Center main leveling with wing mains with thru-flow to engines
	if (me.xfer[1].getBoolValue() and select[1] == 1 and me.lev[1].getValue() > 55) {
	    if (me.fill_status[0] == 1) {
		select[0] = 0;
		thru_flow[0] = 1;
	    }
	    if (me.fill_status[2] == 1) {
		select[2] = 0;
		thru_flow[2] = 1;
	    }
	}
	#     Alt pump overrides center main boost pumps
	if (me.altpump.getBoolValue() and me.lev[4].getValue() > 55)
	    select[1] = 0;
	#     Thru flow from tail tank to mains to engines
	if (select[4] == 1 and me.xfer[4].getBoolValue() and me.lev[4].getValue() > 55) {
	    for (var i=0; i<3; i+=1) {
		if (me.fill[i].getBoolValue() and me.fill_status[i] == 0) {
		    select[i] = 0;
		    thru_flow[i] = 1;
		}
	    }
	}

	# Engine suction and cutouts:
	var speed = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
	var n1 = [ getprop("engines/engine[0]/rpm"),
		   getprop("engines/engine[1]/rpm"),
		   getprop("engines/engine[2]/rpm") ];
	var eng = [ props.globals.getNode("engines/engine[0]/run"),
		    props.globals.getNode("engines/engine[1]/run"),
		    props.globals.getNode("engines/engine[2]/run") ];

	for (var i=0; i<3; i+=1) {
	    if (select[i] == 0 and thru_flow[i] == 0 and !(me.xfeed[i].getBoolValue() and manifold_p)) {
		if (i != 1 and n1[i] > 26 and n1[i] < 89 and speed > 180) {
		    select[i] = 1;
		} else {
		    if (!(i == 1 and me.altpump.getBoolValue()))
			eng[i].setBoolValue(0);
		}
	    }
	}

	# Deselect empty tanks and set the tanks statuses:
	for (var i=0; i<5; i+=1) {
	    if (me.empty[i].getBoolValue()) select[i] = 0;
	    me.sel[i].setBoolValue(select[i]);
	}

	# Do any transfers:
	if (manifold_o and manifold_p) me.transfers();
	
	settimer(func { me.update();},0.5);
    },

    transfers : func {
	var rate = 0.5 * getprop("sim/speed-up");  # in gallons / half-second
	var sources = 0;
	var sinks = 0;
	for (var i=0; i<5; i+=1) {
	    if (me.xfer[i].getBoolValue() and me.lev[i].getValue() / me.density.getValue() > 1.5 * rate)
		sources+= 1;
	    if (me.fill_status[i] == 1 and me.lev[i].getValue() / me.density.getValue() < me.cap[i].getValue() - rate)
		sinks+= 1;
	}

	var xfer_rate = 0.0;
	if (sinks != 0 and sources != 0) {
	    var xfer_rate = rate * me.density.getValue() * sinks;
	    if (xfer_rate > rate * me.density.getValue() * sources * 1.5)
	        xfer_rate = rate * me.density.getValue() * sources * 1.5;
		
	}
	for (var i=0; i<5; i+=1) {
	    if (me.xfer[i].getBoolValue() and me.lev[i].getValue() > xfer_rate / sources) {
		me.lev[i].setValue(me.lev[i].getValue() - (xfer_rate / sources));
	    }
	}
	for (var i=0; i<5; i+=1) {
	    if (me.fill_status[i] == 1 and (me.lev[i].getValue() / me.density.getValue()) < me.cap[i].getValue() - rate)
		me.lev[i].setValue(me.lev[i].getValue() + (xfer_rate / sinks));
	}

	# Fuel Jettison
	var jettrate = rate * me.density.getValue();
	if (getprop("controls/fuel/dump-valve")) {
	    for (var i=0; i<3; i+=1) {
		if (me.xfer[i].getBoolValue())
		    me.lev[i].setValue(me.lev[i].getValue() - (jettrate * 3));
	    }
	    if (me.xfer[3].getBoolValue() and me.lev[3].getValue() > jettrate * 2)
		me.lev[3].setValue(me.lev[3].getValue() - (jettrate * 2));
	    if (me.xfer[4].getBoolValue() and me.lev[4].getValue() > jettrate) {
		me.lev[4].setValue(me.lev[4].getValue() - jettrate);
	    } else {
		if (me.xfer[3].getBoolValue() and me.lev[3].getValue() > jettrate)
		    me.lev[3].setValue(me.lev[3].getValue() - jettrate);
	    }
	}
    },

    fsc : func {
	var xfers = [ 0, 0, 0, 0, 0 ];
	var fills = [ 0, 0, 0, 0, 0 ];

	# Main Fuel Boost Pumps
	for (var i=0; i<3; i+=1) {
	    if (getprop("engines/engine["~i~"]/run") or getprop("controls/engines/StartIgnition-knob["~i~"]") != 0) {
		me.pump[i].setBoolValue(1);
	    } else {
		me.pump[i].setBoolValue(0);
	    }
	}

	# Aux Tanks
	if (!me.empty[3].getBoolValue()) {
	    fills[0] = 1;
	    fills[1] = 1;
	    fills[2] = 1;
	    xfers[3] = 1;
	}

	# Level Mains
	var diffL = me.lev[1].getValue() - me.lev[0].getValue();
	var diffR = me.lev[1].getValue() - me.lev[2].getValue();
	if (me.empty[3].getBoolValue() and (diffL > 20 or diffR > 20)) {
	    fills[0] = 1;
	    fills[2] = 1;
	    xfers[1] = 1;
	}

	# Balance L/R
	var xdiff = diffR > 20 or diffL > 20;
	if (me.lev[0].getValue() - me.lev[2].getValue() > 20) {
	    fills[0] = 0;
	    if (!xdiff) {
		xfers[0] = 1;
		fills[2] = 1;
	    }
	}
	if (me.lev[2].getValue() - me.lev[0].getValue() > 20) {
	    fills[2] = 0;
	    if (!xdiff) {
		xfers[2] = 1;
		fills[0] = 1;
	    }
	}

	# Tail Tank Management
	var xfer_fwd = func {
	    xfers[4] = 1;
	    fills[4] = 0;
	    if (!me.empty[3].getBoolValue()) {
		fills[3] = 1;
	    } else {
		fills[1] = 1;
		if (me.lev[1].getValue() <= me.lev[0].getValue())
		    fills[0] = 1;
		if (me.lev[1].getValue() <= me.lev[2].getValue())
		    fills[2] = 1;
	    }
	}

    
	if (me.tail_mgm_enable == 1) {
	    # No rearward transfer if total fuel < 51000 lbs
	    if (me.total.getValue() < 51000) me.tail_filled = 1;
	    # If tail engine shut down, max 5000 lbs in tail tank
	    if (me.lev[4].getValue() > 5000 and !getprop("engines/engine[1]/run")) {
		me.tail_filled = 1;
		xfer_fwd();
	    }
	    # Tail tank is full
	    if (me.lev[4].getValue() / me.density.getValue() >= me.cap[4].getValue() - 2.5)
		me.tail_filled = 1;
	    # Max 9.5% total fuel in tail tank
	    if (me.lev[4].getValue() > me.total.getValue() * 0.095) {
		me.tail_filled = 1;
	    }
	
		if (me.tail_filled == 0) {
		# Transfer fuel rearward
		    fills[4] = 1;
		    fills[3] = 0;
		    if (!me.empty[3].getBoolValue()) {
			xfers[3] = 1;
		    } else {
			xfers[1] = 1;
			fills[1] = 0;
			if (me.lev[1].getValue() <= me.lev[0].getValue()) {
			    xfers[0] = 1;
			    fills[0] = 0;
			}
			if (me.lev[1].getValue() <= me.lev[2].getValue()) {
			    xfers[2] = 1;
			    fills[2] = 0;
			}
		    }
		} else {
		# Every 30 minutes, transfer fuel fwd for 1 minute
		    me.ticks+= 1;
		    if ((me.ticks * getprop("sim/speed-up")) >= 3600) {
			xfer_fwd();
			if ((me.ticks * getprop("sim/speed-up")) >= 3720 and me.lev[4].getValue() < me.total.getValue() * 0.095)
			    me.ticks = 0;
		    }
		    if (me.empty[4].getBoolValue()) me.tail_mgm_enable = 0;
		}

		for (var i=0; i<3; i+=1) {
		# Maintain mains at 11,500 lbs until tail tank is empty
		    if (me.lev[i].getValue() < 11500) {
			fills[i] = 1;
			xfers[4] = 1;
			me.fill_status[i] = 0;
		    }
		}
		if (getprop("instrumentation/altimeter/pressure-alt-ft") < 26750 and getprop("instrumentation/inst-vertical-speed-indicator/indicated-speed-fpm") < -250) {
		# Cancel tail management on descent and transfer fuel fwd
		    me.tail_mgm_enable = 0;
		}
	} else {
		if (!me.empty[4].getBoolValue())
		    xfer_fwd();
	}

	# Ground and T/O inhibitors
	if (getprop("gear/gear[0]/wow")) {
	    fills[4] = 0;
	    xfers[4] = 0;
	}
	var n1 = [ getprop("engines/engine[0]/rpm"),
                   getprop("engines/engine[1]/rpm"),
                   getprop("engines/engine[2]/rpm") ];
	if (getprop("controls/flight/flaps") > 0.1 and (n1[0] > 65 or n1[1] > 65 or n1[2] > 65)) {
	    for (var i=0; i<5; i+=1) {
		fills[i] = 0;
		xfers[i] = 0;
	    }
	}

	for (var i=0; i<5; i+=1) {
	    me.fill_arm[i].setBoolValue(1);
	    me.fill[i].setBoolValue(fills[i]);
	    me.xfer[i].setBoolValue(xfers[i]);
	}
    },

    tail_mng : func {
	setlistener("controls/fuel/auto-manage", func (mg) {
	    if (mg.getBoolValue()) {
	    	if (getprop("gear/gear[0]/wow")) {
		    var gnd = setlistener("gear/gear[0]/wow", func (wow) {
			if (!wow.getBoolValue() and me.total.getValue() > 59000) {
			    me.tail_mgm_enable = 1;
			    removelistener(gnd);
			}
		    },0,0);
		} else {
		    if (me.total.getValue() > 51000)
			me.tail_mgm_enable = 1;
		}
		me.tail_filled = 0;
		me.ticks = 0;
	    } else {
#		var back2manual = setlistener("controls/fuel/auto-manage", func (b2m) {
#		    if (!b2m.getBoolValue()) {
			for (var i=0; i<3; i+=1) {
			    me.pump[i].setBoolValue(1);
			    me.xfeed[i].setBoolValue(0);
			}
			me.xfer[0].setBoolValue(0);
			me.xfer[2].setBoolValue(0);
			me.xfer[3].setBoolValue(1);
			me.xfer[4].setBoolValue(1);
			me.altpump.setBoolValue(0);
#		    }
#		    removelistener(back2manual);
#		},0,0);
	    }
	},0,0);
    },

    idle_fuelcon : func {
	var dt = getprop("sim/time/delta-sec");

	var get_src = func (eng) {
	    var src = -1;
	    if (me.sel[eng].getBoolValue()) {
		src = eng;
	    } else {
		if (eng == 0) {
		    if (me.sel[2].getBoolValue()) src = 2;
		    if (me.sel[1].getBoolValue()) src = 1;
		}
		if (eng == 1) {
		    if (me.sel[0].getBoolValue()) src = 1;
		    if (me.sel[2].getBoolValue()) src = 2;
		    if (me.sel[0].getBoolValue() and me.sel[2].getBoolValue())
			src = -2;
		}
		if (eng == 2) {
		    if (me.sel[0].getBoolValue()) src = 0;
		    if (me.sel[1].getBoolValue()) src = 1;
		}
		if (me.sel[4].getBoolValue()) src = 4;
		if (me.sel[3].getBoolValue()) src = 3;
	    }
	    return src;
	}

	var idle_ff = func (eng,src) {
		var rate = getprop("engines/engine[" ~eng~ "]/n1") * (26.0 + rand());
                #lbs/hr
                var cons = rate * dt / 3600;
                var cutoff = getprop("controls/engines/engine[" ~eng~ "]/cutoff");
                var frate = getprop("engines/engine[" ~eng~ "]/fuel-flow-gph");

		if (eng == 1) rate = rate / 2;

                if (!cutoff and !me.empty[src].getBoolValue() and frate<10)
                        me.lev[src].setValue(me.lev[src].getValue() - cons);
        }

	if (getprop("engines/engine[0]/run")) idle_ff(0,get_src(0));
	if (getprop("engines/engine[2]/run")) idle_ff(2,get_src(2));
	if (getprop("engines/engine[1]/run")) {
		var source = get_src(1);
		if (source == -2) {
		    idle_ff(1,0);
		    idle_ff(1,2);
		} else {
		    idle_ff(1,source);
		    idle_ff(1,source);
		}
	}
	if (getprop("controls/APU/run")) me.apu_fuelcon(dt,1);

	settimer(func{me.idle_fuelcon();},0);
    },

    apu_fuelcon : func (dt,src) {
	var rate = 741;  #lbs/hr

        var cons = (rand() * rate) * dt / 3600;
        var surcharge = 0.0;

        if (src < 0) src = 0;

        # Insert surcharges here:
#        if (getprop("controls/electrical/APU-generator"))
#                surcharge = surcharge + 0.003;
#        if (getprop("controls/pneumatic/apu-bleed"))
#                surcharge = surcharge + 0.02;
#        if (getprop("systems/pneumatic/packs/pack[0]") == 1)
#                surcharge = surcharge + 0.02;
#        if (getprop("systems/pneumatic/packs/pack[1]") == 1)
#                surcharge = surcharge + 0.02;
#        if (getprop("controls/engines/engine[0]/starter")) surcharge = surcharge + 0.2;
#        if (getprop("controls/engines/engine[1]/starter")) surcharge = surcharge + 0.2;

        cons = cons * (1 + surcharge);

        if (!me.empty[src].getBoolValue()) {
                me.lev[src].setValue(me.lev[src].getValue() - cons);
        } else {
                setprop("controls/APU/off-start-run",0);
        }
    }
};
var MD11fuel = fuelsys.new();
setlistener("/sim/signals/fdm-initialized", func {
	MD11fuel.tail_mng();
	MD11fuel.update();
	MD11fuel.idle_fuelcon();
},0,0);

var balance_fuel = func {
	var lev = [ props.globals.getNode("consumables/fuel/tank[0]/level-gal_us",1),
		    props.globals.getNode("consumables/fuel/tank[1]/level-gal_us",1),
		    props.globals.getNode("consumables/fuel/tank[2]/level-gal_us",1),
		    props.globals.getNode("consumables/fuel/tank[3]/level-gal_us",1),
		    props.globals.getNode("consumables/fuel/tank[4]/level-gal_us",1) ];

	var cap = [ getprop("consumables/fuel/tank[0]/capacity-gal_us"),
		    getprop("consumables/fuel/tank[1]/capacity-gal_us"),
		    getprop("consumables/fuel/tank[2]/capacity-gal_us"),
		    getprop("consumables/fuel/tank[3]/capacity-gal_us"),
		    getprop("consumables/fuel/tank[4]/capacity-gal_us") ];

	var total = getprop("consumables/fuel/total-fuel-gal_us");

	if (total / 3 > cap[0]) {
		lev[0].setValue(cap[0]);
		lev[2].setValue(cap[2]);
	} else {
		lev[0].setValue(total / 3);
		lev[2].setValue(total / 3);
	}
	total = total - lev[0].getValue() - lev[2].getValue();
	if (total > cap[1]) {
		lev[1].setValue(cap[1]);
	} else {
		lev[1].setValue(total);
	}
	total = total - lev[1].getValue();
	if (total > cap[3]) {
		lev[3].setValue(cap[3]);
	} else {
		lev[3].setValue(total);
	}
	total = total - lev[3].getValue();
	if (total > cap[4]) {
		lev[4].setValue(cap[4]);
	} else {
		lev[4].setValue(total);
	}
}


