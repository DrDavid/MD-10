# McDonnell Douglas MD-11
# Nasal effects
#########################

## Livery select
aircraft.livery.init("Aircraft/MD-11/Models/Liveries/");

## Lights
var top_beacon_light = aircraft.light.new("sim/model/lights/beacon[0]", [0.05, 4.05], "controls/lighting/beacon");
var bottom_beacon_light = aircraft.light.new("sim/model/lights/beacon[1]", [0.05, 2, 0.05, 2], "controls/lighting/beacon");

var front_strobe_light = aircraft.light.new("sim/model/lights/strobe[0]", [0.02, 2.5], "controls/lighting/strobe");
var rear_strobe_light = aircraft.light.new("sim/model/lights/strobe[1]", [0.02, 2], "controls/lighting/strobe");

setlistener("controls/lighting/landing-light-nose-switch", func(prop)
{
	var fuselage_lights = props.globals.getNode("controls/lighting/landing-light-nose[0]", 1);
	var gear_lights = props.globals.getNode("controls/lighting/landing-light-nose[1]", 1);
	var setting = prop.getValue();
	if (setting == 1)
	{
		fuselage_lights.setBoolValue(0);
		gear_lights.setBoolValue(1);
	}
	elsif (setting == 2)
	{
		fuselage_lights.setBoolValue(1);
		gear_lights.setBoolValue(1);
	}
	else
	{
		prop.setValue(0);
		fuselage_lights.setBoolValue(0);
		gear_lights.setBoolValue(0);
	}
}, 1, 1);
