#############################################################################
# 777 Autopilot Flight Director System
# Syd Adams
#
# speed modes: THR,THR REF, IDLE,HOLD,THRUST;
# roll modes : TO/GA,HDG SEL,HDG HOLD, LNAV,LOC,ROLLOUT,TRK SEL, TRK HOLD,ATT;
# pitch modes: TO/GA,ALT,V/S,VNAV PTH,VNAV SPD,VNAV ALT,G/S,FLARE,FLCH SPD,FPA;
# FPA range  : -9.9 ~ 9.9 degrees
# VS range   : -8000 ~ 6000
# ALT range  : 0 ~ 50,000
#
#############################################################################

#Usage : var afds = AFDS.new();

var AFDS = {
    new : func{
        var m = {parents:[AFDS]};

        m.spd_list=["","THR","THR REF","HOLD","IDLE","THRUST"];

        m.roll_list=["","HEADING","HEADING","NAV1","LOC","ROLLOUT",
        "TRK SEL","TRK HOLD","ATT","TO/GA"];

        m.pitch_list=["","HOLD","V/S","VNAV PTH","VNAV SPD",
        "PROF","G/S","FLARE","CLB THRUST","FPA","TO/GA","CLB CON","PROF TO"];

        m.step=0;
	m.heading_change_rate = 0;
	
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
	m.autoland = props.globals.initNode("autopilot/autoland/engaged",0,"BOOL");

	m.reset = m.AFDS_inputs.initNode("reset",0,"BOOL");
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
        m.ias_mach_selected = m.AFDS_inputs.initNode("ias-mach-selected",0,"BOOL");
        m.hdg_trk_selected = m.AFDS_inputs.initNode("hdg-trk-selected",0,"BOOL");
        m.vs_fpa_selected = m.AFDS_inputs.initNode("vs-fpa-selected",0,"BOOL");
        m.bank_switch = m.AFDS_inputs.initNode("bank-limit-switch",0,"INT");

        m.ias_setting = m.AP_settings.initNode("target-speed-kt",250); # 100 - 399 #
        m.mach_setting = m.AP_settings.initNode("target-speed-mach",0.40); # 0.40 - 0.95 #
        m.vs_setting = m.AP_settings.initNode("vertical-speed-fpm",0); # -8000 to +6000 #
        m.hdg_setting = m.AP_settings.initNode("heading-bug-deg",360,"INT");
        m.fpa_setting = m.AP_settings.initNode("flight-path-angle",0); # -9.9 to 9.9 #
        m.alt_setting = m.AP_settings.initNode("altitude-setting-ft",10000,"DOUBLE");
        m.FMS_alt = m.AP_settings.initNode("target-altitude-ft",10000,"DOUBLE");
        m.auto_brake_setting = m.AP_settings.initNode("autobrake",0.000,"DOUBLE");
	m.FLthousand = m.AP_settings.initNode("counter-set-altitude-FL",10,"INT");
	m.FLhundred = m.AP_settings.initNode("counter-set-altitude-100",0,"INT");

        m.trk_setting = m.AFDS_settings.initNode("trk",0,"INT");
        m.vs_display = m.AFDS_settings.initNode("vs-display",0);
        m.fpa_display = m.AFDS_settings.initNode("fpa-display",0);
	m.alt_display = props.globals.initNode("autopilot/settings/alt-display-ft",10000);
	m.flch_mode = m.AFDS_settings.initNode("flch-mode",0,"BOOL");
        m.bank_min = m.AFDS_settings.initNode("bank-min",-25);
        m.bank_max = m.AFDS_settings.initNode("bank-max",25);
        m.pitch_min = m.AFDS_settings.initNode("pitch-min",-10);
        m.pitch_max = m.AFDS_settings.initNode("pitch-max",15);
        m.vnav_alt = m.AFDS_settings.initNode("vnav-alt",35000);

        m.AP_roll_mode = m.AFDS_apmodes.initNode("roll-mode","TO/GA");
        m.AP_roll_arm = m.AFDS_apmodes.initNode("roll-mode-arm"," ");
        m.AP_pitch_mode = m.AFDS_apmodes.initNode("pitch-mode","TO/GA");
        m.AP_pitch_arm = m.AFDS_apmodes.initNode("pitch-mode-arm"," ");
        m.AP_speed_mode = m.AFDS_apmodes.initNode("speed-mode","");
        m.AP_annun = m.AFDS_apmodes.initNode("mode-annunciator"," ");

	m.remaining_distance = m.AFDS_inputs.initNode("remaining-distance",0,"DOUBLE");

        m.APl = setlistener(m.AP, func m.setAP(),0,0);
        m.Lbank = setlistener(m.bank_switch, func m.setbank(),0,0);
        m.LTMode = setlistener(m.autothrottle_mode, func m.updateATMode(),0,0);
	m.a_land = setlistener(m.autoland, func {
	    if (m.autoland.getBoolValue()) m.autolandlisteners();
	},0,0);
        m.APdisl = setlistener(m.AP_disengaged, func {
	    if (m.AP_disengaged.getBoolValue()) {
		m.AP.setBoolValue(0);
		m.at1.setBoolValue(0);
		m.at2.setBoolValue(0);
	    }
	    m.setAP();
	},0,0);
	m.Lreset = setlistener(m.reset, func m.afds_reset(),0,0);
	m.Lrefsw = setlistener("instrumentation/efis/mfd/true-north", func m.hdg_ref_sw(),0,0);
	m.e_time = 0;
	m.status_light = m.AFDS_inputs.initNode("status-light",0,"BOOL");

	m.errmsg = ["Invalid Route: Enter 2 or more valid waypoints in your flightplan.","Invalid Route: Enter the departure runway in your flightplan"];
	m.errtrip = [0,0];

        return m;
    },
   
####    Autoflight Button    ####
###################
    APpwrbtn : func {
		    me.AP.setBoolValue(1);
			me.at1.setBoolValue(1);
			me.at2.setBoolValue(1);
			setprop("controls/switches/apoffsound", 0)
    },

####    Yoke AP Disconnect Button    ####
###################
    APyokebtn : func {
	if (me.AP.getBoolValue()) {
	    me.AP.setBoolValue(0);
	} else {
	    me.at1.setBoolValue(0);
	    me.at2.setBoolValue(0);
	}
    },

####    Autoland Listeners    ####
###################
    autolandlisteners : func {
	var at_cutout = setlistener("gear/gear[1]/wow", func(td_main) {
	    if (td_main.getBoolValue()) {
		me.at1.setBoolValue(0);
		me.at2.setBoolValue(0);
		removelistener(at_cutout);
	    }
	},0,0);
	var ap_cutout = setlistener("gear/gear/wow", func(td_nose) {
	    if (td_nose.getBoolValue()) {
		me.AP.setBoolValue(0);
		removelistener(ap_cutout);
	    }
	},0,0);
    },

####    Inputs    ####
###################
    input : func(mode,btn){
#        var fms = 0;
        if(mode==0){
            # horizontal AP controls
            if(me.lateral_mode.getValue() ==btn) btn=0;
	    if (btn == 2) {
		if (getprop("instrumentation/efis/mfd/true-north")) {
		    var hdg_now = int(getprop("orientation/heading-deg")+0.5);
		} else {
		    var hdg_now = int(getprop("orientation/heading-magnetic-deg")+0.5);
		}
		me.hdg_setting.setValue(hdg_now);
	    }
            me.lateral_mode.setValue(btn);
        }elsif(mode==1){
            # vertical AP controls
            if(me.vertical_mode.getValue() ==btn) btn=0;
            var vs_now = int(getprop("/velocities/vertical-speed-fps")*0.6)*100;
            var alt = int((getprop("instrumentation/altimeter/indicated-altitude-ft")+50)/100)*100;
            if (btn==1){
                # hold current altitude
                if (me.AP.getValue())
                {
		    me.alt_display.setValue(alt);
                    me.alt_setting.setValue(alt);
                } else
                    btn = 0;
            }
	    if (btn==2) {
		settimer(func {
		    if (me.vertical_mode.getValue() == 2 or me.vertical_mode == 9)
			me.flch_mode.setBoolValue(1);
		},2);
		if (vs_now > 6000) {
		    me.vs_setting.setValue(6000);
		} elsif (vs_now < -8000) {
		    me.vs_setting.setValue(-8000);
		} else {
		    me.vs_setting.setValue(vs_now);
	 	}
	    }
            if (btn==5) {
                # VNAV
                if (vs_now >= -100)
                {
                    if (me.FMS_alt.getValue() < alt) me.FMS_alt.setValue(alt);
                } else {
                    if (me.FMS_alt.getValue() > alt) me.FMS_alt.setValue(alt);
                }
		me.alt_display.setValue(me.FMS_alt.getValue());
#               me.vnav_alt.setValue(me.FMS_alt.getValue());   
            }
	    if (btn==8) {
		me.alt_setting.setValue(me.alt_display.getValue());
	    }
            if (btn==11)
            {
		if (vs_now>0 and vs_now<6000)
                me.vs_setting.setValue(vs_now);
            }
	    if (btn != 2) me.flch_mode.setBoolValue(0);
            me.vertical_mode.setValue(btn);
        }elsif(mode==2){
            # throttle AP controls
            if(me.autothrottle_mode.getValue() ==btn) btn=0;
            if(getprop("position/altitude-agl-ft")<200) btn=0;
            me.autothrottle_mode.setValue(btn);
        }elsif(mode==3){
            var arm = 1-((me.loc_armed.getBoolValue() or (4==me.lateral_mode.getValue())));
	    if (arm==0) btn = 1;
            if (btn==1){
                # toggle G/S and LOC arm
		if (me.vertical_mode.getValue() == 8 or me.vertical_mode.getValue() == 12) {
		    me.input(1,2);
		    me.flch_mode.setBoolValue(0);
		} elsif (me.vertical_mode.getValue() == 5)
		    me.vertical_mode.setValue(1);
                arm = arm or (1-(me.gs_armed.getBoolValue() or (6==me.vertical_mode.getValue())));
                me.gs_armed.setBoolValue(arm);
                if ((arm==0)and(6==me.vertical_mode.getValue())) me.vertical_mode.setValue(0);
            }
            me.loc_armed.setBoolValue(arm);
            if((arm==0)and(4==me.lateral_mode.getValue())) me.lateral_mode.setValue(0);
        }
    },
###################
    setAP : func{
        var output=1-me.AP.getValue();
        var disabled = me.AP_disengaged.getValue();
        if(getprop("position/altitude-agl-ft")<200)disabled = 1;
        if((disabled)and(output==0)){output = 1;me.AP.setValue(0);}
        setprop("autopilot/internal/target-pitch-deg",getprop("orientation/pitch-deg"));
        setprop("autopilot/internal/target-roll-deg",0);
        me.AP_passive.setValue(output);
    },
###################
    setbank : func{
        var banklimit=me.bank_switch.getValue();
        var lmt=25;
        if(banklimit>0){lmt=banklimit * 5};
        me.bank_max.setValue(lmt);
        lmt = -1 * lmt;
        me.bank_min.setValue(lmt);
    },
###################
    updateATMode : func()
    {
        var idx=me.autothrottle_mode.getValue();
	if (me.AP_disengaged.getBoolValue()) idx = 0;
        me.AP_speed_mode.setValue(me.spd_list[idx]);
    },
###################
    afds_reset : func {
        if (me.reset.getBoolValue()) {
            settimer( func {
                me.reset.setBoolValue(0);
                update_afds();
            },5);
        }
    },
###################
    hdg_ref_sw : func {
        if (me.lateral_mode.getValue() == 2) {
            me.input(0,2);
            me.input(0,2);
        }
    },
###################

    ap_update : func{
        var VS =getprop("velocities/vertical-speed-fps");
        var TAS =getprop("velocities/uBody-fps");
        if(TAS < 10) TAS = 10;
        if(VS < -200) VS=-200;
        if (abs(VS/TAS)<=1)
        {
          var FPangle = math.asin(VS/TAS);
          FPangle *=90;
          setprop("autopilot/internal/fpa",FPangle);
        }
        var msg=" ";
        if(me.FD.getValue())msg="FLT DIR";
        if(me.AP.getValue())msg="AP ENG";
        me.AP_annun.setValue(msg);
        var tmp = abs(me.vs_setting.getValue());
        me.vs_display.setValue(tmp);
        tmp = abs(me.fpa_setting.getValue());
        me.fpa_display.setValue(tmp);
	me.FLthousand.setValue(int(me.alt_setting.getValue() / 1000));
	me.FLhundred.setValue(int(me.alt_setting.getValue() - (me.FLthousand.getValue() * 1000)));
        msg="";
        var hdgoffset = me.hdg_setting.getValue()-getprop("orientation/heading-magnetic-deg");
        if(hdgoffset < -180) hdgoffset +=360;
        if(hdgoffset > 180) hdgoffset +=-360;
        setprop("autopilot/internal/fdm-heading-bug-error-deg",hdgoffset);

		var radaralt = getprop("position/altitude-agl-ft");
        if(radaralt < 200 and me.vertical_mode.getValue() == 6 and me.AP.getBoolValue()) {
	    me.at1.setBoolValue(0);
	    me.autoland.setBoolValue(1);
	} else {
	    me.autoland.setBoolValue(0);
	}
        if (radaralt < 100) {
	    if (!me.autoland.getBoolValue()) {
		me.AP.setBoolValue(0);
#		me.at2.setBoolValue(0);
			}
		}
		var apmodespdauto = getprop("instrumentation/afds/ap-modes/speed-mode");
		var flapsett = getprop("surface-positions/flap-pos-norm");
		if (radaralt < 100 and flapsett > 0.68 and apmodespdauto == "THRUST") {
			setprop("autopilot/settings/target-speed-kt", 0);
		}
	
		if (radaralt < 20) {
		    me.at1.setBoolValue(0);
		}

        if(me.step==0){ ### glideslope armed ?###
#            msg="";
            if(me.gs_armed.getBoolValue()){
#                msg="G/S";
                var gsdefl = getprop("instrumentation/nav/gs-needle-deflection");
                var gsrange = getprop("instrumentation/nav/gs-in-range");
                if(gsdefl< 0.5 and gsdefl>-0.5){
                    if(gsrange){
                        me.vertical_mode.setValue(6);
                        me.gs_armed.setBoolValue(0);
			me.flch_mode.setBoolValue(0);
                    }
                }
            }
#            me.AP_pitch_arm.setValue(msg);

        }elsif(me.step==1){ ### localizer armed ? ###
            if(me.loc_armed.getBoolValue()){
                var hddefl = getprop("instrumentation/nav/heading-needle-deflection");
                if(hddefl< 8 and hddefl>-8){
                    me.lateral_mode.setValue(4);
                    me.loc_armed.setBoolValue(0);
                }
            }

        }elsif(me.step==2){ ### check lateral modes  ###
            var idx=me.lateral_mode.getValue();
	    msg = "";
            if (idx == 1) {
#                msg = "HDG HOLD";
                if (abs(me.hdg_setting.getValue() - getprop("orientation/heading-magnetic-deg")) < 5) {
                    me.lateral_mode.setValue(2);
                }
            }
            if (me.loc_armed.getBoolValue()) msg = "LOC ARMED";
            me.AP_roll_arm.setValue(msg);
            me.AP_roll_mode.setValue(me.roll_list[idx]);
            me.AP_roll_engaged.setBoolValue(idx>0);

        }elsif(me.step==3){ ### check vertical modes  ###
            var idx=me.vertical_mode.getValue();
            var test_fpa=me.vs_fpa_selected.getValue();
            if(idx==2 and test_fpa)idx=9;
            if(idx==9 and !test_fpa)idx=2;
	    msg = "";

	    if (((idx==2) or (idx==9)) and me.flch_mode.getBoolValue())
	    {
		# VS or FPA mode
		me.alt_setting.setValue(me.alt_display.getValue());
		if ((idx==2 and me.vs_setting.getValue()>0) or (idx==9 and me.fpa_setting.getValue()>0)) var climb = 1;
		if ((idx==2 and me.vs_setting.getValue()<=0) or (idx==9 and me.fpa_setting.getValue()<=0)) var climb = 0;
		if ((climb == 1) and (me.alt_setting.getValue() > getprop("instrumentation/altimeter/indicated-altitude-ft")))
		{
		    if (abs(getprop("instrumentation/altimeter/indicated-altitude-ft")-me.alt_setting.getValue())<50) idx=1;
		}
		if ((climb == 0) and (me.alt_setting.getValue() < getprop("instrumentation/altimeter/indicated-altitude-ft"))) 
                {
		    if (abs(getprop("instrumentation/altimeter/indicated-altitude-ft")-me.alt_setting.getValue())<50) idx=1;
		}
		if (idx != 2 and idx != 9) me.flch_mode.setBoolValue(0);
		me.vertical_mode.setValue(idx);
	    }

            if ((idx==1)or(idx==8))
            {
                # flight level change mode
                if (abs(getprop("instrumentation/altimeter/indicated-altitude-ft")-me.alt_setting.getValue())<50) {
                    # within target altitude: switch to ALT HOLD mode
                    idx=1;
                } else {
                    # outside target altitude: change flight level
		    me.alt_setting.setValue(me.alt_display.getValue());
                    idx=8;
		}
                me.vertical_mode.setValue(idx);
            }

            if ((idx==5)or(idx==12))
            {
                me.vnav_alt.setValue(me.FMS_alt.getValue());
                me.alt_setting.setValue(me.FMS_alt.getValue());
                # flight level change mode (VNAV)
                if (abs(getprop("instrumentation/altimeter/indicated-altitude-ft")-me.vnav_alt.getValue())<50) {
                    # within target altitude: switch to VNAV ALT mode
                    idx=5;
                } else {
                    # outside target altitude: change flight level
		    me.alt_display.setValue(me.FMS_alt.getValue());
                    idx=12;
		}
                me.vertical_mode.setValue(idx);
            }
            me.AP_pitch_mode.setValue(me.pitch_list[idx]);
            me.AP_pitch_engaged.setBoolValue(idx>0);
	    if (me.flch_mode.getBoolValue() or idx == 8)
		msg = "ALT";
	    if (me.gs_armed.getBoolValue())
		msg = "LAND ARMED";
            me.AP_pitch_arm.setValue(msg);

        }elsif(me.step==4){             ### check speed modes  ###
	    if (me.ias_mach_selected.getBoolValue()) {
		var target = int(getprop("instrumentation/airspeed-indicator/indicated-speed-kt")+0.5);
		me.ias_setting.setValue(target);
	    } else {
                var target = (int(1000 * getprop("instrumentation/airspeed-indicator/indicated-mach"))) * 0.001;
		me.mach_setting.setValue(target);
	    }
            if (getprop("controls/engines/engine/reverser")) {
                # auto-throttle disables when reverser is enabled
                me.at1.setBoolValue(0);
                me.at2.setBoolValue(0);
            }
	    if (me.at2.getBoolValue() and radaralt > 100 and !me.autoland.getBoolValue())
		me.at1.setBoolValue(1);
#	    if (me.at1.getBoolValue() or (me.at2.getBoolValue() and getprop("engines/engine/rpm") > 60))
	    if (me.at1.getBoolValue()) {
		me.autothrottle_mode.setValue(5);
	    } elsif (me.at2.getBoolValue() and me.autoland.getBoolValue()) {
		me.ias_mach_selected.setBoolValue(0);
		if (radaralt < 200 and me.ias_setting.getValue() > 130)
		    me.ias_setting.setValue(130);
		if (radaralt > 80) {
		    me.autothrottle_mode.setValue(5);
		} else {
		    me.at2.setBoolValue(0);
		    me.autothrottle_mode.setValue(0);
		    setprop("controls/engines/engine[0]/throttle",0);
		    setprop("controls/engines/engine[1]/throttle",0);
		    setprop("controls/engines/engine[2]/throttle",0);
		}
	    } else {
		me.autothrottle_mode.setValue(0);
	    }
        }elsif(me.step==5){
	    max_wpt=getprop("/autopilot/route-manager/route/num");
	    atm_wpt=getprop("/autopilot/route-manager/current-wp");
	    if ((atm_wpt < 0 or atm_wpt >= max_wpt) and getprop("autopilot/route-manager/active"))
		setprop("autopilot/route-manager/active",0);

	    # LNAV error handler
	    var error_condition = 0;
	    if (getprop("autopilot/route-manager/active") and getprop("autopilot/route-manager/route/num") < 2) {
		error_condition = 1;
		if (me.errtrip[0] == 0) {
		    me.errtrip[0] = 1;
		    setprop("/sim/messages/copilot", me.errmsg[0]);
		}
	    } else {
		me.errtrip[0] = 0;
	    }
	    if (getprop("autopilot/route-manager/active") and getprop("autopilot/route-manager/departure/runway") == "") {
		error_condition = 1;
		if (me.errtrip[1] == 0) {
		    me.errtrip[1] = 1;
		    setprop("/sim/messages/copilot", me.errmsg[1]);
		}
	    } else {
		me.errtrip[1] = 0;
	    }

	    # LNAV course calculator
	    if (getprop("/autopilot/route-manager/active") and error_condition == 0) {

	    	if(atm_wpt < (max_wpt - 1)) {
		    me.remaining_distance.setValue(getprop("/autopilot/route-manager/wp/remaining-distance-nm") + getprop("autopilot/route-manager/wp/dist"));
	    	} else {
		    me.remaining_distance.setValue(getprop("autopilot/route-manager/wp/dist"));
	    	}

		var f = flightplan();
		var geocoord = geo.aircraft_position();

		var referenceCourse = f.pathGeod((max_wpt - 1), -getprop("autopilot/route-manager/distance-remaining-nm"));
		var courseCoord = geo.Coord.new().set_latlon(referenceCourse.lat, referenceCourse.lon);
		var CourseError = (geocoord.distance_to(courseCoord) / 1852) + 1;
		var change_wp = abs(getprop("/autopilot/route-manager/wp/bearing-deg") - getprop("orientation/heading-deg"));
		if(change_wp > 180) change_wp = (360 - change_wp);
		CourseError += (change_wp / 20);

		var targetCourse = f.pathGeod((max_wpt - 1), (-getprop("autopilot/route-manager/distance-remaining-nm") + CourseError));

		courseCoord = geo.Coord.new().set_latlon(targetCourse.lat, targetCourse.lon);
		CourseError = (geocoord.course_to(courseCoord) - getprop("orientation/heading-deg"));
		if(CourseError < -180) CourseError += 360;
		elsif(CourseError > 180) CourseError -= 360;
		setprop("autopilot/internal/course-error", CourseError);

		var leg = f.currentWP();
		var enroute = leg.courseAndDistanceFrom(targetCourse);
#		setprop("autopilot/internal/course-deg", enroute[0]);
		var groundspeed = getprop("/velocities/groundspeed-kt");
		if(enroute[1] != nil)
		{
		    var wpt_dist = getprop("autopilot/route-manager/wp/dist");
		    var wpt_eta = (wpt_dist / groundspeed * 3600);
		    var brg_err = getprop("/autopilot/route-manager/wp/true-bearing-deg") - getprop("/orientation/heading-deg");
		    if (brg_err < 0) {
			brg_err = brg_err + 360;
		    }
		    var wp_lead = 30;
		    change_wp = abs(getprop("/autopilot/route-manager/wp[1]/bearing-deg") - getprop("orientation/heading-deg"));
		    if (getprop("instrumentation/airspeed-indicator/indicated-speed-kt") < 240 and getprop("position/altitude-ft") < 10000) {
			wp_lead = 8;
#			brg_err = 0;
			change_wp = 0;
		    }
		    brg_err = math.pi * (brg_err / 180);
		    if (wpt_dist < 16) {
			wpt_eta = abs(wpt_eta * math.cos(brg_err));
		    }

		    if((getprop("gear/gear[1]/wow") == 0) and (getprop("gear/gear[1]/wow") == 0)) {
		    	if(change_wp > 180) change_wp = (360 - change_wp);
		    	if (((me.heading_change_rate * change_wp) > wpt_eta) or (wpt_eta < wp_lead)) {
			    if(atm_wpt < (max_wpt - 1)) {
			    	atm_wpt += 1;
			    	props.globals.getNode("/autopilot/route-manager/current-wp").setValue(atm_wpt);
			    }
		    	}
		    }
		}
	    }

	}elsif(me.step==6){
			ma_spd=getprop("/velocities/mach");
			banklimit=getprop("/instrumentation/afds/inputs/bank-limit-switch");
			if (banklimit==0 and ma_spd>0.85) {
			    lim=0;
			    me.heading_change_rate = 0.0;
			}
			if (banklimit==0 and ma_spd<=0.86 and ma_spd>0.6666) {
			    lim=10;
			    me.heading_change_rate = 2.45 * 0.7;
			}
			if (banklimit==0 and ma_spd<=0.6666 and ma_spd>0.5) {
			    lim=20;	
			    me.heading_change_rate = 1.125 * 0.7;
			}
			if (banklimit==0 and ma_spd<=0.5 and ma_spd>0.3333) {
			    lim=25;
			    me.heading_change_rate = 0.625 * 0.7;
			}
			if (banklimit==0 and ma_spd<=0.333) {
			    lim=30;
			    me.heading_change_rate = 0.55 * 0.7;
			}
			if (banklimit==0){
	        props.globals.getNode("/instrumentation/afds/settings/bank-max").setValue(lim);
			lim = -1 * lim;
			props.globals.getNode("/instrumentation/afds/settings/bank-min").setValue(lim);
			}
	}

        me.step+=1;
        if(me.step>6)me.step =0;

# Debugging status 'light'
        if (!me.status_light.getBoolValue() and (getprop("sim/time/elapsed-sec") - me.e_time > 2)) {
            me.status_light.setBoolValue(1);
            settimer( func {
                me.status_light.setBoolValue(0);
                me.e_time = getprop("sim/time/elapsed-sec");
            },0.2);
        }

    },
};
#####################


var afds = AFDS.new();

setlistener("/sim/signals/fdm-initialized", func {
    settimer(update_afds, 6);
	setprop("controls/switches/apoffsound", 1);
	afds.input(1,8);
	afds.input(0,1);
    print("AUTOFLIGHT ... FINE!");
});

var lim=30;
var max_wpt=1;
var atm_wpt=1;

var update_afds = func {
    if (!getprop("instrumentation/afds/inputs/reset")) {
        afds.ap_update();
        settimer(update_afds, 0);
    }
}

setlistener("autopilot/internal/disconnect-signal", func (sig) {
	if (sig.getBoolValue())
		afds.APyokebtn();
},0,0);

