# McDonnell Douglas MD-10
# Aircraft systems
#########################

var is_tanker = getprop("sim/aircraft") == "KC-10A";

# NOTE: This file contains a loop for running all update functions, so it should be loaded last

  setlistener("controls/autoflight/heading-select", func {
  	setprop("autopilot/settings/heading-bug-deg", getprop("controls/autoflight/heading-select"));
  });

## Properties to save on exit
var save_properties =
[
	"controls/autoflight/enable-mode-annunciators",
	"controls/gear/enable-tiller"
];
foreach (var property; save_properties)
{
	aircraft.data.add(property);
}

## Main systems update loop
var systems =
{
	loopid: -1,
	init: func
	{
		print("Systems ... FINE!");
		systems.loopid += 1;
		settimer(func systems.update(systems.loopid), 0);
	},
	stop: func
	{
		systems.loopid -= 1;
	},
	reinit: func
	{
		print("MD-10 aircraft systems ... reinitialized");
		setprop("sim/model/start-idling", 0);
		systems.stop();
		settimer(func systems.update(systems.loopid), 0);
	},
	update: func(id)
	{
		# check if our loop id matches the current loop id
		if (id != systems.loopid) return;
		engine1.update();
		engine2.update();
		engine3.update();
		update_electrical();
		update_gear();
		if (is_tanker) update_tanker();
		# stop calling our systems code if the aircraft crashes
		if (!props.globals.getNode("sim/crashed").getBoolValue())
		{
			settimer(func systems.update(id), 0);
		}
	}
};

# call init() 2 seconds after the FDM is ready
setlistener("sim/signals/fdm-initialized", func
{
	settimer(systems.init, 2);
}, 0, 0);
# call init() if the simulator resets
setlistener("sim/signals/reinit", func(reinit)
{
	if (reinit.getBoolValue())
	{
		systems.reinit();
	}
}, 0, 0);

## Startup/shutdown functions
var startid = -1;
var startup = func
{
	startid += 1;
	var id = startid;
	setprop("controls/engines/engine[0]/cutoff", 1);
	setprop("controls/engines/engine[1]/cutoff", 1);
	setprop("controls/engines/engine[2]/cutoff", 1);
	setprop("controls/engines/engine[0]/starter", 1);
	setprop("controls/engines/engine[1]/starter", 1);
	setprop("controls/engines/engine[2]/starter", 1);
	settimer(func
	{
		if (id == startid)
		{
			setprop("controls/engines/engine[0]/cutoff", 0);
			setprop("controls/engines/engine[1]/cutoff", 0);
			setprop("controls/engines/engine[2]/cutoff", 0);
		}
	}, 2);
};
var shutdown = func
{
	setprop("controls/engines/engine[0]/cutoff", 1);
	setprop("controls/engines/engine[1]/cutoff", 1);
	setprop("controls/engines/engine[2]/cutoff", 1);
};
setlistener("sim/model/start-idling", func(idle)
{
	var run = idle.getBoolValue();
	if (run)
	{
		startup();
	}
	else
	{
		shutdown();
	}
}, 0, 0);

## Tanker update function
var update_tanker = func
{
	# Turn tanker on/off based on boom position and fuel level
	# TODO: Consume fuel when aircraft is refueling
	var boom_pos = props.globals.getNode("sim/model/door-positions/boom/position-norm");
	var fuel = props.globals.getNode("sim/weight[1]/weight-lb");
	var on_off = props.globals.getNode("tanker", 1);
	on_off.setBoolValue(boom_pos != nil and fuel.getValue() > 0 and boom_pos.getValue() == 1);

	# Raise the boom when any of the gears are compressed
	if ((props.globals.getNode("gear/gear[0]/wow").getBoolValue() or props.globals.getNode("gear/gear[2]/wow").getBoolValue() or props.globals.getNode("gear/gear[4]/wow").getBoolValue()) and boom_pos.getValue() > 0)
	{
		doors.boom.setpos(0);
	}
};

## Prevent landing gear retraction if any of the gears are compressed
setlistener("controls/gear/gear-down", func(gear_down)
{
	var down = gear_down.getBoolValue();
	if (!down and (props.globals.getNode("gear/gear[0]/wow").getBoolValue() or props.globals.getNode("gear/gear[2]/wow").getBoolValue() or props.globals.getNode("gear/gear[4]/wow").getBoolValue()))
	{
		gear_down.setBoolValue(1);
	}
}, 0, 0);

