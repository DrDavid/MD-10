# McDonnell Douglas MD-10
# Nasal effects
#########################

## Livery select
aircraft.livery.init("Aircraft/MD-10/Models/Liveries/" ~ getprop("sim/aero"));

## Lights
var top_beacon_light = aircraft.light.new("sim/model/lights/beacon[0]", [0.05, 4.05], "controls/lighting/beacon");
var bottom_beacon_light = aircraft.light.new("sim/model/lights/beacon[1]", [0.05, 2, 0.05, 2], "controls/lighting/beacon");

var front_strobe_light = aircraft.light.new("sim/model/lights/strobe[0]", [0.05, 2.5], "controls/lighting/strobe");
var rear_strobe_light = aircraft.light.new("sim/model/lights/strobe[1]", [0.05, 2], "controls/lighting/strobe");

setlistener("controls/lighting/landing-light-nose-switch", func(prop)
{
	var fuselage_lights = props.globals.getNode("controls/lighting/landing-light-nose[0]", 1);
	var gear_lights = props.globals.getNode("controls/lighting/landing-light-nose[1]", 1);
	var fuselage_lights_rear = props.globals.getNode("controls/lighting/landing-light-butt[0]", 1);
	var gear_lights_rear = props.globals.getNode("controls/lighting/landing-light-butt[1]", 1);

	var setting = prop.getValue();
	if (setting == 1)
	{
		fuselage_lights.setBoolValue(0);
		gear_lights.setBoolValue(1);
		fuselage_lights_rear.setBoolValue(0);
		gear_lights_rear.setBoolValue(1);
	}
	elsif (setting == 2)
	{
		fuselage_lights.setBoolValue(1);
		gear_lights.setBoolValue(1);
		fuselage_lights_rear.setBoolValue(1);
		gear_lights_rear.setBoolValue(1);
	}
	else
	{
		prop.setValue(0);
		fuselage_lights.setBoolValue(0);
		gear_lights.setBoolValue(0);
		fuselage_lights_rear.setBoolValue(0);
		gear_lights_rear.setBoolValue(0);
	}
}, 1, 1);

## Tire smoke/rain
var tiresmoke_system = aircraft.tyresmoke_system.new(0, 2, 4, 5);
aircraft.rain.init();

## Configuration switcher stuff (MD-10CF only)
if (getprop("sim/aircraft") == "MD-10CF")
{
	# Switching function
	var switch_configuration = func
	{
		var config = props.globals.getNode("sim/model/configuration");
		var enabled = props.globals.getNode("sim/model/livery/enable-configuration-switch");
		if (enabled.getBoolValue())
		{
			if (config.getValue() == "pax")
			{
				config.setValue("cargo");
			}
			else
			{
				config.setValue("pax");
				MD10.doors.cargo_main.setpos(0);
			}
		}
	};
	# If configuration switching is disabled for a particular livery, set the configuration to the livery-specified one
	setlistener("sim/model/livery/enable-configuration-switch", func(switch)
	{
		var menu_item_enabled = props.globals.getNode("sim/menubar/default/menu[100]/item[7]/enabled");
		if (!switch.getBoolValue())
		{
			setprop("sim/model/configuration", getprop("sim/model/livery/configuration"));
			menu_item_enabled.setBoolValue(0);
		}
		else
		{
			menu_item_enabled.setBoolValue(1);
		}
	}, 1, 1);
}
