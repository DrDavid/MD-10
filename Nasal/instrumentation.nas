## Bombardier CRJ700 series
## Aircraft instrumentation
## Modified for MD-10 series
###########################

## Autopilot
# Basic roll mode controller
setlistener("autopilot/internal/basic-roll-mode-engage", func(v)
{
	if (!v.getBoolValue()) return;
	var roll = getprop("instrumentation/attitude-indicator[0]/indicated-roll-deg");
	if (math.abs(roll) > 5)
	{
		setprop("controls/autoflight/basic-roll-mode", 0);
		setprop("controls/autoflight/basic-roll-select", roll);
	}
	else
	{
		var heading = getprop("instrumentation/heading-indicator[0]/indicated-heading-deg");
		setprop("controls/autoflight/basic-roll-mode", 1);
		setprop("controls/autoflight/basic-roll-heading-select", heading);
	}
}, 0, 0);
# Basic pitch mode controller
setlistener("autopilot/internal/basic-pitch-mode-engage", func(v)
{
	if (!v.getBoolValue()) return;
	var pitch = getprop("instrumentation/attitude-indicator[0]/indicated-pitch-deg");
	setprop("controls/autoflight/pitch-select", int((pitch / 0.5) + 0.5) * 0.5);
}, 0, 0);

## Timers
var _normtime_ = func(x)
{
	while (x >= 60) x -= 60;
	return x;
};
# chronometer
var _gettimefmt_ = func(x)
{
	if (x >= 3600)
	{
		return sprintf("%02.f:%02.f", int(x / 3600), _normtime_(int(x / 60)));
	}
	return sprintf("%02.f:%02.f", _normtime_(int(x / 60)), _normtime_(x));
};
var chrono_prop = "instrumentation/clock/chronometer-time-sec";
var chrono_timer = aircraft.timer.new(chrono_prop, 1);
setlistener(chrono_prop, func(v)
{
	var fmtN = props.globals.getNode("instrumentation/clock/chronometer-time-fmt", 1);
	fmtN.setValue(_gettimefmt_(v.getValue()));
}, 0, 0);

# elapsed flight time (another chronometer)
var et_prop = "instrumentation/clock/elapsed-time-sec";
var et_timer = aircraft.timer.new(et_prop, 1, 0);
setlistener(et_prop, func(v)
{
	var fmtN = props.globals.getNode("instrumentation/clock/elapsed-time-fmt", 1);
	fmtN.setValue(_gettimefmt_(v.getValue()));
}, 0, 0);
setlistener("gear/gear[1]/wow", func(v)
{
	if (v.getBoolValue())
	{
		et_timer.stop();
	}
	else
	{
		et_timer.start()
	}
}, 0, 0);

## Format date
setlistener("sim/time/real/day", func(v)
{
	# wait one frame to avoid nil property errors
	settimer(func
	{
		var day = v.getValue();
		var month = getprop("sim/time/real/month");
		var year = getprop("sim/time/real/year");

		var date_node = props.globals.getNode("instrumentation/clock/indicated-date-string", 1);
		date_node.setValue(sprintf("%02.f %02.f", day, month));
		var year_node = props.globals.getNode("instrumentation/clock/indicated-short-year", 1);
		year_node.setValue(substr(year ~ "", 2, 4));
	}, 0);
}, 1, 0);

## Total air temperature (TAT) calculator
# formula is
#  T = S + (1.4 - 1)/2 * M^2
var update_tat = func
{
	var node = props.globals.getNode("environment/total-air-temperature-degc", 1);
	var sat = getprop("environment/temperature-degc");
	var mach = getprop("velocities/mach");
	var tat = sat + 0.2 * mach * mach;#math.pow(mach, 2);
	node.setDoubleValue(tat);
};

## Update copilot's integer properties for transmission
var update_copilot_ints = func
{
	var instruments = props.globals.getNode("instrumentation", 1);
	
	var vsi = instruments.getChild("vertical-speed-indicator", 1, 1);
	vsi.getChild("indicated-speed-fpm-int", 0, 1).setIntValue(int(vsi.getChild("indicated-speed-fpm", 0, 1).getValue()));
	
	var ra = instruments.getChild("radar-altimeter", 1, 1);
	ra.getChild("radar-altitude-ft-int", 0, 1).setIntValue(int(ra.getChild("radar-altitude-ft", 0, 1).getValue()));
};

## Spool up instruments every 5 seconds
var update_spin = func
{
	setprop("instrumentation/attitude-indicator[0]/spin", 1);
	setprop("instrumentation/attitude-indicator[2]/spin", 1);
	setprop("instrumentation/heading-indicator[0]/spin", 1);
	setprop("instrumentation/heading-indicator[1]/spin", 1);
	settimer(update_spin, 5);
};
settimer(update_spin, 2);
