var throttle		= 0;
var radio_alt		= 0;
var flaps			= 0;
var parkbrake		= 0;
var speed			= 0;
var reverser		= 0;
var apu_running		= 0;
var gear_down		= 0;
var gear_override	= 0;
var flap_override	= 0;
var ap_passive		= 1;
var ap_disengaged	= 0;
var rudder_trim		= 0;
var elev_trim		= 0;
var engfire			= [0,0,0,0];
var secondary_eicas = {};
var secEICAS		= {};
var pack 			= [0,0,0];

var num_lines = 18;

msgs_warning = [];
msgs_caution = [];
msgs_advisory = [];
msgs_memo = [];

props.globals.initNode("/instrumentation/weu/state/stall-speed",-100);

eicas = props.globals.initNode("/instrumentation/eicas");
eicas_msg_warning	= eicas.initNode("msg/warning"," ","STRING");
eicas_msg_caution	= eicas.initNode("msg/caution"," ","STRING");
eicas_msg_advisory	= eicas.initNode("msg/advisory"," ","STRING");
eicas_msg_memo		= eicas.initNode("msg/memo"," ","STRING");

setlistener("sim/signals/fdm-initialized", func() {
	setlistener("controls/gear/gear-down",            func { update_listener_inputs() } );
	setlistener("controls/gear/brake-parking",        func { update_listener_inputs() } );
	setlistener("controls/engines/engine/reverser",   func { update_listener_inputs() } );
	setlistener("controls/engines/engine[0]/on-fire", func(n) { engfire[0] = n.getValue(); } );
	setlistener("controls/engines/engine[1]/on-fire", func(n) { engfire[1] = n.getValue(); } );
	setlistener("controls/engines/engine[2]/on-fire", func(n) { engfire[2] = n.getValue(); } );
	setlistener("controls/flight/rudder-trim",        func { update_listener_inputs() } );
	setlistener("controls/flight/elevator-trim",      func { update_listener_inputs() } );
	setlistener("sim/freeze/replay-state",            func { update_listener_inputs() } );
	setlistener("/autopilot/autobrake/step",          func { update_listener_inputs() } );
	setlistener("/controls/pneumatic/pack-control",func { pack[0] = (getprop("/controls/pneumatic/pack-control")>0); } );
	setlistener("/controls/pneumatic/pack-control[1]",func { pack[1] = (getprop("/controls/pneumatic/pack-control[1]")>0); } );
	setlistener("/controls/pneumatic/pack-control[2]",func { pack[2] = (getprop("/controls/pneumatic/pack-control[2]")>0); } );
	
	setlistener("controls/engines/engine/throttle-lever",   func { update_throttle_input() } );

	update_listener_inputs();
	update_throttle_input();
    update_system();
    
    setprop("/instrumentation/eicas/display","ENG");
});