## Autopilot
# mode annunciator messages
var ap_mode_annunN = props.globals.getNode("controls/autoflight/enable-mode-annunciators", 1);
setlistener(ap_mode_annunN, func(v)
{
	announce_ap_mode(nil, "Mode annunciators " ~ (v.getBoolValue() ? "ON." : "OFF."), 0);
}, 0, 0);
setlistener("controls/autoflight/control-wheel-steering-override", func(v)
{
	announce_ap_mode(nil, "Control wheel steering override " ~ (v.getBoolValue() ? "ON." : "OFF."));
}, 0, 0);
setlistener("controls/autoflight/nav-backcourse", func(v)
{
	announce_ap_mode(nil, "VOR backcourse mode " ~ (v.getBoolValue() ? "ON." : "OFF."));
}, 0, 0);
var ap_spd_modes =
[
	"IAS hold",
	"EPR limit"
];
var ap_lat_modes =
[
	"maintain heading",
	"magnetic heading hold",
	"inertial navigation system (Route Manager)",#"inertial navigation system (INS)",
	"VOR capture/track",
	"instrument landing system (ILS)"
];
var ap_ver_modes =
[
	"altitude capture",
	"vertical speed hold",
	"hold IAS with pitch",
	"hold Mach with pitch",#"performance management system (PMS)",
	"autoland"
];
var announce_ap_mode = func(n, x, check_mode = 1)
{
	if (check_mode and !ap_mode_annunN.getBoolValue()) return;
	var msg = "Autopilot: ";
	if (n == "speed")
	{
		msg ~= "Autothrottle set to " ~ ap_spd_modes[x] ~ ".";
	}
	elsif (n == "lateral")
	{
		msg ~= "Lateral mode set to " ~ ap_lat_modes[x] ~ ".";
	}
	elsif (n == "vertical")
	{
		msg ~= "Vertical mode set to " ~ ap_ver_modes[x] ~ ".";
	}
	else
	{
		msg ~= x;
	}
	setprop("sim/messages/copilot", msg);
};
var set_basic_heading = func
{
	setprop("controls/autoflight/heading-basic-select", getprop("instrumentation/heading-indicator[0]/indicated-heading-deg"));
};
var set_ias_with_pitch = func
{
	setprop("controls/autoflight/ias-with-pitch-select", getprop("instrumentation/airspeed-indicator[0]/indicated-speed-kt"));
};
var set_mach_with_pitch = func
{
	setprop("controls/autoflight/mach-with-pitch-select", getprop("instrumentation/airspeed-indicator[0]/indicated-mach"));
};
setlistener("controls/autoflight/speed-mode", func(v)
{
	announce_ap_mode("speed", v.getValue());
}, 0, 0);
setlistener("controls/autoflight/lateral-mode", func(v)
{
	v = v.getValue();
	announce_ap_mode("lateral", v);
	if (v == 0) set_basic_heading();
}, 0, 0);
setlistener("controls/autoflight/vertical-mode", func(v)
{
	v = v.getValue();
	announce_ap_mode("vertical", v);
	if (v == 2) set_ias_with_pitch();
	elsif (v == 3) set_mach_with_pitch();
}, 0, 0);
setlistener("controls/autoflight/autothrottle-engage[0]", func(v)
{
	if (v.getBoolValue())
	{
		announce_ap_mode(nil, "Autothrottle #1 engaged.");
		announce_ap_mode("speed", getprop("controls/autoflight/speed-mode"));
	}
}, 0, 0);
setlistener("controls/autoflight/autothrottle-engage[1]", func(v)
{
	if (v.getBoolValue())
	{
		announce_ap_mode(nil, "Autothrottle #2 engaged.");
		announce_ap_mode("speed", getprop("controls/autoflight/speed-mode"));
	}
}, 0, 0);
setlistener("controls/autoflight/autopilot[0]/engage-mode", func(v)
{
	v = v.getValue();
	if (v != 0)
	{
		var lat = getprop("controls/autoflight/lateral-mode");
		if (lat == 0) set_basic_heading();
		var ver = getprop("controls/autoflight/vertical-mode");
		if (ver == 2) set_ias_with_pitch();
		elsif (ver == 3) set_mach_with_pitch();
		if (v == 1)
 		{
 			announce_ap_mode(nil, "System #1 set to control wheel steering (CWS) mode.");
			announce_ap_mode("lateral", getprop("controls/autoflight/lateral-mode"));
			announce_ap_mode("vertical", getprop("controls/autoflight/vertical-mode"));
		}
		elsif (v == 2)
		{
			announce_ap_mode(nil, "System #1 set to command (CMD) mode.");
			announce_ap_mode("lateral", getprop("controls/autoflight/lateral-mode"));
			announce_ap_mode("vertical", getprop("controls/autoflight/vertical-mode"));
		}
	}
}, 0, 0);
setlistener("controls/autoflight/autopilot[1]/engage-mode", func(v)
{
	v = v.getValue();
	if (v != 0)
	{
		var lat = getprop("controls/autoflight/lateral-mode");
		if (lat == 0) set_basic_heading();
		var ver = getprop("controls/autoflight/vertical-mode");
		if (ver == 2) set_ias_with_pitch();
		elsif (ver == 3) set_mach_with_pitch();
		if (v == 1)
		{
			announce_ap_mode(nil, "System #2 set to control wheel steering (CWS) mode.");
			announce_ap_mode("lateral", getprop("controls/autoflight/lateral-mode"));
			announce_ap_mode("vertical", getprop("controls/autoflight/vertical-mode"));
		}
		elsif (v == 2)
		{
			announce_ap_mode(nil, "System #2 set to command (CMD) mode.");
			announce_ap_mode("lateral", getprop("controls/autoflight/lateral-mode"));
			announce_ap_mode("vertical", getprop("controls/autoflight/vertical-mode"));
		}
	}
}, 0, 0);
# disengage the autothrottles during autoland
setlistener("autopilot/autoland/align-phase", func(v)
{
	if (v.getBoolValue())
	{
		props.globals.getNode("controls/autoflight/autothrottle-engage[0]").setBoolValue(0);
		props.globals.getNode("controls/autoflight/autothrottle-engage[1]").setBoolValue(0);
	}
}, 0, 0);
# autobrake setting announce function
var announce_autobrake = func
{
	var node = props.globals.getNode ("/controls/gear/ABS-select", 1);
	var val = node.getValue ();
	var message = "Automatic brakes: ";
	if (val == 0)
	{
		message ~= "Disarmed.";
	}
	elsif (val == 1)
	{
		message ~= "Set to MIN.";
	}
	elsif (val == 2)
	{
		message ~= "Set to MED.";
	}
	elsif (val == 3)
	{
		message ~= "Set to maximum brake pressure.";
	}
	setprop ("/sim/messages/copilot", message);
};

