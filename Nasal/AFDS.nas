#############################################################################
# 777 Autopilot Flight Director System
# Syd Adams
#
# speed modes: THR,THR REF, IDLE,HOLD,SPD;
# roll modes : TO/GA,HDG SEL,HDG HOLD, LNAV,LOC,ROLLOUT,TRK SEL, TRK HOLD,ATT;
# pitch modes: TO/GA,ALT,V/S,VNAV PTH,VNAV SPD,VNAV ALT,G/S,FLARE,FLCH SPD,FPA;
# FPA range  : -9.9 ~ 9.9 degrees
# VS range   : -8000 ~ 6000
# ALT range  : 0 ~ 50,000
# KIAS range : 100 ~ 399
# MACH range : 0.40 ~ 0.95
#
#############################################################################

#Usage : var afds = AFDS.new();

var copilot = func(msg) { setprop("sim/messages/copilot",msg);}

var AFDS = {
	new : func{
		var m = {parents:[AFDS]};

		m.spd_list=["","THR","THR REF","HOLD","IDLE","THRUST"];

		m.roll_list=["","HDG SEL","HEADING","LNAV","LOC","ROLLOUT",
		"TRK SEL","TRK HOLD","ATT","TO/GA"];

		m.pitch_list=["","ALT","V/S","VNAV PTH","VNAV THRUST",
		"VNAV ALT","G/S","FLARE","FLCH THRUST","FPA","TO/GA"];

		m.step=0;
		m.descent_step=0;
		m.heading_change_rate = 0;
		m.optimal_alt = 0;
		m.intervention_alt = 0;
		m.altitude_restriction = -9999.99;
		m.altitude_alert_from_out = 0;
		m.altitude_alert_from_in = 0;
		m.top_of_descent = 0;
		m.vorient = 0;

		m.heading_reference=props.globals.initNode("systems/navigation/hdgref/reference",0,"BOOL");
		m.crab_angle=props.globals.initNode("orientation/crab-angle", 0, "DOUBLE");
		m.crab_angle_total=props.globals.initNode("orientation/crab-angle-total", 0, "DOUBLE");
		m.rwy_align_limit=props.globals.initNode("orientation/rwy-align-limit", 0, "DOUBLE");
		m.AFDS_node = props.globals.getNode("instrumentation/afds",1);
		m.AFDS_inputs = m.AFDS_node.getNode("inputs",1);
		m.AFDS_apmodes = m.AFDS_node.getNode("ap-modes",1);
		m.AFDS_settings = m.AFDS_node.getNode("settings",1);
		m.AP_settings = props.globals.getNode("autopilot/settings",1);

		m.AP = m.AFDS_inputs.initNode("AP",0,"BOOL");
		m.AP_disengaged = m.AFDS_inputs.initNode("AP-disengage",0,"BOOL");
		m.AP_passive = props.globals.initNode("autopilot/locks/passive-mode",1,"BOOL");
		m.AP_pitch_engaged = props.globals.initNode("autopilot/locks/pitch-engaged",1,"BOOL");
		m.AP_roll_engaged = props.globals.initNode("autopilot/locks/roll-engaged",1,"BOOL");

		m.FMC = props.globals.getNode("autopilot/route-manager", 1);
		m.FMC_cruise_alt = m.FMC.initNode("cruise/altitude-ft",10000,"DOUBLE");
		m.FMC_cruise_ias = m.FMC.initNode("cruise/speed-kts",320,"DOUBLE");
		m.FMC_cruise_mach = m.FMC.initNode("cruise/speed-mach",0.840,"DOUBLE");
		m.FMC_descent_ias = m.FMC.initNode("descent/speed-kts",280,"DOUBLE");
		m.FMC_descent_mach = m.FMC.initNode("descent/speed-mach",0.780,"DOUBLE");
		m.FMC_active = m.FMC.initNode("active",0,"BOOL");
		m.FMC_current_wp = m.FMC.initNode("current-wp",0,"INT");
		m.FMC_destination_ils = m.FMC.initNode("destination-ils",0,"BOOL");
		m.FMC_landing_rwy_elevation = m.FMC.initNode("landing-rwy-elevation",0,"DOUBLE");

		m.FD = m.AFDS_inputs.initNode("FD",0,"BOOL");
		m.at1 = m.AFDS_inputs.initNode("at-armed[0]",0,"BOOL");
		m.at2 = m.AFDS_inputs.initNode("at-armed[1]",0,"BOOL");
		m.alt_knob = m.AFDS_inputs.initNode("alt-knob",0,"BOOL");
		m.autothrottle_mode = m.AFDS_inputs.initNode("autothrottle-index",0,"INT");
		m.lateral_mode = m.AFDS_inputs.initNode("lateral-index",0,"INT");
		m.vertical_mode = m.AFDS_inputs.initNode("vertical-index",0,"INT");
		m.gs_armed = m.AFDS_inputs.initNode("gs-armed",0,"BOOL");
		m.loc_armed = m.AFDS_inputs.initNode("loc-armed",0,"BOOL");
		m.vor_armed = m.AFDS_inputs.initNode("vor-armed",0,"BOOL");
		m.lnav_armed = m.AFDS_inputs.initNode("lnav-armed",0,"BOOL");
		m.vnav_armed = m.AFDS_inputs.initNode("vnav-armed",0,"BOOL");
		m.rollout_armed = m.AFDS_inputs.initNode("rollout-armed",0,"BOOL");
		m.flare_armed = m.AFDS_inputs.initNode("flare-armed",0,"BOOL");
		m.ias_mach_selected = m.AFDS_inputs.initNode("ias-mach-selected",0,"BOOL");
		m.hdg_trk_selected = m.AFDS_inputs.initNode("hdg-trk-selected",0,"BOOL");
		m.vs_fpa_selected = m.AFDS_inputs.initNode("vs-fpa-selected",0,"BOOL");
		m.bank_switch = m.AFDS_inputs.initNode("bank-limit-switch",0,"INT");
		m.vnav_path_mode = m.AFDS_inputs.initNode("vnav-path-mode",0,"INT");
		m.vnav_mcp_reset = m.AFDS_inputs.initNode("vnav-mcp-reset",0,"BOOL");
		m.vnav_descent = m.AFDS_inputs.initNode("vnav-descent",0,"BOOL");
		m.climb_continuous = m.AFDS_inputs.initNode("climb-continuous",0,"BOOL");
		m.indicated_vs_fpm = m.AFDS_inputs.initNode("indicated-vs-fpm",0,"DOUBLE");
		m.estimated_time_arrival = m.AFDS_inputs.initNode("estimated-time-arrival",0,"INT");
		m.remaining_distance = m.AFDS_inputs.initNode("remaining-distance",0,"DOUBLE");
		m.reference_deg = m.AFDS_inputs.initNode("reference-deg",0,"DOUBLE");

		m.ias_setting = m.AP_settings.initNode("target-speed-kt",250);# 100 - 399 #
		m.mach_setting = m.AP_settings.initNode("target-speed-mach",0.40);# 0.40 - 0.95 #
		m.vs_setting = m.AP_settings.initNode("vertical-speed-fpm",0); # -8000 to +6000 #
		m.hdg_setting = m.AP_settings.initNode("heading-bug-deg",360,"INT"); # 1 to 360
		m.hdg_setting_last = m.AP_settings.initNode("heading-bug-last",360,"INT"); # 1 to 360
		m.hdg_setting_active = m.AP_settings.initNode("heading-bug-active",0,"BOOL");
		m.fpa_setting = m.AP_settings.initNode("flight-path-angle",0); # -9.9 to 9.9 #
		m.alt_setting = m.AP_settings.initNode("counter-set-altitude-ft",10000,"DOUBLE");
		m.alt_setting_FL = m.AP_settings.initNode("counter-set-altitude-FL",10,"INT");
		m.alt_setting_100 = m.AP_settings.initNode("counter-set-altitude-100",000,"INT");
		m.target_alt = m.AP_settings.initNode("actual-target-altitude-ft",10000,"DOUBLE");
		m.radio_alt_ind = m.AP_settings.initNode("radio-altimeter-indication",000,"INT");
		m.pfd_mach_ind = m.AP_settings.initNode("pfd-mach-indication",000,"INT");
		m.pfd_mach_target = m.AP_settings.initNode("pfd-mach-target-indication",000,"INT");
		m.auto_brake_setting = m.AP_settings.initNode("autobrake",0.000,"DOUBLE");
		m.flare_constant_setting = m.AP_settings.initNode("flare-constant",0.000,"DOUBLE");
		m.thrust_lmt = m.AP_settings.initNode("thrust-lmt",1,"DOUBLE");
		m.flight_idle = m.AP_settings.initNode("flight-idle",0,"DOUBLE");

		m.vs_display = m.AFDS_settings.initNode("vs-display",0);
		m.fpa_display = m.AFDS_settings.initNode("fpa-display",0);
		m.bank_min = m.AFDS_settings.initNode("bank-min",-25);
		m.bank_max = m.AFDS_settings.initNode("bank-max",25);
		m.pitch_min = m.AFDS_settings.initNode("pitch-min",-10);
		m.pitch_max = m.AFDS_settings.initNode("pitch-max",15);
		m.auto_popup = m.AFDS_settings.initNode("auto-pop-up",0,"BOOL");
		m.heading = m.AFDS_settings.initNode("heading",360,"INT");
		m.manual_intervention = m.AFDS_settings.initNode("manual-intervention",0,"BOOL");

		m.AP_roll_mode = m.AFDS_apmodes.initNode("roll-mode","TO/GA");
		m.AP_roll_arm = m.AFDS_apmodes.initNode("roll-mode-arm"," ");
		m.AP_pitch_mode = m.AFDS_apmodes.initNode("pitch-mode","TO/GA");
		m.AP_pitch_arm = m.AFDS_apmodes.initNode("pitch-mode-arm"," ");
		m.AP_speed_mode = m.AFDS_apmodes.initNode("speed-mode","");
		m.AP_annun = m.AFDS_apmodes.initNode("mode-annunciator"," ");

		m.APl = setlistener(m.AP, func m.setAP(),0,0);
		m.APdisl = setlistener(m.AP_disengaged, func m.setAP(),0,0);
		m.Lbank = setlistener(m.bank_switch, func m.setbank(),0,0);
		m.LTMode = setlistener(m.autothrottle_mode, func m.updateATMode(),0,0);
		m.WpChanged = setlistener(m.FMC.getNode("wp/id",1), func m.wpChanged(),0,0);
		m.RmDisabled = setlistener(m.FMC.getNode("active",1), func m.wpChanged(),0,0);
        
        
        m.NDSymbols = props.globals.getNode("autopilot/route-manager/vnav", 1);
		setprop("autopilot/internal/waypoint-bearing-error-deg", 0);
		return m;
	},

####  Inputs   ####
###################
	input : func(mode,btn)
	{
		if(getprop("systems/electrical/outputs/avionics"))
		{
			var current_alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
			if(mode==0)
			{
				# horizontal AP controls
				if(btn == 1)		# Heading Sel button
				{
					if(getprop("position/gear-agl-ft") < 50)
					{
						btn = me.lateral_mode.getValue();
					}
				}
				elsif(btn == 2)		# Heading Hold button
				{
					# set target to current heading
					var tgtHdg = me.heading.getValue();
					me.hdg_setting.setValue(tgtHdg);
					if(getprop("position/gear-agl-ft") < 50)
					{
						btn = me.lateral_mode.getValue();
					}
					else
					{
						if(me.hdg_trk_selected.getValue())
						{
							btn = 6;    # TRK SEL
						}
						else
						{
							btn = 1;    # HDG SEL
						}
					}
				}
				elsif(btn==3)		# LNAV button
				{
					if(!me.FMC_active.getValue() or
						me.FMC_current_wp.getValue()<0 or
						(getprop("autopilot/route-manager/wp/id")==""))
					{
						# Oops, route manager isn't active. Keep current mode.
						btn = me.lateral_mode.getValue();
						copilot("Captain, LNAV doesn't engage. We forgot to program or activate the route manager!");
					}
					else
					{
						if(me.lateral_mode.getValue() == 3)		# Current mode is LNAV
						{
							# set target to current heading
							var tgtHdg = me.heading.getValue();
							me.hdg_setting.setValue(tgtHdg);
							btn = 1;	# Heading sel
						}
						elsif(me.lnav_armed.getValue())
						{	# LNAV armed then disarm
							me.lnav_armed.setValue(0);
							btn = me.lateral_mode.getValue();
						}
						else
						{	# LNAV arm
							me.lnav_armed.setValue(1);
							btn = me.lateral_mode.getValue();
						}
					}
				}
				me.lateral_mode.setValue(btn);
			}
			elsif(mode==1)
			{
				# vertical AP controls
				if (btn==1)
				{
					# hold current altitude
					if(me.AP.getValue() or me.FD.getValue())
					{
						var alt = int((current_alt+50)/100)*100;
						me.target_alt.setValue(alt);
						me.autothrottle_mode.setValue(5);	# A/T THRUST
					}
					else
					{
						btn = 0;
					}
				}
				if(btn==2)
				{
					# hold current vertical speed
					var vs = getprop("velocities/vertical-speed-fps") * 60;
					vs = int(vs/100)*100;
					if (vs<-8000) vs = -8000;
					if (vs>6000) vs = 6000;
					me.vs_setting.setValue(vs);
					if(vs == 0)
					{
						me.target_alt.setValue(current_alt);
					}
					me.autothrottle_mode.setValue(5);	# A/T THRUST
				}
				if(btn==4)
				{
					# Altitude intervention
					if(me.alt_setting.getValue() == me.intervention_alt)
					{
						# clear current restriction
						var temp_wpt = me.FMC_current_wp.getValue() + 1;
						me.altitude_restriction = getprop("autopilot/route-manager/route/wp["~temp_wpt~"]/altitude-ft");
						if(me.altitude_restriction > 0)
						{
							me.altitude_restriction = int((me.altitude_restriction + 50) / 100 )* 100;
						}
					}
					else
					{
						me.intervention_alt = me.alt_setting.getValue();
					}
					btn = me.vertical_mode.getValue();
				}
				elsif(btn == 255)
				{
					if(me.vs_setting.getValue() == 0)
					{
						me.target_alt.setValue(current_alt);
					}
					else
					{
						me.target_alt.setValue(me.alt_setting.getValue());
					}
					btn = 2;
				}
				if(btn==5)		# VNAV
				{
					if (!me.FMC_active.getValue() or
						me.FMC_current_wp.getValue()<0 or
						(getprop("autopilot/route-manager/wp/id")==""))
					{
						# Oops, route manager isn't active. Keep current mode.
						btn = me.vertical_mode.getValue();
						copilot("Captain, VNAV doesn't engage. We forgot to program or activate the route manager!");
					}
					else
					{
						var vnav_mode = me.vertical_mode.getValue();
						if(vnav_mode == 3)			# Current mode is VNAV PTH
						{
						}
						elsif(vnav_mode == 4)		# Current mode is VNAV THRUST
						{
						}
						elsif(vnav_mode == 5)		# Current mode is VNAV ALT
						{
						}
						elsif(me.vnav_armed.getValue())
						{	# VNAV armed then disarm
							me.vnav_armed.setValue(0);
							btn = vnav_mode;
						}
						else
						{	# VNAV arm
							me.vnav_armed.setValue(1);
							me.vnav_path_mode.setValue(0);		# VNAV PTH HOLD
							me.vnav_mcp_reset.setValue(0);
							me.vnav_descent.setValue(0);
							btn = vnav_mode;
							me.descent_step = 0;
							me.manual_intervention.setValue(0);
						}
					}
				}
				if(btn==8)		# FLCH THRUST
				{
					# change flight level
					if(((current_alt
						- getprop("autopilot/internal/airport-height")) < 400)
						or (me.at1.getValue() == 0) or (me.at2.getValue() == 0))
					{
						btn = 0;
					}
					elsif(current_alt < me.alt_setting.getValue())
					{
						me.autothrottle_mode.setValue(1);	# A/T THR
					}
					else
					{
						me.autothrottle_mode.setValue(4);	# A/T IDLE
					}
					setprop("autopilot/internal/current-pitch-deg", getprop("orientation/pitch-deg"));
				}
				me.vertical_mode.setValue(btn);
			}
			elsif(mode == 2)
			{
				# throttle AP controls
				if(me.autothrottle_mode.getValue() != 0
					or (me.at1.getValue() == 0) or (me.at2.getValue() == 0))
				{
					btn = 0;
				}
				elsif(btn == 2)		# TOGA
				{
					if((getprop("instrumentation/airspeed-indicator/indicated-speed-kt") > 50)
						or (getprop("controls/flight/flaps") == 0))
					{
						btn = 0;
					}
					me.auto_popup.setValue(1);
				}
				elsif((current_alt
						- getprop("autopilot/internal/airport-height")) < 400)
				{
					btn=0;
					copilot("Captain, auto-throttle won't engage below 400ft.");
				}
				if(btn == 2)
				{
					setprop("autopilot/locks/takeoff-mode", 1);
				}
				me.autothrottle_mode.setValue(btn);
			}
			elsif(mode==3)	#FD, LOC or G/S button
			{
				if(btn == 2)	# FD button toggle
				{
					if(me.FD.getValue())
					{
						if(getprop("gear/gear[1]/wow"))
						{
							me.lateral_mode.setValue(9);		# TOGA
							me.vertical_mode.setValue(10);		# TOGA
						}
					}
					else
					{
						if(!me.AP.getValue())
						{
							me.lateral_mode.setValue(0);		# Clear
							me.vertical_mode.setValue(0);		# Clear
							setprop("autopilot/settings/roll-transition", 0);
							setprop("autopilot/settings/pitch-transition", 0);
						}
					}
				}
				elsif(btn == 3)	# AP button toggle
				{
					if(!me.AP.getValue())
					{
						me.rollout_armed.setValue(0);
						me.flare_armed.setValue(0);
						me.loc_armed.setValue(0);			# Disarm
						me.gs_armed.setValue(0);			# Disarm
						if(!me.FD.getValue())
						{
							me.lateral_mode.setValue(0);		# NO MODE
							me.vertical_mode.setValue(0);		# NO MODE
							setprop("autopilot/settings/roll-transition", 0);
							setprop("autopilot/settings/pitch-transition", 0);
						}
						else
						{
							if(me.hdg_trk_selected.getValue())
							{
								me.lateral_mode.setValue(7);	# TRK HOLD
							}
							else
							{
								me.lateral_mode.setValue(2);	# HDG HOLD
							}
							me.vertical_mode.setValue(1);		# ALT
						}
					}
					else
					{
						if(!me.FD.getValue()
							and !me.lnav_armed.getValue()
							and (me.lateral_mode.getValue() != 3))
						{
							me.lateral_mode.setValue(8);		# ATT
						}
						if(!me.vnav_armed.getValue()
							and (me.vertical_mode.getValue() == 0))
						{
							# hold current vertical speed
							var vs = getprop("velocities/vertical-speed-fps") * 60;
							vs = int(vs/100)*100;
							if (vs<-8000) vs = -8000;
							if (vs>6000) vs = 6000;
							me.vs_setting.setValue(vs);
							if(vs == 0)
							{
								me.target_alt.setValue(current_alt);
							}
							else
							{
								me.target_alt.setValue(me.alt_setting.getValue());
							}
							me.vertical_mode.setValue(2);		# V/S
						}
					}
				}
				else
				{
					var llocmode = me.lateral_mode.getValue();
					var lgsmode = me.vertical_mode.getValue();
					if(btn==0)
					{
						if(me.loc_armed.getValue())			# LOC armed but not captured yet
						{
							if(me.gs_armed.getValue())			# GS armed but not captured yet
							{
								me.gs_armed.setValue(0);
							}
							me.loc_armed.setValue(0);
						}
						elsif(llocmode == 4)		# Alrady in LOC mode
						{
							if(me.gs_armed.getValue())
							{
								me.gs_armed.setValue(0);
							}
							elsif((lgsmode != 6)
								and (getprop("position/gear-agl-ft") > 1500))
							{
								me.lateral_mode.setValue(8);		# Default roll mode (ATT)
							}
						}
						elsif(me.loc_armed.getValue())			# LOC armed but not captured yet
						{
							me.loc_armed.setValue(0);			# Disarm
						}
						else
						{
							me.loc_armed.setValue(1);			# LOC arm
						}
					}
					elsif (btn==1)	#APP button
					{
						if((llocmode == 4)	# Already in LOC mode
								and (me.gs_armed.getValue(1)		# GS armed
									or (lgsmode == 6))
								and (getprop("position/gear-agl-ft") > 1500))
						{
							me.lateral_mode.setValue(8);	# Default roll mode (ATT)
							me.vertical_mode.setValue(2);	# Default pich mode (V/S)
							me.gs_armed.setValue(0);		# Disarm
						}
						elsif(me.loc_armed.getValue())		# loc armed but not captured yet
						{
							me.gs_armed.setValue(0);		# Disarm
							me.loc_armed.setValue(0);		# Disarm
						}
						else
						{
							me.gs_armed.setValue(1);		# G/S arm
							me.loc_armed.setValue(1);		# LOC arm
						}
					}
				}
			}
			elsif(mode==4)	#Other (HDG REF button, TRK-HDG)
			{
				if(btn==0)
				{
					me.referenceChange();
					me.hdg_setting.setValue(me.heading.getValue());
					if(me.hdg_trk_selected.getValue())
					{
						if((me.lateral_mode.getValue() == 1)
							or (me.lateral_mode.getValue() == 2))
						{
							me.lateral_mode.setValue(6);	# TRK SEL
						}
					}
					else
					{
						if((me.lateral_mode.getValue() == 6)
							or (me.lateral_mode.getValue() == 7))
						{
							me.lateral_mode.setValue(1);	# HDG SEL
						}
					}
				}
			}
		}
	},
###################
	setAP : func{
		if(me.heading.getValue() == nil)
		{
			me.heading.setValue(getprop("sim/presets/heading-deg"));
		}
		var output = 1-me.AP.getValue();
		var disabled = me.AP_disengaged.getValue();
		if((output==0)and(getprop("position/gear-agl-ft")<200))
		{
			disabled = 1;
			copilot("Captain, autopilot won't engage below 200ft.");
		}
		if((disabled)and(output==0)){output = 1;me.AP.setValue(0);}
		if (output==1)
		{
			var msg="";
			var msg2="";
			var msg3="";
			if (abs(getprop("controls/flight/rudder-trim"))   > 0.04) msg  = "rudder";
			if (abs(getprop("controls/flight/elevator-trim")) > 0.04) msg2 = "pitch";
			if (abs(getprop("controls/flight/aileron-trim"))  > 0.04) msg3 = "aileron";
			if (msg ~ msg2 ~ msg3 != "")
			{
				if ((msg != "")and(msg2!=""))
					msg = msg ~ ", " ~ msg2;
				else
					msg = msg ~ msg2;
				if ((msg != "")and(msg3!=""))
					msg = msg ~ " and " ~ msg3;
				else
					msg = msg ~ msg3;
				copilot("Captain, autopilot disengaged. Careful, check " ~ msg ~ " trim!");
			}
			me.rollout_armed.setValue(0);
			me.flare_armed.setValue(0);
			me.loc_armed.setValue(0);			# Disarm
			me.gs_armed.setValue(0);			# Disarm
			if(!me.FD.getValue())
			{
				me.lateral_mode.setValue(0);		# NO MODE
				me.vertical_mode.setValue(0);		# NO MODE
				setprop("autopilot/settings/roll-transition", 0);
				setprop("autopilot/settings/pitch-transition", 0);
			}
			else
			{
				if(me.lateral_mode.getValue() == 0)
				{
					me.lateral_mode.setValue(2);		# HDG HOLD
				}
				if(me.vertical_mode.getValue() == 0)
				{
					me.vertical_mode.setValue(1);		# ALT
				}
			}
		}
		else
		{
			if(!me.FD.getValue()
				and !me.lnav_armed.getValue()
				and (me.lateral_mode.getValue() != 3))
			{
				var current_bank = getprop("orientation/roll-deg");
				me.lateral_mode.setValue(8);		# ATT
			}
			if(!me.vnav_armed.getValue()
				and (me.vertical_mode.getValue() == 0))
			{
				# hold current vertical speed
				var vs = getprop("velocities/vertical-speed-fps") * 60;
				vs = int(vs/100)*100;
				if (vs<-8000) vs = -8000;
				if (vs>6000) vs = 6000;
				me.vs_setting.setValue(vs);
				if(vs == 0)
				{
					me.target_alt.setValue(getprop("instrumentation/altimeter/indicated-altitude-ft"));
				}
				else
				{
					me.target_alt.setValue(me.alt_setting.getValue());
				}
				me.vertical_mode.setValue(2);		# V/S
			}
		}
	},
###################
	setbank : func{
		var banklimit = me.bank_switch.getValue();
		var lmt = 25;
		if(banklimit>0) {lmt = banklimit * 5};
		me.bank_max.setValue(lmt);
		lmt = -1 * lmt;
		me.bank_min.setValue(lmt);
	},
###################
	referenceChange : func()
	{
		# Heading reference selection
		if(getprop("systems/navigation/hdgref/button")
				or (abs(getprop("position/latitude-deg")) > 82.0))
		{
			me.heading_reference.setValue(1);
		}
		else
		{
			me.heading_reference.setValue(0);
		}
		setprop("instrumentation/efis/mfd/true-north", me.heading_reference.getValue());
		setprop("instrumentation/efis[1]/mfd/true-north", me.heading_reference.getValue());
		if(getprop("velocities/groundspeed-kt") > 5)
		{
			vheading = (getprop("orientation/heading-deg") - getprop("orientation/track-deg"));
			if(vheading < -180) vheading +=360;
			if(vheading > 180) vheading +=-360;
			if(me.hdg_trk_selected.getValue())
			{
				setprop("autopilot/internal/crab-angle-hdg", vheading);
				setprop("autopilot/internal/crab-angle-trk", 0);
			}
			else
			{
				setprop("autopilot/internal/crab-angle-trk", vheading);
				setprop("autopilot/internal/crab-angle-hdg", 0);
			}
		}
		else
		{
			setprop("autopilot/internal/crab-angle-hdg", 0);
			setprop("autopilot/internal/crab-angle-trk", 0);
		}
		if(me.heading_reference.getValue())
		{
			if((me.hdg_trk_selected.getValue())
				and (getprop("velocities/groundspeed-kt") > 5))
			{
				vheading = getprop("orientation/track-deg");
			}
			else
			{
				vheading = getprop("orientation/heading-deg");
			}
			me.vorient = 0;
		}
		else
		{
			if((me.hdg_trk_selected.getValue())
				and (getprop("velocities/groundspeed-kt") > 5))
			{
				vheading = getprop("orientation/track-magnetic-deg");
			}
			else
			{
				vheading = getprop("orientation/heading-magnetic-deg");
			}
			me.vorient = getprop("environment/magnetic-variation-deg");
		}
		me.reference_deg.setValue(vheading);
		# VOR, ADF direction calculation
		setprop("instrumentation/efis/mfd/lvordirection", (getprop("instrumentation/nav/heading-deg") - vheading - me.vorient));
		setprop("instrumentation/efis/mfd/rvordirection", (getprop("instrumentation/nav[1]/heading-deg") - vheading - me.vorient));
		setprop("instrumentation/efis/mfd/ladfdirection", (getprop("instrumentation/adf/indicated-bearing-deg")
					+ getprop("autopilot/internal/crab-angle-hdg")));
		setprop("instrumentation/efis/mfd/radfdirection", (getprop("instrumentation/adf[1]/indicated-bearing-deg")
					+ getprop("autopilot/internal/crab-angle-hdg")));
		# Wind direction and bearing calculation
		setprop("instrumentation/efis/mfd/winddirection", (getprop("environment/wind-from-heading-deg") - vheading - me.vorient));
		vheading = int(vheading + 0.5);
		if(vheading < 0.5)
		{
			vheading += 360;
		}
		me.heading.setValue(vheading);
		vheading = (getprop("environment/wind-from-heading-deg") - me.vorient);
		vheading = int(vheading + 0.5);
		if(vheading < 0.5)
		{
			vheading += 360;
		}
		setprop("instrumentation/efis/mfd/windbearing", vheading);
	},
	
###################
	updateATMode : func()
	{
		var idx = me.autothrottle_mode.getValue();
		if((me.AP_speed_mode.getValue() != me.spd_list[idx])
				and (idx > 0))
		{
			setprop("autopilot/settings/speed-transition", 1);
			settimer(func
			{
				setprop("autopilot/settings/speed-transition", 0);
			}, 10);
		}
		me.AP_speed_mode.setValue(me.spd_list[idx]);
	},
#################
	wpChanged : func{
		if((getprop("autopilot/route-manager/wp/id")=="") or
			!me.FMC_active.getValue() and
			(me.lateral_mode.getValue() == 3) and
			me.AP.getValue())
		{
			# LNAV active, but route manager is disabled now => switch to HDG HOLD (current heading)
			me.input(0,2);
		}
	},
#################
	ap_update : func{
		var Vcal = func(M)
		{
			var p = getprop("environment/pressure-inhg") * 3386.388640341;
			var pt = p * math.pow(1 + 0.2 * M*M,3.5);
			var Vc =  math.sqrt((math.pow((pt-p)/101325+1,0.285714286) -1 ) * 7 * 101325 /1.225) / 0.5144;
			return (Vc);
		}
		var current_alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
		var VS = getprop("velocities/vertical-speed-fps");
		var TAS = getprop("instrumentation/airspeed-indicator/true-speed-kt") * KT2FPS; # keeping TAS as fps
		me.indicated_vs_fpm.setValue(int((abs(VS) * 60 + 50) / 100) * 100);
		if(getprop("instrumentation/airspeed-indicator/indicated-speed-kt") < 0)
		{
			setprop("instrumentation/airspeed-indicator/indicated-speed-kt", 0);
		}
		# This value is used for displaying negative altitude 
		if(current_alt < 0)
		{
			setprop("instrumentation/altimeter/indicator-altitude-ft", abs(current_alt) + 90000);
		}
		else
		{
			setprop("instrumentation/altimeter/indicator-altitude-ft", current_alt);
		}
		if(TAS < 10) TAS = 10;
		if(VS < -200) VS=-200;
		if (abs(VS/TAS)<=1)
		{
			var FPangle = math.asin(VS/TAS);
			FPangle *=90;
			setprop("autopilot/internal/fpa",FPangle);
		}
		var msg = " ";
		if(me.FD.getValue())
		{
			msg="FLT DIR";
		}
		if(me.AP.getValue())
		{
			msg="AP1";
			if(me.rollout_armed.getValue())
			{
				msg="LAND 3";
			}
		}
		if(msg == " ")
		{
			setprop("autopilot/settings/autopilot-transition", 0);
		}
		elsif(me.AP_annun.getValue() != msg)
		{
			setprop("autopilot/settings/autopilot-transition", 1);
			settimer(func
			{
				setprop("autopilot/settings/autopilot-transition", 0);
			}, 10);
		}
		me.AP_annun.setValue(msg);
		var tmp = abs(me.vs_setting.getValue());
		me.vs_display.setValue(tmp);
		tmp = abs(me.fpa_setting.getValue());
		me.fpa_display.setValue(tmp);
		msg = "";
		# Heading reference selection
		me.referenceChange();
		# Heading bug position calculation
		var hdgoffset = 0;
		hdgoffset = (me.hdg_setting.getValue()-me.reference_deg.getValue());
		if(hdgoffset < -180) hdgoffset +=360;
		if(hdgoffset > 180) hdgoffset +=-360;
		setprop("autopilot/internal/heading-bug-error-deg",hdgoffset);
		# Calculation of localizer pointer
		var deflection = getprop("instrumentation/nav/heading-needle-deflection-norm");
		if((abs(deflection) < 0.5233) and (getprop("instrumentation/nav/signal-quality-norm") > 0.99))
		{
			setprop("autopilot/internal/presision-loc", 1);
  				setprop("instrumentation/nav/heading-needle-deflection-ptr", (deflection * 1.728));
		}
		else
		{
			setprop("autopilot/internal/presision-loc", 0);
			setprop("instrumentation/nav/heading-needle-deflection-ptr", deflection);
		}

		if(me.step==0){ ### glideslope armed ?###
			var gear_agl_ft = getprop("position/gear-agl-ft");
			if(gear_agl_ft > 500)
			{
				gear_agl_ft = int(gear_agl_ft / 20) * 20; 
			}
			elsif(gear_agl_ft > 100)
			{
				gear_agl_ft = int(gear_agl_ft / 10) * 10; 
			}
			me.radio_alt_ind.setValue(gear_agl_ft); 
			msg="";
			if(me.gs_armed.getValue())
			{
				msg="G/S";
				if(me.lateral_mode.getValue() == 4)	#LOC already captured
				{
					var vradials = (getprop("instrumentation/nav[0]/radials/target-radial-deg")
							- getprop("orientation/heading-deg"));
					if(vradials < -180) vradials += 360;
					elsif(vradials >= 180) vradials -= 360;
					if(abs(vradials) < 80)
					{
						var gsdefl = getprop("instrumentation/nav/gs-needle-deflection-deg");
						var gsrange = getprop("instrumentation/nav/gs-in-range");
						if ((gsdefl< 0.1 and gsdefl>-0.1)and
							gsrange)
						{
							me.vertical_mode.setValue(6);
							me.gs_armed.setValue(0);
						}
					}
				}
			}
			elsif(me.flare_armed.getValue())
			{
				msg="FLARE";
			}
			elsif(me.vnav_armed.getValue())
			{
				msg = "VNAV";
			}
			me.AP_pitch_arm.setValue(msg);

		}elsif(me.step==1){ ### localizer armed ? ###
			msg = "";
			if(me.loc_armed.getValue())
			{
				msg = "LOC";
				if (getprop("instrumentation/nav/in-range"))
				{
					if(!getprop("instrumentation/nav/nav-loc"))
					{
						var vheading = getprop("instrumentation/nav/radials/selected-deg");
						var vvor = getprop("instrumentation/nav/heading-deg");
						var vdist = getprop("instrumentation/nav/nav-distance");
						var vheading = getprop("orientation/heading-deg");
						var vspeed = getprop("instrumentation/airspeed-indicator/indicated-mach");
						var deg_to_rad = math.pi / 180;
						var vdiff = abs(vheading - vvor + me.vorient);
						vdiff = abs(vdist * math.sin(vdiff * deg_to_rad));
						var vlim = vspeed / 0.3 * 1300 * abs(vheading - vheading) / 45 ;
						if(vdiff < vlim)
						{
							me.lateral_mode.setValue(4);
							me.loc_armed.setValue(0);
						}
					}
					else
					{
						var vradials = (getprop("instrumentation/nav[0]/radials/target-radial-deg")
								- getprop("orientation/heading-deg"));
						if(vradials < -180) vradials += 360;
						elsif(vradials >= 180) vradials -= 360;
						if(abs(vradials) < 120)
						{
							var hddefl = getprop("instrumentation/nav/heading-needle-deflection");
							if(abs(hddefl) < 9.9)
							{
								me.lateral_mode.setValue(4);
								me.loc_armed.setValue(0);
								vradials = getprop("instrumentation/nav[0]/radials/target-radial-deg") - me.vorient + 0.5;
								if(vradials < 0.5) vradials += 360;
								elsif(vradials >= 360.5) vradials -= 360;
								me.hdg_setting.setValue(vradials);
							}
							else
							{
								setprop("autopilot/internal/presision-loc", 0);
							}
						}
					}
				}
				else
				{
					setprop("autopilot/internal/presision-loc", 0);
				}
			}
			elsif(me.lnav_armed.getValue())
			{
				if(getprop("position/gear-agl-ft") > 50)
				{
					msg = "";
					me.lnav_armed.setValue(0);		# Clear
					me.lateral_mode.setValue(3);	# LNAV
				}
				else
				{
					msg = "LNAV";
				}
			}
			elsif(me.rollout_armed.getValue())
			{
				msg = "ROLLOUT";
			}
			me.AP_roll_arm.setValue(msg);

		}elsif(me.step == 2){ ### check lateral modes  ###
			# Heading bug line enable control
			var vsethdg = me.hdg_setting.getValue();
			if(me.hdg_setting_last.getValue() != vsethdg)

			{
				me.hdg_setting_last.setValue(vsethdg);
				me.hdg_setting_active.setValue(1);
			}
			else
			{
				if(getprop("instrumentation/efis/mfd/display-mode") == "MAP")
				{
					if(me.lateral_mode.getValue() == 3
						or me.lateral_mode.getValue() == 4
						or me.lateral_mode.getValue() == 5)
					{
						if(me.hdg_setting_active.getValue() == 1)
						{
							settimer(func
							{
								if(me.hdg_setting_last.getValue() == vsethdg)
								{
									me.hdg_setting_active.setValue(0);
								}
							}, 10);
						}
					}
					else
					{
						me.hdg_setting_active.setValue(1);
					}
				}
			}
			var idx = me.lateral_mode.getValue();
			if(getprop("position/gear-agl-ft") > 50)
			{
				if ((idx == 1) or (idx == 2))
				{
					# switch between HDG SEL and HDG HOLD
					if (abs(me.reference_deg.getValue() - me.hdg_setting.getValue())<2)
					{
						idx = 2; # HDG HOLD
					}
					else
					{
						idx = 1; # HDG SEL
					}
				}
				if((idx == 6) or (idx == 7))
				{
					# switch between TRK SEL and TRK HOLD
					if (abs(me.reference_deg.getValue() - me.hdg_setting.getValue())<2)
					{
						idx = 7; # TRK HOLD
					}
					else
					{
						idx = 6; # TRK SEL
					}
				}
			}
			if(idx == 4)		# LOC
			{
				if((me.rollout_armed.getValue())
					and (getprop("position/gear-agl-ft") < 50))
				{
					me.rollout_armed.setValue(0);
					idx = 5;	# ROLLOUT
				}
				me.crab_angle.setValue(me.heading.getValue() - getprop("instrumentation/nav[0]/radials/target-radial-deg") + me.vorient);
				me.crab_angle_total.setValue(abs(me.crab_angle.getValue() + getprop("orientation/side-slip-deg")));
				if(me.crab_angle.getValue() > 0)
				{
					me.rwy_align_limit.setValue(5.0);
				}
				else
				{
					me.rwy_align_limit.setValue(-5.0);
				}
			}
			elsif(idx == 5)									# ROLLOUT
			{
				if(getprop("velocities/groundspeed-kt") < 50)
				{
					me.AP.setValue(0);						# Autopilot off
					setprop("controls/flight/aileron", 0);	# Aileron set neutral
					setprop("controls/flight/rudder", 0);	# Rudder set neutral
					me.FMC_destination_ils.setValue(0);		# Clear destination ILS set
					if(!me.FD.getValue())
					{
						idx = 0;	# NO MODE
					}
					else
					{
						idx = 1; 	# HDG SEL
					}
				}
			}
			elsif(idx == 8)									# ATT
			{
				var current_bank = getprop("orientation/roll-deg");
				if(current_bank > 30)
				{
					setprop("autopilot/internal/target-roll-deg", 30);
				}
				elsif(current_bank < -30)
				{
					setprop("autopilot/internal/target-roll-deg", -30);
				}
				elsif((abs(current_bank) > 5) and (abs(current_bank) <= 30))
				{
					setprop("autopilot/internal/target-roll-deg", current_bank);
				}
				elsif(abs(current_bank) <= 5)
				{
					setprop("autopilot/internal/target-roll-deg", 0);
				}
				if(abs(current_bank) <= 3)
				{
					var tgtHdg = int(me.reference_deg.getValue());
					me.hdg_setting.setValue(tgtHdg);
					if(me.hdg_trk_selected.getValue())
					{
						idx = 7;    # TRK HOLD
					}
					else
					{
						idx = 2;    #  HDG HOLD
					}
				}
			}
			me.lateral_mode.setValue(idx);
			if((me.AP_roll_mode.getValue() != me.roll_list[idx])
					and (idx > 0))
			{
				setprop("autopilot/settings/roll-transition", 1);
				settimer(func
				{
					setprop("autopilot/settings/roll-transition", 0);
				}, 10);
			}
			me.AP_roll_mode.setValue(me.roll_list[idx]);
			me.AP_roll_engaged.setBoolValue(idx > 0);

		}elsif(me.step==3){ ### check vertical modes  ###
			# This is only for Canvas ND pridiction circle indication, not used inside
			setprop("autopilot/settings/target-altitude-ft", me.target_alt.getValue());
			me.alt_setting_FL.setValue(me.alt_setting.getValue() / 1000);
			me.alt_setting_100.setValue(me.alt_setting.getValue() - (me.alt_setting_FL.getValue() * 1000));
			if(getprop("instrumentation/airspeed-indicator/indicated-speed-kt") < 100)
			{
				setprop("autopilot/internal/airport-height", current_alt);
			}
			### altitude alert ###
			var alt_deviation = abs(me.alt_setting.getValue() - current_alt);
			if((alt_deviation > 900)
					or (me.vertical_mode.getValue() == 6)			# G/S mode
					or (getprop("gear/gear/position-norm") == 1)) 	# Gear down and locked
			{
				me.altitude_alert_from_out = 0;
				me.altitude_alert_from_in = 0;
				setprop("autopilot/internal/alt-alert", 0);
			}
			elsif(alt_deviation > 200)
			{
				if((me.altitude_alert_from_out == 0)
						and (me.altitude_alert_from_in == 0))
				{
					me.altitude_alert_from_out = 1;
					setprop("autopilot/internal/alt-alert", 1);
				}
				elsif((me.altitude_alert_from_out == 1)
						and (me.altitude_alert_from_in == 1))
				{
					me.altitude_alert_from_out = 0;
					setprop("autopilot/internal/alt-alert", 2);
				}
			}
			else
			{
				me.altitude_alert_from_out = 1;
				me.altitude_alert_from_in = 1;
				setprop("autopilot/internal/alt-alert", 0);
			}

			var idx = me.vertical_mode.getValue();
			var test_fpa = me.vs_fpa_selected.getValue();
			var offset = (abs(getprop("velocities/vertical-speed-fps") * 60) / 8);
			if(offset < 20)
			{
				offset = 20;
			}

			elsif(idx == 3)		# VNAV PTH
			{
				if(me.vnav_descent.getValue())
				{
					if(me.descent_step == 0)
					{
						if(me.ias_mach_selected.getValue() == 1)
						{
							if(Vcal(me.FMC_descent_mach.getValue()) > (getprop("instrumentation/weu/state/stall-speed") + 5))
							{
								me.mach_setting.setValue(me.FMC_descent_mach.getValue());
							}
						}
						else
						{
							if(current_alt > 12000)
							{
								me.ias_setting.setValue(me.FMC_descent_ias.getValue());
							}
						}
						me.descent_step += 1;
					}
					elsif(me.descent_step == 1)
					{
						if(me.ias_mach_selected.getValue() == 1)
						{
							if(me.mach_setting.getValue() == me.FMC_descent_mach.getValue())
							{
								if(getprop("instrumentation/airspeed-indicator/indicated-mach") < (me.FMC_descent_mach.getValue() + 0.015))
								{
									me.vnav_path_mode.setValue(1);		# VNAV PTH DESCEND VS
									me.target_alt.setValue(me.intervention_alt);
									me.vs_setting.setValue(-2000);
									me.descent_step += 1;
								}
							}
							else
							{
								me.vnav_path_mode.setValue(1);		# VNAV PTH DESCEND VS
								me.target_alt.setValue(me.intervention_alt);
								me.vs_setting.setValue(-2000);
								me.descent_step += 1;
							}
						}
						else
						{
							if(getprop("instrumentation/airspeed-indicator/indicated-speed-kt") < (me.FMC_descent_ias.getValue() + 15))
							{
								me.vnav_path_mode.setValue(1);		# VNAV PTH DESCEND VS
								me.target_alt.setValue(me.intervention_alt);
								me.vs_setting.setValue(-2000);
								me.descent_step += 1;
							}
						}
					}
					elsif(me.descent_step == 2)
					{
						if(me.ias_mach_selected.getValue() == 1)
						{
							if(getprop("instrumentation/airspeed-indicator/indicated-speed-kt") >= me.FMC_descent_ias.getValue())
							{
								me.ias_mach_selected.setValue(0);
								me.ias_setting.setValue(me.FMC_descent_ias.getValue());
								me.descent_step += 1;
							}
							elsif((me.mach_setting.getValue() != me.FMC_descent_mach.getValue())
								and (Vcal(me.FMC_descent_mach.getValue()) > (getprop("instrumentation/weu/state/stall-speed") + 5)))
							{
								me.mach_setting.setValue(me.FMC_descent_mach.getValue());
							}
						}
						else
						{
							me.descent_step += 1;
						}
					}
					elsif(me.descent_step == 3)
					{
						if(current_alt < 29000)
						{
							me.vnav_path_mode.setValue(2);			# VNAV PTH DESCEND FLCH
							me.descent_step += 1;
						}
					}
					elsif(me.descent_step == 4)
					{
						if((current_alt < 12000)
							and (me.ias_setting.getValue() > 250))
						{
							me.ias_setting.setValue(250);
							me.descent_step += 1;
						}
					}
					# flight level change mode
					if (abs(current_alt - me.intervention_alt) < offset)
					{
						if(me.autothrottle_mode.getValue() != 0)
						{
							me.autothrottle_mode.setValue(5);	# A/T THRUST
						}
						me.vs_setting.setValue(0);
						me.vnav_path_mode.setValue(0);
						if(current_alt > (getprop("autopilot/route-manager/destination/field-elevation-ft") + 4750))
						{
							idx = 5;	# VNAV ALT
						}
					}
				}
				else
				{
					if(me.intervention_alt != me.FMC_cruise_alt.getValue())
					{
						me.FMC_cruise_alt.setValue(me.intervention_alt);
						if(me.intervention_alt <= me.optimal_alt)
						{
							me.target_alt.setValue(me.intervention_alt);
						}
						else
						{
							me.target_alt.setValue(me.optimal_alt);
						}
						idx = 4;	# VNAV THRUST
					}
					if((me.mach_setting.getValue() >= me.FMC_cruise_mach.getValue())
						and (me.ias_mach_selected.getValue() == 0))
					{
						me.ias_mach_selected.setValue(1);
						me.mach_setting.setValue(me.FMC_cruise_mach.getValue());
					}
					elsif((me.ias_setting.getValue() >= me.FMC_cruise_ias.getValue())
						and (me.ias_mach_selected.getValue() == 1))
					{
						me.ias_mach_selected.setValue(0);
						me.ias_setting.setValue(me.FMC_cruise_ias.getValue());
					}
					elsif(me.ias_mach_selected.getValue() == 0)
					{
						if(current_alt < 10000)
						{
							me.ias_setting.setValue(250);
						}
						else
						{
							me.ias_setting.setValue(me.FMC_cruise_ias.getValue());
						}
					}
				}
			}
			elsif(idx == 4)		# VNAV THRUST
			{
				if(getprop("controls/flight/flaps") > 0)		# flaps down
				{
					me.ias_setting.setValue(getprop("instrumentation/weu/state/target-speed"));
				}
				elsif(current_alt < 10000)
				{
					me.ias_setting.setValue(250);
				}
				else
				{
					if((me.mach_setting.getValue() >= me.FMC_cruise_mach.getValue())
						and (me.ias_mach_selected.getValue() == 0)
						and (current_alt < me.target_alt.getValue()))
					{
						me.ias_mach_selected.setValue(1);
						me.mach_setting.setValue(me.FMC_cruise_mach.getValue());
					}
					elsif((me.ias_setting.getValue() >= me.FMC_cruise_ias.getValue())
						and (me.ias_mach_selected.getValue() == 1)
						and (current_alt > me.target_alt.getValue()))
					{
						me.ias_mach_selected.setValue(0);
						me.ias_setting.setValue(me.FMC_cruise_ias.getValue());
					}
					elsif(me.ias_mach_selected.getValue() == 0)
					{
						if(current_alt < 10000)
						{
							me.ias_setting.setValue(250);
						}
						else
						{
							me.ias_setting.setValue(me.FMC_cruise_ias.getValue());
						}
					}
				}
				if(me.altitude_restriction > 0)
				{
					me.target_alt.setValue(me.altitude_restriction);
				}
				elsif(me.intervention_alt >= me.optimal_alt)
				{
					if(me.FMC_cruise_alt.getValue() >= me.optimal_alt)
					{
						me.target_alt.setValue(me.optimal_alt);
					}
					else
					{
						me.target_alt.setValue(me.intervention_alt);
					}
				}
				else
				{
					me.target_alt.setValue(me.intervention_alt);
				}
				var offset = (abs(getprop("velocities/vertical-speed-fps") * 60) / 8);
				if(offset < 20)
				{
					offset = 20;
				}
				if (abs(current_alt
					- me.target_alt.getValue()) < offset)
				{
					if(abs(current_alt - me.FMC_cruise_alt.getValue()) < offset)
					{			
						# within target altitude: switch to VANV PTH mode
						idx=3;
					}
					else
					{
						idx=5;				# VNAV ALT
					}
					if(me.autothrottle_mode.getValue() != 0)
					{
						me.autothrottle_mode.setValue(5);	# A/T THRUST
					}
					me.vs_setting.setValue(0);
				}
			}
			elsif(idx == 5)		# VNAV ALT
			{
				if(me.vnav_descent.getValue())
				{
					if(me.intervention_alt < (current_alt - 500))
					{
						idx = 3;		# VNAV PTH
						me.descent_step = 0;
					}
				}
				elsif(me.altitude_restriction > 0)
				{
					if(current_alt < (me.altitude_restriction - 500))
					{
						me.target_alt.setValue(me.altitude_restriction);
						idx = 4;		# VNAV THRUST
					}
				}
				elsif((current_alt <  (me.optimal_alt - 500))
					and (current_alt < (me.intervention_alt - 500)))
				{
					if(me.optimal_alt < me.intervention_alt)
					{
						me.target_alt.setValue(me.optimal_alt);
					}
					else
					{
						me.target_alt.setValue(me.intervention_alt);
					}
					idx = 4;		# VNAV THRUST
				}
			}
			elsif(idx == 6)				# G/S
			{
				var f_angle = getprop("autopilot/constant/flare-base") * 135 / getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
				me.flare_constant_setting.setValue(f_angle);
				if(getprop("position/gear-agl-ft") < 50)
				{
					me.flare_armed.setValue(0);
					idx = 7;			# FLARE
				}
				elsif(me.AP.getValue() and (getprop("position/gear-agl-ft") < 1500))
				{
					me.rollout_armed.setValue(1);		# ROLLOUT
					me.flare_armed.setValue(1);			# FLARE
					setprop("autopilot/settings/flare-speed-fps", 5);
				}
			}
			else
			{
				if(me.autothrottle_mode.getValue() == 5)	# THRUST
				{
					if(getprop("position/gear-agl-ft") < 50)
					{
						me.autothrottle_mode.setValue(4);	# A/T IDLE
					}
					if(getprop("velocities/groundspeed-kt") < 30)
					{
						if(!me.FD.getValue())
						{
							idx = 0;	# NO MODE
						}
						else
						{
							idx = 1; 	# ALT
						}
					}
				}
			}
			if((current_alt
				- getprop("autopilot/internal/airport-height")) > 400) # Take off mode and above baro 400 ft
			{
				if(me.vnav_armed.getValue())
				{
					if(me.target_alt.getValue() == int(current_alt))
					{
						if(me.FMC_cruise_alt.getValue() == int(current_alt))
						{
							idx = 3;		# VNAV PTH
						}
						else
						{
							idx = 5;		# VNAV ALT
						}					
					}
					else
					{
						idx = 4;		# VNAV THRUST
					}
					me.intervention_alt = me.alt_setting.getValue();
					if(me.intervention_alt > me.FMC_cruise_alt.getValue())
					{
						me.target_alt.setValue(me.FMC_cruise_alt.getValue());
					}
					else
					{
						me.target_alt.setValue(me.intervention_alt);
					}
					me.vnav_armed.setValue(0);
				}
			}
			me.vertical_mode.setValue(idx);
			if((me.AP_pitch_mode.getValue() != me.pitch_list[idx])
					and (idx > 0))
			{
				setprop("autopilot/settings/pitch-transition", 1);
				settimer(func
				{
					setprop("autopilot/settings/pitch-transition", 0);
				}, 10);
			}
			me.AP_pitch_mode.setValue(me.pitch_list[idx]);
			me.AP_pitch_engaged.setBoolValue(idx>0);

		}
		elsif(me.step == 4) 			### Auto Throttle mode control  ###
		{
			# Thrust reference rate calculation. This should be provided by FMC
			var payload = getprop("consumables/fuel/total-fuel-lbs") + getprop("sim/weight[0]/weight-lb") + getprop("sim/weight[1]/weight-lb");
			var derate = 0.3 - payload * 0.00000083;
			if(me.ias_setting.getValue() < 251)
			{
				var vflight_idle = (getprop("autopilot/constant/descent-profile-low-base")
					+ (getprop("autopilot/constant/descent-profile-low-rate") * payload / 1000));
			}
			else
			{
				var vflight_idle = (getprop("autopilot/constant/descent-profile-high-base")
					+ (getprop("autopilot/constant/descent-profile-high-rate") * payload / 1000));
			}
			if(vflight_idle < 0.00) vflight_idle = 0.00;
			me.flight_idle.setValue(vflight_idle);
			# Thurst limit varis on altitude
			var thrust_lmt = 0.96;
			if(current_alt < 25000)
			{
				if((me.vertical_mode.getValue() == 8)			# FLCH THRUST mode
					or(me.vertical_mode.getValue() == 4))		# VNAV THRUST mode
				{
					if(me.vertical_mode.getValue() == 4)		# VNAV THRUST mode
					{
						thrust_lmt = derate / 25000 * abs(current_alt) + (0.95 - derate);
					}
					if(getprop("controls/flight/flaps") == 0)
					{
						if(me.ias_mach_selected.getValue())
						{
							thrust_lmt *= (me.mach_setting.getValue() / 0.84);
						}
						else
						{
							thrust_lmt *= (me.ias_setting.getValue() / 320);
						}
					}
					else
					{
						thrust_lmt *= 0.78125;
					}
				}
				elsif(me.vertical_mode.getValue() != 2)			# not V/S mode
				{
					thrust_lmt = derate / 25000 * abs(current_alt) + (0.95 - derate);
				}
			}
			me.thrust_lmt.setValue(thrust_lmt);
			# IAS and MACH number update in back ground
			var temp = 0;
			if(me.ias_mach_selected.getValue() == 1)
			{
				me.ias_setting.setValue(Vcal(me.mach_setting.getValue()));
			}
			else
			{
				temp = (int(getprop("instrumentation/airspeed-indicator/indicated-mach")  * 1000 + 0.5) / 1000);
				me.mach_setting.setValue(temp);
			}
			# Auto throttle arm switch is offed
			if((me.at1.getValue() == 0) or (me.at2.getValue() == 0))
			{
				me.autothrottle_mode.setValue(0);
				setprop("autopilot/settings/speed-transition", 0);
			}
			# auto-throttle disengaged when reverser is enabled
			elsif (getprop("controls/engines/engine/reverser-act"))
			{
				me.autothrottle_mode.setValue(0);
				setprop("autopilot/settings/speed-transition", 0);
			}
			elsif(me.autothrottle_mode.getValue() == 2)		# THR REF
			{
				if((getprop("instrumentation/airspeed-indicator/indicated-speed-kt") > 80)
					and ((current_alt - getprop("autopilot/internal/airport-height")) < 400))
				{
					me.autothrottle_mode.setValue(3);			# HOLD
				}
				elsif((me.vertical_mode.getValue() != 3)		# not VNAV PTH
					and (me.vertical_mode.getValue() != 5))		# not VNAV ALT
				{
					if((getprop("controls/flight/flaps") == 0)		# FLAPs up
						and (me.vertical_mode.getValue() != 4))		# not VNAV THRUST
					{
						me.autothrottle_mode.setValue(5);		# THRUST
					}
					else
					{
						setprop("controls/engines/engine[0]/throttle", thrust_lmt);
						setprop("controls/engines/engine[1]/throttle", thrust_lmt);
						setprop("controls/engines/engine[2]/throttle", thrust_lmt);
					}
				}
			}
			elsif((me.autothrottle_mode.getValue() == 4)		# Auto throttle mode IDLE 
				and ((me.vertical_mode.getValue() == 8)			# FLCH THRUST mode
					or (me.vertical_mode.getValue() == 3))		# VNAV PTH mode
				and (int(me.flight_idle.getValue() * 1000) == int(getprop("controls/engines/engine[0]/throttle-act") * 1000))		# #1Thrust is actual flight idle
				and (int(me.flight_idle.getValue() * 1000) == int(getprop("controls/engines/engine[1]/throttle-act") * 1000)))		# #2Thrust is actual flight idle
			{
				me.autothrottle_mode.setValue(3);				# HOLD
			}
			# Take off mode and above baro 400 ft
			elsif((current_alt - getprop("autopilot/internal/airport-height")) > 400)
			{
				setprop("autopilot/locks/takeoff-mode", 0);
				if(me.autothrottle_mode.getValue() == 1)		# THR
				{
					setprop("controls/engines/engine[0]/throttle", thrust_lmt);
					setprop("controls/engines/engine[1]/throttle", thrust_lmt);
				}
				elsif((me.vertical_mode.getValue() == 10)		# TO/GA
					or ((me.autothrottle_mode.getValue() == 3)	# HOLD
					and (me.vertical_mode.getValue() != 8)		 # not FLCH
						and (me.vertical_mode.getValue() != 3) 	 # not VNAV PTH
						and (me.vertical_mode.getValue() != 5))) # not VNAV ALT
				{
					if(getprop("controls/flight/flaps") == 0)
					{
						me.autothrottle_mode.setValue(5);		# THRUST
					}
					else
					{
						me.autothrottle_mode.setValue(2);		# THR REF
					}
				}
				elsif(me.vertical_mode.getValue() == 4)			# VNAV THRUST
				{
					me.autothrottle_mode.setValue(2);			# THR REF
				}
				elsif(me.vertical_mode.getValue() == 3)			# VNAV PTH
				{
					if(me.vnav_path_mode.getValue() == 2)
					{
						if(me.autothrottle_mode.getValue() != 3)
						{
							me.autothrottle_mode.setValue(4);	# IDLE
						}
					}
					else
					{
						me.autothrottle_mode.setValue(5);		# THRUST
					}
				}
				elsif(me.vertical_mode.getValue() == 5)			# VNAV ALT
				{
					me.autothrottle_mode.setValue(5);		# THRUST
				}
			}
			elsif((getprop("position/gear-agl-ft") > 100)		# Approach mode and above 100 ft
					and (me.vertical_mode.getValue() == 6)) 
			{
				me.autothrottle_mode.setValue(5);				# THRUST
			}
			idx = me.autothrottle_mode.getValue();
			if((me.AP_speed_mode.getValue() != me.spd_list[idx])
					and (idx > 0))
			{
				setprop("autopilot/settings/speed-transition", 1);
				settimer(func
				{
					setprop("autopilot/settings/speed-transition", 0);
				}, 10);
			}
			me.AP_speed_mode.setValue(me.spd_list[idx]);
		}
		elsif(me.step==5)			#LNAV route calculation
		{
			var total_distance = getprop("autopilot/route-manager/total-distance");
			var distance = total_distance - getprop("autopilot/route-manager/distance-remaining-nm");
			var destination_elevation = getprop("autopilot/route-manager/destination/field-elevation-ft");
			if (me.FMC_active.getValue())
			{
				var max_wpt = getprop("autopilot/route-manager/route/num");
				var atm_wpt = me.FMC_current_wp.getValue();
				if(me.lateral_mode.getValue() == 3)		# Current mode is LNAV
				{
					if(atm_wpt < (max_wpt - 1))
					{
						me.remaining_distance.setValue(getprop("autopilot/route-manager/wp/remaining-distance-nm")
							+ getprop("autopilot/route-manager/wp/dist"));
						var next_course = getprop("autopilot/route-manager/wp[1]/bearing-deg");
					}
					else
					{
						me.remaining_distance.setValue(getprop("autopilot/route-manager/wp/dist"));
					}
					if(me.vnav_descent.getValue() == 0)	# Calculation of Top Of Descent distance
					{
						var cruise_alt = me.FMC_cruise_alt.getValue();
						me.top_of_descent = 16;
						if(cruise_alt > 10000)
						{
							me.top_of_descent += 21;
							if(cruise_alt > 29000)
							{
								me.top_of_descent += 41.8;
								if(cruise_alt > 36000)
								{
									me.top_of_descent += 28;
									me.top_of_descent += (cruise_alt - 36000) / 1000 * 3.8;
								}
								else
								{
									me.top_of_descent += (cruise_alt - 29000) / 1000 * 4;
								}
							}
							else
							{
								me.top_of_descent += (cruise_alt - 10000) / 1000 * 2.2;
							}
							me.top_of_descent += 6.7;
						}
						else
						{
							me.top_of_descent += (cruise_alt - 3000) / 1000 * 3;
						}
						me.top_of_descent -= (destination_elevation / 1000 * 3);
						if((me.alt_setting.getValue() > 24000)
							and (me.alt_setting.getValue() >= cruise_alt))
						{
							if(me.remaining_distance.getValue() < (me.top_of_descent + 10))
							{
								me.vnav_mcp_reset.setValue(1);
								copilot("Reset MCP ALT");
							}
						}
						else
						{
							me.vnav_mcp_reset.setValue(0);
							if(me.remaining_distance.getValue() < me.top_of_descent)
							{
								me.vnav_descent.setValue(1);
								me.intervention_alt = me.alt_setting.getValue();
							}
						}
					}
				}
				
				var groundspeed = getprop("velocities/groundspeed-kt");
				var f= flightplan(); 
#				var topClimb = f.pathGeod(0, 100);
				var topDescent = f.pathGeod(-1, -me.top_of_descent);
				var targetCourse = f.pathGeod(-1, -me.remaining_distance.getValue());
				var leg = f.currentWP(); 
				if(leg == nil)
				{
					me.step+=1;
					if(me.step>6) me.step =0;
					return;
				}
				var enroute = leg.courseAndDistanceFrom(targetCourse);
				if(me.FMC_current_wp.getValue() == 0)
				{
					setprop("autopilot/internal/course-deg", getprop("orientation/heading-deg"));
				}
				else
				{
					setprop("autopilot/internal/course-deg", enroute[0]);
				}

				var courseCoord = geo.Coord.new().set_latlon(targetCourse.lat, targetCourse.lon); 
				var geocoord = geo.aircraft_position(); 
				var CourseError = (geocoord.course_to(courseCoord) - getprop("orientation/heading-deg"));
				if(CourseError < -180) CourseError += 360;
				elsif(CourseError > 180) CourseError -= 360;
				if(CourseError > 0)
				{
					CourseError = geocoord.distance_to(courseCoord);
				}
				else
				{
					CourseError = (geocoord.distance_to(courseCoord) * -1);
				}
				var cCourseError = CourseError * 0.01;
				if(cCourseError > 4.0) cCourseError = 4.0;
				elsif(cCourseError < -4.0) cCourseError = -4.0;
				setprop("autopilot/internal/course-error", cCourseError);

#				var tcNode = me.NDSymbols.getNode("tc", 1);
#				tcNode.getNode("longitude-deg", 1).setValue(topClimb.lon);
#				tcNode.getNode("latitude-deg", 1).setValue(topClimb.lat);

				var tdNode = me.NDSymbols.getNode("td", 1);
				tdNode.getNode("longitude-deg", 1).setValue(topDescent.lon);
				tdNode.getNode("latitude-deg", 1).setValue(topDescent.lat);
				if(enroute[1] != nil)	# Course deg
				{
					var wpt_eta = (enroute[1] / groundspeed * 3600);
					var gmt = getprop("instrumentation/clock/indicated-sec");
					if((getprop("gear/gear[1]/wow") == 0) and (getprop("gear/gear[2]/wow") == 0))
					{
						gmt += (wpt_eta + 30);
						var gmt_hour = int(gmt / 3600);
						if(gmt_hour > 24)
						{
							gmt_hour -= 24;
							gmt -= 24 * 3600;
						}
						me.estimated_time_arrival.setValue(gmt_hour * 100 + int((gmt - gmt_hour * 3600) / 60));
						var change_wp = abs(getprop("autopilot/route-manager/wp[1]/bearing-deg") - me.heading.getValue());
						if(change_wp > 180) change_wp = (360 - change_wp);
						if(((me.heading_change_rate * change_wp) > wpt_eta)
							or (enroute[1] < 0.6))
 						{
 							if(atm_wpt < (max_wpt - 1))
							{
								atm_wpt += 1;
								me.FMC_current_wp.setValue(atm_wpt);
								me.altitude_restriction = getprop("autopilot/route-manager/route/wp["~atm_wpt~"]/altitude-ft");
								if(me.altitude_restriction > 0)
								{
									me.altitude_restriction = int((me.altitude_restriction + 50) / 100 )* 100;
								}
							}
						}
					}
				}
				if((me.FMC_destination_ils.getValue() == 0)	#FMC autotune function
					and (me.lateral_mode.getValue() == 3))	#LNAV engaged
				{
					if((me.remaining_distance.getValue() < 150)
						or (me.remaining_distance.getValue() < (me.top_of_descent + 50))
						or (me.vnav_descent.getValue() == 1))
					{
						var dist_run = flightplan().destination_runway;
						if(dist_run != nil)
						{
							var freq = dist_run.ils_frequency_mhz;
							if(freq != nil)
							{
								setprop("instrumentation/nav/frequencies/standby-mhz", freq);
								b777.Efis.set_radio_mode(2);
								b777.Efis.swap_freq();
								me.FMC_destination_ils.setValue(1);
							}
						}
					}
				}
				if((distance > 400) or (distance > (total_distance / 2)))
				{
					me.FMC_landing_rwy_elevation.setValue(destination_elevation);
				}
				else
				{
					me.FMC_landing_rwy_elevation.setValue(getprop("autopilot/route-manager/departure/field-elevation-ft"));
				}
			}
			else
			{
				if((distance == nil) or (total_distance == nil))
				{
					# Reset flag when not active
					if(me.FMC_destination_ils.getValue() == 1) me.FMC_destination_ils.setValue(0);
					me.FMC_landing_rwy_elevation.setValue(getprop("autopilot/route-manager/departure/field-elevation-ft"));
				}
				else
				{
					if((distance > 400) or (distance > (total_distance / 2)))
					{
						me.FMC_landing_rwy_elevation.setValue(destination_elevation);
					}
					else
					{
						# Reset flag when not active
						if(me.FMC_destination_ils.getValue() == 1) me.FMC_destination_ils.setValue(0);
						me.FMC_landing_rwy_elevation.setValue(getprop("autopilot/route-manager/departure/field-elevation-ft"));
					}
				}
			}
		}elsif(me.step==6)
		{
			if(getprop("controls/flight/flaps") == 0)
			{
				me.auto_popup.setValue(0);
			}
			var ma_spd = getprop("instrumentation/airspeed-indicator/indicated-mach");
			me.pfd_mach_ind.setValue(ma_spd * 1000);
			me.pfd_mach_target.setValue(getprop("autopilot/settings/target-speed-mach") * 1000);
			var banklimit = getprop("instrumentation/afds/inputs/bank-limit-switch");
			if(banklimit==0)
			{
				var lim = 0;
				me.heading_change_rate = 0;
				if(ma_spd > 0.85)
				{
					lim=5;
					me.heading_change_rate = 4.9 * 0.7;
				}
				elsif(ma_spd > 0.6666)
				{
					lim=10;
					me.heading_change_rate = 2.45 * 0.7;
				}
				elsif(ma_spd > 0.5)
				{
					lim=20;
					me.heading_change_rate = 1.125 * 0.7;
				}
				elsif(ma_spd > 0.3333)
				{
					lim=30;
					me.heading_change_rate = 0.625 * 0.7;
				}
				else
				{
					lim=35;
					me.heading_change_rate = 0.55 * 0.7;
				}
				props.globals.getNode("instrumentation/afds/settings/bank-max").setValue(lim);
				lim = -1 * lim;
				props.globals.getNode("instrumentation/afds/settings/bank-min").setValue(lim);
			}
		}

		me.step+=1;
		if(me.step>6) me.step =0;
	},
};
#####################


var afds = AFDS.new();

	setlistener("sim/signals/fdm-initialized", func {
	settimer(update_afds,6);
});

var update_afds = func {
	afds.ap_update();
	settimer(update_afds, 0);
}