var update_eicas = func(warningmsgs,cautionmsgs,advisorymsgs,memomsgs) {
	var msg="";
	var spacer="";
	var line = 0;
	for(var i=0; i<size(warningmsgs); i+=1)
	{
		msg = msg ~ warningmsgs[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	eicas_msg_warning.setValue(msg);
	msg=spacer;
	for(var i=0; i<size(cautionmsgs); i+=1)
	{
		msg = msg ~ cautionmsgs[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	eicas_msg_caution.setValue(msg);
	msg=spacer;
	for(var i=0; i<size(advisorymsgs); i+=1)
	{
		msg = msg ~ advisorymsgs[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	eicas_msg_advisory.setValue(msg);
	while (line+size(memomsgs) < num_lines) {
		line+=1;
		spacer = spacer ~ "\n";
	}
	msg=spacer;
	for(var i=0; i<size(memomsgs); i+=1)
	{
		msg = msg ~ memomsgs[i] ~ "\n";
	}
	eicas_msg_memo.setValue(msg);
}
	
var takeoff_config_warnings = func {
	if ((throttle>=0.667)and
		(!reverser))
	{
		if (((flaps<0.3)or(flaps>0.7)) and (speed < getprop("/instrumentation/fmc/vspeeds/V1")))
			append(msgs_warning,">CONFIG FLAPS");
		if (parkbrake)
			append(msgs_warning,">CONFIG PARK BRK");
   }
}

var warning_messages = func {
	if (radio_alt>41000)
		append(msgs_warning,">CABIN ALTITUDE");
	if ((((radio_alt<800) and (throttle<0.1)) or (flaps>0.6)) and !gear_down)
		append(msgs_warning,">CONFIG GEAR");
	if (getprop("/gear/gear/wow") and (getprop("/controls/engines/engine[1]/throttle")>0.5 or getprop("/controls/engines/engine[2]/throttle")>0.5) and (getprop("/gear/gear[1]/steering-norm") != 0 or getprop("/gear/gear[2]/steering-norm") != 0))
		append(msgs_warning,">CONFIG GEAR CTR");
	if (getprop("controls/flight/speedbrake") != 0 and getprop("/gear/gear/wow") and (getprop("/controls/engines/engine[1]/throttle")>0.5 or getprop("/controls/engines/engine[2]/throttle")>0.5))
		append(msgs_warning,">CONFIG SPOILERS");	
	if (engfire[0] or engfire[1] or engfire[2]) {
		var msgs_fire = "FIRE ENGINE ";
		if (engfire[0])
			msgs_fire = msgs_fire~"1, ";
		if (engfire[1])
			msgs_fire = msgs_fire~"2, ";
		if (engfire[2])
			msgs_fire = msgs_fire~"3, ";
		append(msgs_warning,substr(msgs_fire,0,size(msgs_fire)-2));
	}
}

var caution_messages = func {
	if (getprop("/systems/electrical/ac-bus[0]") or getprop("/systems/electrical/ac-bus[1]") or getprop("/systems/electrical/ac-bus[2]")) {
		var msgs_ac_bus = ">ELEC AC BUS ";
		if (getprop("/systems/electrical/ac-bus[0]"))
			msgs_ac_bus = msgs_ac_bus~"1, ";
		if (getprop("/systems/electrical/ac-bus[1]"))
			msgs_ac_bus = msgs_ac_bus~"2, ";
		if (getprop("/systems/electrical/ac-bus[2]"))
			msgs_ac_bus = msgs_ac_bus~"3, ";
		append(msgs_caution,substr(msgs_ac_bus,0,size(msgs_ac_bus)-2));
	}
	if (getprop("/controls/engines/engine[0]/cutoff") or getprop("/controls/engines/engine[1]/cutoff") or getprop("/controls/engines/engine[2]/cutoff")) {
		var msgs_eng_cutoff = ">ENG ";
		if (getprop("/controls/engines/engine[0]/cutoff"))
			msgs_eng_cutoff = msgs_eng_cutoff~"1, ";
		if (getprop("/controls/engines/engine[1]/cutoff"))
			msgs_eng_cutoff = msgs_eng_cutoff~"2, ";
		if (getprop("/controls/engines/engine[2]/cutoff"))
			msgs_eng_cutoff = msgs_eng_cutoff~"3, ";
		append(msgs_caution,substr(msgs_eng_cutoff,0,size(msgs_eng_cutoff)-2)~" SHUTDOWN");
	}
	var msgs_eng_fuel_press = "FUEL PRESS ENG ";
	if (size(msgs_eng_fuel_press) > 15)
		append(msgs_caution,substr(msgs_eng_fuel_press,0,size(msgs_eng_fuel_press)-2));
	if ((getprop("/consumables/fuel/tank[1]/level-lbs") < 1985) or (getprop("/consumables/fuel/tank[2]/level-lbs") < 1985) or (getprop("/consumables/fuel/tank[3]/level-lbs") < 1985) or (getprop("/consumables/fuel/tank[4]/level-lbs") < 1985))
		append(msgs_caution,"FUEL QTY LOW");
	if ((getprop("/controls/fuel/dump-valve") == 1))
		append(msgs_caution,"FUEL JETT SYS");
	if (getprop("controls/flight/speedbrake") and ((radio_alt<800 and radio_alt>15) or flaps>0.7 or throttle>0.1))
		append(msgs_caution,">SPEEDBRAKES EXT");	
}

var advisory_messages = func {
	if ((getprop("/controls/anti-ice/engine[0]/carb-heat") or getprop("/controls/anti-ice/engine[1]/carb-heat") or getprop("/controls/anti-ice/engine[2]/carb-heat") or getprop("/controls/anti-ice/wing-heat")) and getprop("/environment/temperature-degc") > 12)
		append(msgs_advisory,">ANTI-ICE");
	if (!getprop("/controls/engines/autostart"))
		append(msgs_advisory,">AUTOSTART OFF");
	if (!getprop("/controls/electric/battery"))
		append(msgs_advisory,">BATTERY OFF");
	}
	if (!getprop("/controls/electric/generator-control[0]") or !getprop("/controls/electric/generator-control[1]") or !getprop("/controls/electric/generator-control[2]") or !getprop("/controls/electric/generator-control[3]")) {
		var msgs_elecGenOff = ">ELEC GEN OFF ";
		if (!getprop("/controls/electric/generator-control[0]"))
			msgs_elecGenOff = msgs_elecGenOff~"1, ";
		if (!getprop("/controls/electric/generator-control[1]"))
			msgs_elecGenOff = msgs_elecGenOff~"2, ";
		if (!getprop("/controls/electric/generator-control[2]"))
			msgs_elecGenOff = msgs_elecGenOff~"3, ";
		append(msgs_advisory,substr(msgs_elecGenOff,0,size(msgs_elecGenOff)-2));
	}
	if (((getprop("/consumables/fuel/tank[2]/level-lbs") <= getprop("/consumables/fuel/tank[1]/level-lbs")) or (getprop("/consumables/fuel/tank[3]/level-lbs") <= getprop("/consumables/fuel/tank[4]/level-lbs"))) and !getprop("/controls/fuel/dump-valve"))
		append(msgs_advisory,">FUEL TANK/ENG");
	if ((((getprop("/consumables/fuel/tank[2]/level-lbs") > getprop("/consumables/fuel/tank[1]/level-lbs")) or (getprop("/consumables/fuel/tank[3]/level-lbs") > getprop("/consumables/fuel/tank[4]/level-lbs"))) or getprop("/gear/gear/wow") == 1 ) and (getprop("/controls/fuel/tank[1]/x-feed") == 1) and (getprop("/controls/fuel/tank[4]/x-feed") == 1))
		append(msgs_advisory,">FUEL XFER 1+4");
	if (getprop("/systems/hydraulic/demand-pump-pressure-low[0]") == 1 or getprop("/systems/hydraulic/demand-pump-pressure-low[1]") == 1 or getprop("/systems/hydraulic/demand-pump-pressure-low[2]") == 1 or getprop("/systems/hydraulic/demand-pump-pressure-low[3]") == 1)
		append(msgs_advisory,"HYD PRESS DEM 1, 2, 3");
	if (getprop("/systems/hydraulic/engine-pump-pressure-low[0]") == 1 or getprop("/systems/hydraulic/engine-pump-pressure-low[1]") == 1 or getprop("/systems/hydraulic/engine-pump-pressure-low[2]") == 1 or getprop("/systems/hydraulic/engine-pump-pressure-low[3]") == 1)
		append(msgs_advisory,"HYD PRESS ENG 1, 2, 3");
	if (getprop("/controls/fuel/dump-valve") == 1)
		append(msgs_advisory,">JETT NOZ ON");
	if (((getprop("/consumables/fuel/tank[1]/level-lbs") != getprop("/consumables/fuel/tank[2]/level-lbs")) or (getprop("/consumables/fuel/tank[3]/level-lbs") != getprop("/consumables/fuel/tank[4]/level-lbs"))) and ((getprop("/controls/fuel/tank[1]/x-feed") != 1) or (getprop("/controls/fuel/tank[4]/x-feed") != 1)))
		append(msgs_advisory,">X FEED CONFIG");
	if (!getprop("controls/flight/yaw-damper"))
		append(msgs_advisory,">YAW DAMPER LWR, UPR");
}

var memo_messages = func {
	if (getprop("/controls/engines/con-ignition"))
		append(msgs_memo,"CON IGNITION ON");
	if (apu_running and (getprop("/engines/engine[3]/n1") > 95))
		append(msgs_memo,"APU RUNNING");
	if (parkbrake)
		append(msgs_memo,"PARK BRAKE SET");
	if (getprop("/autopilot/autobrake/step") == -1)
		append(msgs_memo,"AUTOBRAKES RTO");
	if (getprop("/autopilot/autobrake/step") > 0 and getprop("/autopilot/autobrake/step") < 4)
		append(msgs_memo,"AUTOBRAKES "~getprop("/autopilot/autobrake/step"));
	if (getprop("/controls/switches/seatbelt-sign") and getprop("/controls/switches/smoking-sign"))
		append(msgs_memo,"PASS SIGNS ON");
	else {
		if (getprop("/controls/switches/seatbelt-sign"))
			append(msgs_memo,"SEATBELTS ON");
		if (getprop("/controls/switches/smoking-sign"))
			append(msgs_memo,"NO SMOKING ON");
	}
	if (!pack[0] and !pack[1] and !pack[2])
		append(msgs_memo,"PACKS OFF");
	else {
		if (!pack[0] and !pack[1])
			append(msgs_memo,"PACKS 1+2 OFF");
		if (!pack[0] and !pack[2])
			append(msgs_memo,"PACKS 1+3 OFF");
		if (!pack[1] and !pack[2])
			append(msgs_memo,"PACKS 2+3 OFF");
		if (!pack[0] and (pack[1] and pack[2]))
			append(msgs_memo,"PACK 1 OFF");
		if (!pack[1] and (pack[0] and pack[2]))
			append(msgs_memo,"PACK 2 OFF");
		if (!pack[2] and (pack[0] and pack[1]))
			append(msgs_memo,"PACK 3 OFF");
	}
	if (getprop("/controls/pneumatic/pack-high-flow"))
		append(msgs_memo,"PACKS HIGH FLOW");
}
	
var update_listener_inputs = func() {
	# be nice to sim: some inputs rarely change. use listeners.
	enabled       = (getprop("sim/freeze/replay-state")!=1);
	reverser      = getprop("controls/engines/engine/reverser");
	gear_down     = getprop("controls/gear/gear-down");
	parkbrake     = getprop("controls/gear/brake-parking");
	apu_running   = getprop("engines/engine[3]/running");
	rudder_trim   = getprop("controls/flight/rudder-trim");
	elev_trim     = getprop("controls/flight/elevator-trim");
}

var update_throttle_input = func() {
	throttle = getprop("controls/engines/engine/throttle-lever");
}
	
var update_system = func() {
	msgs_warning   = [];
	msgs_caution = [];
	msgs_advisory = [];
	msgs_memo    = [];
	
	radio_alt	= getprop("position/altitude-agl-ft")-16.5;
	speed		= getprop("velocities/airspeed-kt");
	
	takeoff_config_warnings();
	warning_messages();
	caution_messages();
	advisory_messages();
	memo_messages();
	
	update_eicas(msgs_warning,msgs_caution,msgs_advisory,msgs_memo);
	
	settimer(update_system,0.5);
}

var eicasCreated = 0;

setlistener("/instrumentation/eicas/display", func {
	if (eicasCreated == 1)
		secondary_eicas.del();
	secondary_eicas = canvas.new({
		"name": "EICASsecondary",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	secondary_eicas.addPlacement({"node": "Lower-EICAS-Screen"});
	var display = getprop("/instrumentation/eicas/display");
	var group = secondary_eicas.createGroup();
	if (display == "DRS")
		secEICAS = canvas_doors.new(group);
	elsif (display == "ELEC")
		secEICAS = canvas_elec.new(group);
	elsif (display == "ENG")
		secEICAS = canvas_eng.new(group);
	elsif (display == "FUEL")
		secEICAS = canvas_fuel.new(group);
	elsif (display == "GEAR")
		secEICAS = canvas_gear.new(group);
	elsif (display == "STAT")
		secEICAS = canvas_stat.new(group);
	secEICAS.update();
	eicasCreated = 1;
});

var showEicas = func() {
	var dlg = canvas.Window.new([400, 400], "dialog");
	dlg.setCanvas(secondary_eicas);
}
