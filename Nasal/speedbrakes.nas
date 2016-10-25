# Speedbrake controller - tikibar, and it0uchpods



var spoilers = {
    new : func {
	m = { parents : [spoilers] };

	m.lever = props.globals.initNode("controls/flight/speedbrake-lever",0,"INT");
	m.auto = props.globals.initNode("controls/flight/autospeedbrakes-armed",0,"BOOL");
	m.pos_cmd = props.globals.getNode("controls/flight/speedbrake",0);
#	m.hydraulic = props.globals.getNode("systems/hydraulic/equipment/enable-spoil",0);

	m.lev_pos = 0;

	return m;
    },

    update : func {
	me.lev_pos = me.lever.getValue();

	# Set the status of auto and the speedbrake position
	if (me.lev_pos == 0) {
	    me.pos_cmd.setValue(0);
	}
	if (me.lev_pos == 1) {
	    me.pos_cmd.setValue(0.250);
	}
	if (me.lev_pos == 2) {
	    me.pos_cmd.setValue(0.500);
	}
	if (me.lev_pos == 3) {
	    me.pos_cmd.setValue(0.750);
	}
	if (me.lev_pos == 4) {
	    me.pos_cmd.setValue(1.0);
	}
    },

    arm : func {
	# Auto speedbrake
	if (me.auto.getBoolValue()) {
	    var td = setlistener("gear/gear[1]/wow", func {
		me.autospeedbrake();
	    },0,0);
	    var td2 = setlistener("gear/gear[0]/wow", func {
		me.autospeedbrake();
	    },0,0);
	    var asb = setlistener("controls/flight/autospeedbrakes-armed", func {
		if (!me.auto.getBoolValue()) {
		    removelistener(asb);
		    removelistener(td);
		    removelistener(td2);
		}
	    },0,0);
	}
    },

    autospeedbrake : func {
	var throt = getprop("controls/engines/engine[0]/throttle-act") < 0.4 and
		    getprop("controls/engines/engine[1]/throttle-act") < 0.4 and
		    getprop("controls/engines/engine[2]/throttle-act") < 0.4;
	var revrs = getprop("controls/engines/engine[0]/reverser") and
		    getprop("controls/engines/engine[1]/reverser") and
		    getprop("controls/engines/engine[2]/reverser");
	if (me.auto.getBoolValue() and getprop("systems/hydraulic/equipment/enable-spoil")) {
	    if ((getprop("gear/gear[1]/wow") or getprop("gear/gear[2]/wow") or getprop("gear/gear[3]/wow") or getprop("gear/gear[4]/wow")) and (throt or revrs)) {
		me.pos_cmd.setValue(0.750);
		setprop("controls/flight/speedbrake-lever", 3);
		if (getprop("gear/gear[0]/wow")) {
			me.pos_cmd.setValue(1.0);
			setprop("controls/flight/speedbrake-lever", 4);
		}
	    }
	}
    },
};

var Speedbrakes = spoilers.new();
setlistener("controls/flight/speedbrake-lever", func {
	if (!getprop("gear/gear[0]/wow") and getprop("controls/flight/speedbrake-lever")==4)
	    setprop("controls/flight/speedbrake-lever",0);
	Speedbrakes.update();
},0,0);
setlistener("controls/flight/autospeedbrakes-armed", func {
	Speedbrakes.arm();
},0,0);