## Instrumentation
# Spool up the instruments every 5 seconds
var update_spin = func
{
	setprop("instrumentation/attitude-indicator[0]/spin", 1);
	setprop("instrumentation/attitude-indicator[1]/spin", 1);
	setprop("instrumentation/attitude-indicator[2]/spin", 1);
	setprop("instrumentation/heading-indicator[0]/spin", 1);
	setprop("instrumentation/heading-indicator[1]/spin", 1);
	settimer(update_spin, 5);
};
settimer(update_spin, 5);
# Chronometers
var chronometer1 = aircraft.timer.new("instrumentation/clock[0]/elapsed-sec", 1, 0);
var chronometer2 = aircraft.timer.new("instrumentation/clock[1]/elapsed-sec", 1, 0);

## Landing gear updater
var update_gear = func
{
	var has_ctr_gear = props.globals.getNode("sim/model/livery/has-center-gear").getBoolValue();
	var ctr_gear_down = props.globals.getNode("controls/gear/center-gear-down");
	if (has_ctr_gear)
	{
		var ctr_gear_independent = props.globals.getNode("controls/gear/isolate-center-gear").getBoolValue();
		var gear_down = props.globals.getNode("controls/gear/gear-down");
		if (gear_down.getBoolValue())
		{
			if (!ctr_gear_independent)
			{
				ctr_gear_down.setBoolValue(1);
			}
			return;
		}
		ctr_gear_down.setBoolValue(0);
		return;
	}
	ctr_gear_down.setBoolValue(0);
	setprop("gear/gear[5]/position-norm", 0);
};

## Aircraft-specific dialogs
var dialogs =
{
	autopilot: gui.Dialog.new("sim/gui/dialogs/autopilot/dialog", "Aircraft/MD-10/Systems/autopilot-dlg.xml"),
	radio: gui.Dialog.new("sim/gui/dialogs/radio-stack/dialog", "Aircraft/MD-10/Systems/radio-stack-dlg.xml"),
	lights: gui.Dialog.new("sim/gui/dialogs/lights/dialog", "Aircraft/MD-10/Systems/lights-dlg.xml"),
	doors: gui.Dialog.new("sim/gui/dialogs/doors/dialog", "Aircraft/MD-10/Systems/doors-dlg.xml"),
	failures: gui.Dialog.new("sim/gui/dialogs/failures/dialog", "Aircraft/MD-10/Systems/failures-dlg.xml"),
	tiller: gui.Dialog.new("sim/gui/dialogs/tiller/dialog", "Aircraft/MD-10/Systems/tiller-dlg.xml")
};
gui.menuBind("autopilot", "MD10.dialogs.autopilot.open();");
gui.menuBind("radio", "MD10.dialogs.radio.open();");
