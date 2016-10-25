# Pneumatics

var supply_l = 0.0;
var supply_r = 0.0;

var pneumatic = {
    new : func {
        m = { parents : [pneumatic]};
	m.controls = props.globals.getNode("controls/pneumatic",1);
	m.system = props.globals.getNode("systems/pneumatic",1);
	# Switches
	m.apu_valve = m.controls.initNode("APU-bleed-valve",0,"BOOL");
	m.eng_bleed = [ m.controls.initNode("engine-bleed[0]",0,"BOOL"),
			m.controls.initNode("engine-bleed[1]",0,"BOOL"),
			m.controls.initNode("engine-bleed[2]",0,"BOOL") ];
	m.isln_l = m.controls.initNode("isolation-valve[0]",1,"BOOL");	# 1-2 ISOL
	m.isln_r = m.controls.initNode("isolation-valve[1]",1,"BOOL");	# 1-3 ISOL
	m.auto_mode = m.controls.initNode("auto-mode",0,"BOOL");

	# Supplies
	m.APU = m.system.initNode("APU-bleed",0,"BOOL");
	m.eng = [ props.globals.getNode("engines/engine[0]/rpm",1),
		  props.globals.getNode("engines/engine[1]/rpm",1),
		  props.globals.getNode("engines/engine[2]/rpm",1) ];
	m.service = m.system.initNode("air-service",0,"BOOL");

	# Packs
	m.pack_knob = [ m.controls.initNode("pack-control[0]",0,"BOOL"),
			m.controls.initNode("pack-control[1]",0,"BOOL"),
			m.controls.initNode("pack-control[2]",0,"BOOL") ];
	m.pack_status = [ m.system.initNode("pack[0]",0,"INT"),
			  m.system.initNode("pack[1]",0,"INT"),
			  m.system.initNode("pack[2]",0,"INT") ];
	m.packs_hi = m.controls.initNode("pack-high-flow",0,"BOOL");
#	m.pack_fault = m.system.initNode("pack-sys-fault",0,"BOOL");

	# Demands
	m.starter = [ props.globals.getNode("controls/engines/StartIgnition-knob[0]",1),
		      props.globals.getNode("controls/engines/StartIgnition-knob[1]",1),
		      props.globals.getNode("controls/engines/StartIgnition-knob[2]",1) ];
	m.APU_gen = props.globals.getNode("controls/electric/APU-generator",1);
	m.deice = props.globals.getNode("controls/anti-ice/wing-heat",1);
	m.deice.setBoolValue(0);

	# Output
	m.bleed_air = [ m.system.initNode("bleed-air[0]",0,"BOOL"),
			m.system.initNode("bleed-air[1]",0,"BOOL") ];
	m.pressure = [ m.system.initNode("pressure-norm[0]",0,"DOUBLE"),
		       m.system.initNode("pressure-norm[1]",0,"DOUBLE") ];

    return m;
    },

    update_pres : func {
	# Supply
	supply_l = 0.0;
	supply_r = 0.0;

	#   Left
	if (me.isln_l.getBoolValue()) {
	    if (me.service.getBoolValue())
		supply_l = supply_l + 0.89;
	    if (me.APU.getBoolValue() and me.apu_valve.getBoolValue())
		supply_l = supply_l + 1.02;
	}
	if (me.eng[0].getValue() > 21 and me.eng_bleed[0].getBoolValue()) {
		supply_l = supply_l + 1.08;
	    if (me.isln_r.getBoolValue())
		supply_r = supply_r + 1.08;
	}
	if (me.eng[1].getValue() > 21 and me.eng_bleed[1].getBoolValue() and me.isln_l.getBoolValue()) {
		supply_l = supply_l + 1.08;
	    if (me.isln_l.getBoolValue() and me.isln_r.getBoolValue())
		supply_r = supply_r + 1.08;
	}

	#   Right
	if (me.isln_r.getBoolValue() and me.isln_l.getBoolValue()) {
	    if (me.service.getBoolValue())
		supply_r = supply_r + 0.89;
	    if (me.APU.getBoolValue() and me.apu_valve.getBoolValue())
		supply_r = supply_r + 1.02;
	}
	if (me.eng[2].getValue() > 21 and me.eng_bleed[2].getBoolValue()) {
		supply_r = supply_r + 1.08;
	    if (me.isln_r.getBoolValue())
		supply_l = supply_l + 1.08;
	}

	var air_l = 45 * supply_l;
	var air_r = 45 * supply_r;

	supply_l = 0.0;
	supply_r = 0.0;

	# Demand

	 # Starters
	var dem = 0;
	for (var i=0; i<3; i+=1) {
	    if (me.starter[i].getValue()) {
		if (me.eng[i].getValue() < 14) {
		    dem = 0.33;
		} else {
		    dem = 0.12;
		}
		if (i == 0) {
		    supply_l = supply_l - dem;
		    if (me.isln_r.getBoolValue())
			supply_r = supply_r - dem;
		} elsif (i == 1 and me.isln_l.getBoolValue()) {
		    supply_l = supply_l - dem;
		    if (me.isln_r.getBoolValue())
			supply_r = supply_r - dem;
		} else {
		    supply_r = supply_r - dem;
		    if (me.isln_r.getBoolValue())
			supply_l = supply_l - dem;
		}
	    }
	}

	 # APU generator
	if (me.APU_gen.getValue() == 2 and me.apu_valve.getBoolValue()) {
	    if (me.isln_l.getBoolValue())
		supply_l = supply_l - 0.05;
	    if (me.isln_r.getBoolValue())
		supply_r = supply_r - 0.05;
	}

	 # Packs
	var hiflo = 1.0;
	if (me.packs_hi.getBoolValue()) hiflo = 1.2;
	if (me.pack_status[0].getValue() == 1) {
	    supply_l = supply_l - (0.30 * hiflo);
	    if (me.isln_r.getBoolValue())
		supply_r = supply_r - (0.30 * hiflo);
	}
	if (me.pack_status[1].getValue() == 1) {
	    if (me.isln_l.getBoolValue()) {
		supply_l = supply_l - (0.30 * hiflo);
		if (me.isln_r.getBoolValue())
		    supply_r = supply_r - (0.30 * hiflo);
	    }
	}
	if (me.pack_status[2].getValue() == 1) {
	    supply_r = supply_r - (0.30 * hiflo);
	    if (me.isln_r.getBoolValue())
		supply_l = supply_l - (0.30 * hiflo);
	}

	 # Wing Anti-Ice
	if (me.deice.getBoolValue()) {
		supply_l = supply_l - 0.18;
		supply_r = supply_r - 0.18;
	}

	supply_l = 8 * supply_l;
	supply_r = 8 * supply_r;


	supply_l = supply_l + air_l;
	supply_r = supply_r + air_r;

	if (supply_l > 45) supply_l = 45;
	if (supply_r > 45) supply_r = 45;
	if (supply_l < 0) supply_l = 0;
	if (supply_r < 0) supply_r = 0;

	if (supply_l > 36.8) {
		me.bleed_air[0].setBoolValue(1);
	} else {
		me.bleed_air[0].setBoolValue(0);
	}
	if (supply_r > 36.8) {
		me.bleed_air[1].setBoolValue(1);
	} else {
		me.bleed_air[1].setBoolValue(0);
	}
	me.pressure[0].setValue(supply_l);
	me.pressure[1].setValue(supply_r);
    },

    update_auto : func {
	if (me.auto_mode.getBoolValue()) {
	    me.isln_l.setBoolValue(1);
	    me.isln_r.setBoolValue(1);
	    #APU
	    if (me.APU.getBoolValue()) {
		me.apu_valve.setBoolValue(1);
	    } else {
		me.apu_valve.setBoolValue(0);
	    }
	    #Engine Bleeds
	    for (var i=0; i<3; i+=1) {
		if (me.eng[i].getValue() > 21) {
		    me.eng_bleed[i].setBoolValue(1);
		} else {
		    me.eng_bleed[i].setBoolValue(0);
		}
	    #Packs
		if (me.starter[0].getValue()!=0 or me.starter[1].getValue()!=0 or me.starter[2].getValue()!=0) {
		    me.pack_knob[i].setBoolValue(0);
		} else {
		    if (me.eng_bleed[i].getBoolValue()) {
			if ((i==0 or i==2) and getprop("position/altitude-agl-ft") < 400 and me.eng[i].getValue() > 70) {
			    me.pack_knob[i].setBoolValue(0);
			} else {
			    me.pack_knob[i].setBoolValue(1);
			}
		    } elsif (me.apu_valve.getBoolValue() and me.APU.getBoolValue()) {
			if ((i==0 and me.isln_l.getBoolValue()) or i==1)
			    me.pack_knob[i].setBoolValue(1);
		    } else {
			me.pack_knob[i].setBoolValue(0);
		    }
		}
	    }
	    if (getprop("systems/pressurization/cabin-altitude-ft") > 9500)
		packs_hi.setBoolValue(1);
	}
    },

    update : func {
	me.update_auto();
	# No ground air if parking brake off or aircraft in the air.
	if (!getprop("controls/gear/brake-parking") or !getprop("gear/gear[1]/wow"))
	    me.service.setBoolValue(0);

	# APU active
	if (getprop("controls/APU/run")) {
	    me.APU.setBoolValue(1);
	} else {
	    me.APU.setBoolValue(0);
	}

	# Pressure checks
	me.update_pres();
	var cutout_l = 0;
	var cutout_r = 0;
	var middle = 0;
	if (me.bleed_air[0].getBoolValue() and me.isln_l.getBoolValue()) {
	    middle = 1;
	} elsif (!me.isln_l.getBoolValue()) {
	    if ((me.APU.getBoolValue() and me.apu_valve.getBoolValue()) or me.service.getBoolValue() or (me.eng[1].getValue() > 21 and me.eng_bleed[1].getBoolValue()))
		middle = 1;
	} else {
	    middle = 0;
	}
	if (!me.bleed_air[0].getBoolValue())
		cutout_l = 1;
	if (!me.bleed_air[1].getBoolValue())
		cutout_r = 1;

	# Packs
	var packs_off = 0;
	for (var i=0; i<3; i+=1) {
	    var status = me.pack_status[i].getValue();
	    if (me.pack_knob[i].getBoolValue()) {
#		if (!me.pack_fault.getBoolValue()) {
		    if (i == 0) {
			if (cutout_l == 0) status = 1;
		    }
		    if (i == 1) {
			if (middle == 1) status = 1;
		    }
		    if (i == 2) {
			if (cutout_r == 0) status = 1;
			if (getprop("systems/pressurization/relief-valve") or getprop("controls/pressurization/outflow-valve-pos[0]") == 0 or getprop("controls/pressurization/outflow-valve-pos[1]") == 0)
			    status = 0;
			if (getprop("gear/gear[0]/wow") and !getprop("controls/gear/brake-parking"))
			    status = 0;
		    }
#		}
	    } else {
		status = 0;
		packs_off += 1;
	    }
	    me.pack_status[i].setValue(status);
	}
#	if (packs_off == 3)
#	    me.pack_fault.setBoolValue(0);

	# Low pressure cutouts
	if (getprop("instrumentation/airspeed-indicator/indicated-speed-kt") < 180) {
	    if (cutout_l == 1 and me.starter[0].getValue()) {
		settimer(func {me.starter[0].setValue(0);},0.3);
		cutout_l = 0;
		cutout_r = 0;
	    }
	    if (middle == 0 and me.starter[1].getValue()) {
		settimer(func {me.starter[1].setValue(0);},0.3);
		cutout_l = 0;
		cutout_r = 0;
	    }
	    if (cutout_r == 1 and me.starter[2].getValue()) {
		settimer(func {me.starter[2].setValue(0);},0.3);
		cutout_l = 0;
		cutout_r = 0;
	    }
	}
	if (cutout_r == 1 and me.pack_status[2].getValue() == 1) {
		me.pack_status[2].setValue(-1);
		cutout_l = 0;
		cutout_r = 0;
	}
	if (middle == 0 and me.pack_status[1].getValue() == 1) {
		me.pack_status[1].setValue(-1);
#		me.pack_fault.setBoolValue(1);
	}
	if (cutout_l == 1 and me.pack_status[0].getValue() == 1) {
		me.pack_status[0].setValue(-1);
		cutout_l = 0;
		cutout_r = 0;
	}
	if (cutout_l == 1 and cutout_r == 1)
		me.deice.setBoolValue(0);
    },

};
var MD11air = pneumatic.new();
var air_loop = func {
	MD11air.update();
	settimer(air_loop,0.5);
}
setlistener("/sim/signals/fdm-initialized", func (init) {
	if (init.getBoolValue()) {
		settimer( func {
		   air_loop(); 
		},2);
	}
},0,0);

print('Pneumatic System ... Check');
