####    jet engine electrical system    ####
####    Syd Adams    ####
<<<<<<< HEAD
var l_main_ac = props.globals.initNode("systems/electrical/L-MAIN-AC",0,"DOUBLE");
var c_main_ac = props.globals.initNode("systems/electrical/R-MAIN-AC",0,"DOUBLE");
var r_main_ac = props.globals.initNode("systems/electrical/R2-MAIN-AC",0,"DOUBLE");
var l_xfr = props.globals.initNode("systems/electrical/L-XFR",0,"DOUBLE");
var c_xfr = props.globals.initNode("systems/electrical/C-XFR",0,"DOUBLE");
var r_xfr = props.globals.initNode("systems/electrical/R-XFR",0,"DOUBLE");
var l_dc = props.globals.initNode("systems/electrical/L-DC",0,"DOUBLE");
var c_dc = props.globals.initNode("systems/electrical/C-DC",0,"DOUBLE");
var r_dc = props.globals.initNode("systems/electrical/R-DC",0,"DOUBLE");
var hot_bat = props.globals.initNode("systems/electrical/HOT-BAT",0,"DOUBLE");
var bat = props.globals.initNode("systems/electrical/BAT",0,"DOUBLE");
var cpt_flt_inst = props.globals.initNode("systems/electrical/CPT-FLT-INST",0,"DOUBLE");
var fo_flt_inst = props.globals.initNode("systems/electrical/FO-FLT-INST",0,"DOUBLE");
var l_gcb = props.globals.initNode("systems/electrical/L-GCB",0,"BOOL");
var c_gcb = props.globals.initNode("systems/electrical/C-GCB",0,"BOOL");
var r_gcb = props.globals.initNode("systems/electrical/R-GCB",0,"BOOL");
var apb = props.globals.initNode("systems/electrical/APB",0,"BOOL");
var pri_epc = props.globals.initNode("systems/electrical/PRI-EPC",0,"BOOL");
var sec_epc = props.globals.initNode("systems/electrical/SEC-EPC",0,"BOOL");
var l_btb = props.globals.initNode("systems/electrical/L-BTB",0,"BOOL");
var c_btb = props.globals.initNode("systems/electrical/C-BTB",0,"BOOL");
var r_btb = props.globals.initNode("systems/electrical/R-BTB",0,"BOOL");
var main_bat_rly = props.globals.initNode("systems/electrical/MAIN-BAT-RLY",0,"BOOL");
var dc_bus_tie_rly = props.globals.initNode("systems/electrical/DC_BUS_TIE_RLY",1,"BOOL");
var bat_cpt_isln_rely = props.globals.initNode("systems/electrical/BAT-CPT-ISLN-RLY",1,"BOOL");
var cpt_fo_bus_tie_rely = props.globals.initNode("systems/electrical/CPT-FO-BUS-TIE-RLY",0,"BOOL");
var primary_external  = props.globals.initNode("controls/electric/external-power",0,"BOOL");
var secondary_external  = props.globals.initNode("controls/electric/external-power[1]",0,"BOOL");
var ac_tie_bus = props.globals.initNode("systems/electrical/AC_TIE_BUS",0,"DOUBLE");

var vbus_count = 0;
var Lbus = props.globals.initNode("systems/electrical/left-bus",0,"DOUBLE");
var Cbus = props.globals.initNode("systems/electrical/center-bus",0,"DOUBLE");
var Rbus = props.globals.initNode("systems/electrical/right-bus",0,"DOUBLE");
var AVswitch=props.globals.initNode("systems/electrical/outputs/avionics",0,"BOOL");
var APUgen=props.globals.initNode("controls/electric/APU-generator",0,"BOOL");
var CDUswitch=props.globals.initNode("instrumentation/cdu/serviceable",0,"BOOL");
var DomeLtControl=props.globals.initNode("controls/lighting/dome-intencity",0,"DOUBLE");
var DomeLtIntencity=props.globals.initNode("systems/electrical/domelight-int",0,"DOUBLE");
var landinglights=props.globals.initNode("controls/lighting/landing-lights",0,"BOOL");
=======
var count=0;
var ammeter_ave = 0.0;
var Lbus = props.globals.initNode("/systems/electrical/left-bus",0,"DOUBLE");
var Rbus = props.globals.initNode("/systems/electrical/right-bus",0,"DOUBLE");
var Amps = props.globals.initNode("/systems/electrical/amps",0,"DOUBLE");
var EXT  = props.globals.initNode("/controls/electric/external-power",0,"DOUBLE");
var XTie  = props.globals.initNode("/systems/electrical/xtie",0,"BOOL");
var APUgen=props.globals.initNode("controls/electric/APU-generator",0,"BOOL");
var extpwr=props.globals.initNode("controls/electric/external-power",0,"BOOL");
var lbus_volts = 0.0;
var rbus_volts = 0.0;
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77

var lbus_input=[];
var lbus_output=[];
var lbus_load=[];

<<<<<<< HEAD
var cbus_input=[];
var cbus_output=[];
var cbus_load=[];

=======
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
var rbus_input=[];
var rbus_output=[];
var rbus_load=[];

var lights_input=[];
var lights_output=[];
var lights_load=[];

<<<<<<< HEAD
var strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("controls/lighting/strobe-state", [0.05, 1.30], strobe_switch);
var beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("controls/lighting/beacon-state", [0.05, 2.0], beacon_switch);

var APU = {
	new : func(generator)
	{
		var m = { parents : [APU] };
		m.generator = generator;
		m.valid = 0;
		return m;
	},
	
	get_transition : func
	{
		var switched = 0;
		if(me.valid == 0)
		{
			if(me.generator.getValue() == 1)
			{
				apb.setValue(1);
				me.valid = 1;
				switched = 1;
			}
		}
		else
		{
			if(me.generator.getValue() == 0)
			{
				apb.setValue(0);
				me.valid = 0;
				switched = 1;
			}
		}
		return switched;
	}
};

var External = {
	new : func(switch)
	{
		var m = { parents : [External] };
		m.valid = 0;
		m.switch = switch;
		return m;
	},
	
	get_transition : func
	{
		var switched = 0;
		if(me.valid == 0)
		{
			if(me.switch.getValue() == 1)
			{
				me.valid = 1;
				switched = 1;
			}
		}
		else
		{
			if(me.switch.getValue() == 0)
			{
				me.valid = 0;
				switched = 1;
			}
		}
		return switched;
	}
};

var Battery = {
    new : func(vlt,amp,hr,chp,cha){
        var m = { parents : [Battery] };

        m.ideal_volts = vlt;
        m.ideal_amps = amp;
        m.amp_hours = hr;
        m.charge_percent = chp;
        m.charge_amps = cha;

        return m;
=======
#var battery = Battery.new(switch-prop,volts,amps,amp_hours,charge_percent,charge_amps);
var Battery = {
    new : func(swtch,vlt,amp,hr,chp,cha){
    m = { parents : [Battery] };
            m.switch = props.globals.getNode(swtch,1);
            m.switch.setBoolValue(0);
            m.ideal_volts = vlt;
            m.ideal_amps = amp;
            m.amp_hours = hr;
            m.charge_percent = chp;
            m.charge_amps = cha;
    return m;
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
    },

    apply_load : func(load,dt) {
        if(me.switch.getValue()){
<<<<<<< HEAD
            var amphrs_used = load * dt / 3600.0;
            var percent_used = amphrs_used / me.amp_hours;
            me.charge_percent -= percent_used;
            if ( me.charge_percent < 0.0 ) {
                me.charge_percent = 0.0;
            } elsif ( me.charge_percent > 1.0 ) {
                me.charge_percent = 1.0;
            }
            var output = me.amp_hours * me.charge_percent;
            return output;
        } else
            return 0;
    },

    get_output_volts : func {
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_volts * factor;
            return output;
    },

    get_output_amps : func {
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_amps * factor;
            return output;
    }
};
# var alternator = Alternator.new(num,switch,rpm_source,rpm_threshold,volts,amps);
var Alternator = {
    new : func (num,switch,src,thr,vlt,amp){
        var m = { parents : [Alternator] };
        m.switch =  props.globals.getNode(switch,1);
        m.switch.setBoolValue(0);
	    m.meter =  props.globals.getNode("systems/electrical/gen-load["~num~"]",1);
    	m.gen_output =  props.globals.getNode("engines/engine["~num~"]/amp-v",1);
        m.meter.setDoubleValue(0);
        m.gen_output.setDoubleValue(0);
=======
        var amphrs_used = load * dt / 3600.0;
        var percent_used = amphrs_used / me.amp_hours;
        me.charge_percent -= percent_used;
        if ( me.charge_percent < 0.0 ) {
            me.charge_percent = 0.0;
        } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
        }
        var output =me.amp_hours * me.charge_percent;
        return output;
        }else return 0;
    },

    get_output_volts : func {
        if(me.switch.getValue()){
        var x = 1.0 - me.charge_percent;
        var tmp = -(3.0 * x - 1.0);
        var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
        var output =me.ideal_volts * factor;
        return output;
        }else return 0;
    },

    get_output_amps : func {
        if(me.switch.getValue()){
        var x = 1.0 - me.charge_percent;
        var tmp = -(3.0 * x - 1.0);
        var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
        var output =me.ideal_amps * factor;
        return output;
        }else return 0;
    }
};

# var alternator = Alternator.new(num,switch,gen_output,rpm_source,rpm_threshold,volts,amps);
var Alternator = {
    new : func (num,switch,gen_output,src,thr,vlt,amp){
        m = { parents : [Alternator] };
        m.switch =  props.globals.getNode(switch,1);
        m.switch.setBoolValue(1); # TODO: Change this to 0
        m.meter =  props.globals.getNode("systems/electrical/gen-load["~num~"]",1);
        m.meter.setDoubleValue(0);
        m.gen_output =  props.globals.getNode(gen_output,1);
        m.gen_output.setDoubleValue(0);
        m.meter.setDoubleValue(0);
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
        m.rpm_source =  props.globals.getNode(src,1);
        m.rpm_threshold = thr;
        m.ideal_volts = vlt;
        m.ideal_amps = amp;
<<<<<<< HEAD
		m.valid = 0;
        return m;
    },


    apply_load : func(load) {
        var cur_volt = me.gen_output.getValue();
        var cur_amp  = me.meter.getValue();
        var gout = 0;
        if(cur_volt >1){
            var factor = 1/cur_volt;
            var gout = (load * factor);
            if(gout>1)gout=1;
=======
        return m;
    },

    apply_load : func(load) {
        var cur_volt=me.gen_output.getValue();
        var cur_amp=me.meter.getValue();
        if(cur_volt >1){
            var factor=1/cur_volt;
            gout = (load * factor);
            if(gout>1)gout=1;
        }else{
            gout=0;
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
        }
        me.meter.setValue(gout);
    },

    get_output_volts : func {
        var out = 0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold or 0;
            if ( factor > 1.0 )factor = 1.0;
            var out = (me.ideal_volts * factor);
        }
        me.gen_output.setValue(out);
        return out;
    },

    get_output_amps : func {
<<<<<<< HEAD
        var ampout = 0;
=======
        var ampout =0;
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold or 0;
            if ( factor > 1.0 ) {
                factor = 1.0;
            }
            ampout = me.ideal_amps * factor;
        }
        return ampout;
<<<<<<< HEAD
    },

	get_transition : func
	{
	var switched = 0;
		if(me.valid == 0)
		{
			if(me.get_output_volts() > 90)
			{
				me.valid = 1;
				switched = 1;
			}
		}
		else
		{
			if(me.get_output_volts() < 70)
			{
				me.valid = 0;
				switched = 1;
			}
		}
		return switched;
	}
};

var battery = Battery.new(24,30,34,1.0,7.0);
var lidg = Alternator.new(0,"controls/electric/engine[0]/gen-switch","/engines/engine[0]/rpm",17.0,115.0,60.0);
var cidg = Alternator.new(1,"controls/electric/engine[1]/gen-switch","/engines/engine[1]/rpm",17.0,115.0,60.0);
var ridg = Alternator.new(2,"controls/electric/engine[2]/gen-switch","/engines/engine[2]/rpm",17.0,115.0,60.0);
var external_primary = External.new(pri_epc);
var external_secondary = External.new(sec_epc);
var apu = APU.new(APUgen);

#####################################
setlistener("sim/signals/fdm-initialized", func {
    init_switches();
    settimer(update_electrical,5);
});

var init_switches = func{
    setprop("controls/lighting/instruments-norm",0.8);
    setprop("controls/lighting/engines-norm",0.8);
    props.globals.initNode("controls/electric/ammeter-switch",0,"BOOL");
    props.globals.getNode("systems/electrical/serviceable",0,"BOOL");
    props.globals.getNode("controls/electric/external-power",0,"BOOL");
    props.globals.getNode("controls/electric/external-power[1]",0,"BOOL");
    setprop("controls/lighting/instrument-lights-norm",0.8);
    setprop("controls/lighting/efis-norm",0.8);
    setprop("controls/lighting/panel-norm",0.8);
    setprop("controls/electric/battery-switch",0);
    setprop("controls/electric/engine/gen-switch",1);
    setprop("controls/electric/engine[1]/gen-switch",1);
	setprop("controls/electric/engine[2]/gen-switch",1);
    setprop("controls/electric/engine/bus-tie",1);
    setprop("controls/electric/engine[1]/bus-tie",1);
    setprop("controls/electric/engine[2]/bus-tie",1);
    setprop("controls/APU/apu-gen-switch",0);
    setprop("controls/electric/engine/gen-bu-switch",1);
    setprop("controls/electric/engine[1]/gen-bu-switch",1);
    setprop("controls/electric/engine[2]/gen-bu-switch",1);
    setprop("controls/lighting/nav-lights",0);
    setprop("controls/lighting/beacon",0);
	landinglights.setValue(0);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light[0]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[0]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light[1]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[1]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light[2]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[2]",0,"DOUBLE"));
=======
    }
};

var battery = Battery.new("/controls/electric/battery-switch",24,30,34,1.0,7.0);
var alternator1 = Alternator.new(0,"controls/electric/engine[0]/generator","/engines/engine[0]/amp-v","/engines/engine[0]/rpm",20.0,28.0,60.0);
var alternator2 = Alternator.new(1,"controls/electric/engine[1]/generator","/engines/engine[1]/amp-v","/engines/engine[1]/rpm",20.0,28.0,60.0);
var alternator3 = Alternator.new(2,"controls/electric/engine[2]/generator","/engines/engine[2]/amp-v","/engines/engine[2]/rpm",20.0,28.0,60.0);
#var alternator4 = Alternator.new(3,"controls/electric/APU-generator","/engines/apu/amp-v","/engines/apu/rpm",80.0,24.0,60.0);

#####################################
setlistener("/sim/signals/fdm-initialized", func {
    init_switches();
    settimer(update_electrical,5);
    print("Electrical System ... ok");
});

var init_switches = func{
    var AVswitch=props.globals.initNode("controls/electric/avionics-switch",1,"BOOL");
    setprop("controls/lighting/instruments-norm",0.8);
    props.globals.initNode("controls/electric/ammeter-switch",0,"BOOL");
    props.globals.getNode("systems/electrical/serviceable",0,"BOOL");
    props.globals.getNode("controls/electric/external-power",0,"BOOL");
    setprop("controls/lighting/instrument-lights-norm",0.8);
    setprop("controls/lighting/panel-norm",0.8);

    append(lights_input,props.globals.initNode("controls/lighting/landing-light-port",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light-port",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light-nose[0]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light-nose[0]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light-nose[1]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light-nose[1]",0,"DOUBLE"));
    append(lights_load,1);

    append(lights_input,props.globals.initNode("controls/lighting/landing-light-butt[0]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light-butt[0]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light-butt[1]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light-butt[1]",0,"DOUBLE"));
    append(lights_load,1);

    append(lights_input,props.globals.initNode("controls/lighting/landing-light-stbd",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light-stbd",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/panel-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/panel-lights",0,"DOUBLE"));
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/nav-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/nav-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/cabin-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/cabin-lights",0,"DOUBLE"));
    append(lights_load,1);
<<<<<<< HEAD
    append(lights_input,props.globals.initNode("controls/lighting/map-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/map-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/wing-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/wing-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/recog-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/recog-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/logo-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/logo-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/taxi-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/taxi-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/beacon-state/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/beacon",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/strobe-state/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/strobe",0,"DOUBLE"));
    append(lights_load,1);

=======
    append(lights_input,props.globals.initNode("controls/lighting/wing-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/wing-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/logo-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/logo-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/instrument-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/instrument-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("sim/model/lights/beacon[0]/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/beacon[0]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("sim/model/lights/beacon[1]/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/beacon[1]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("sim/model/lights/strobe[0]/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/strobe[0]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("sim/model/lights/strobe[1]/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/strobe[1]",0,"DOUBLE"));
    append(lights_load,1);

    append(rbus_input,AVswitch);
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/autopilot[0]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,AVswitch);
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/autopilot[1]",0,"DOUBLE"));
    append(rbus_load,1);
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
    append(rbus_input,props.globals.initNode("controls/electric/wiper-switch",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/wiper",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[0]/fuel-pump",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/fuel-pump[0]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[1]/fuel-pump",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/fuel-pump[1]",0,"DOUBLE"));
    append(rbus_load,1);
<<<<<<< HEAD
	append(rbus_input,props.globals.initNode("controls/engines/engine[2]/fuel-pump",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/fuel-pump[2]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/StartIgnition-knob[0]",0,"DOUBLE"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/StartIgnition-knob[1]",0,"DOUBLE"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter[1]",0,"DOUBLE"));
    append(rbus_load,1);
	append(rbus_input,props.globals.initNode("controls/engines/StartIgnition-knob[2]",0,"DOUBLE"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter[2]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,AVswitch);
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/KNS80",0,"DOUBLE"));
    append(rbus_load,1);


    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/efis",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/adf",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/dme",0,"DOUBLE"));
=======
    append(rbus_input,props.globals.initNode("controls/engines/engine[0]/starter",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[1]/starter",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter[1]",0,"DOUBLE"));
    append(rbus_load,1);

    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/adf",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/dme[0]",0,"DOUBLE"));
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/gps",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
<<<<<<< HEAD
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/DG",0,"DOUBLE"));
=======
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/efis",0,"DOUBLE"));
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/transponder",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/mk-viii",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/turn-coordinator",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/comm",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/comm[1]",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/nav",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/nav[1]",0,"DOUBLE"));
    append(lbus_load,1);
<<<<<<< HEAD
}

update_virtual_bus = func( dt ) {
    var PWR = getprop("systems/electrical/serviceable");
    var xtie = 0;
    var load = 0.0;
    var power_source = nil;
	if(lidg.get_transition())
	{
		l_gcb.setValue(lidg.valid);
		if(lidg.valid)
		{
			apb.setValue(0);
			pri_epc.setValue(0);
			sec_epc.setValue(0);
			l_btb.setValue(1);
			r_btb.setValue(1);
		}
	}
	elsif(ridg.get_transition())
	{
		r_gcb.setValue(ridg.valid);
		if(ridg.valid)
		{
			apb.setValue(0);
			pri_epc.setValue(0);
			sec_epc.setValue(0);
			l_btb.setValue(1);
			r_btb.setValue(1);
		}
	}
	elsif(external_primary.get_transition())
	{
		if(external_primary.valid)
		{
			r_gcb.setValue(0);
			if(external_secondary.valid)
			{
				r_btb.setValue(0);
			}
			else
			{
				l_gcb.setValue(0);
				apb.setValue(0);
				l_btb.setValue(1);
				r_btb.setValue(1);
			}
		}
	}
	elsif(external_secondary.get_transition())
	{
		if(external_secondary.valid)
		{
			apb.setValue(0);
			l_gcb.setValue(0);
			l_btb.setValue(1);
			if(external_primary.valid)
			{
				r_btb.setValue(0);
			}
			else
			{
				r_gcb.setValue(0)
			}
		}
	}
	elsif(apu.get_transition())
	{
		if(apu.valid)
		{
			sec_epc.setValue(0);
			l_btb.setValue(1);
			if(external_primary.valid)
			{
				r_btb.setValue(0);
			}
			else
			{
				r_gcb.setValue(0);
			}
		}
	}

	if(lidg.valid)
	{
		l_main_ac.setValue(lidg.get_output_volts());
	}
	elsif(apu.valid)
	{
		l_main_ac.setValue(115);
	}
	elsif(external_secondary.valid)
	{
		l_main_ac.setValue(115);
	}
	elsif(external_primary.valid)
	{
		l_main_ac.setValue(115);
	}
	elsif(ridg.valid)
	{
		l_main_ac.setValue(ridg.get_output_volts());
	}
	else
	{
		l_main_ac.setValue(0);
	}
	l_xfr.setValue(l_main_ac.getValue());
	
	
	if(cidg.valid)
	{
		c_main_ac.setValue(cidg.get_output_volts());
	}
	elsif(external_primary.valid)
	{
		c_main_ac.setValue(115);
	}
	elsif(external_secondary.valid)
	{
		c_main_ac.setValue(115);
	}
	elsif(apu.valid)
	{
		c_main_ac.setValue(115);
	}
	elsif(lidg.valid)
	{
		c_main_ac.setValue(lidg.get_output_volts());
	}
	
		
	if(ridg.valid)
	{
		r_main_ac.setValue(ridg.get_output_volts());
	}
	elsif(external_primary.valid)
	{
		r_main_ac.setValue(115);
	}
	elsif(external_secondary.valid)
	{
		r_main_ac.setValue(115);
	}
	elsif(apu.valid)
	{
		r_main_ac.setValue(115);
	}
	elsif(lidg.valid)
	{
		r_main_ac.setValue(lidg.get_output_volts());
	}
	
	
	else
	{
		r_main_ac.setValue(0);
	}
	r_xfr.setValue(r_main_ac.getValue());

	if(lidg.valid or apu.valid or external_secondary.valid or external_primary.valid or ridg.valid)
	{
		ac_tie_bus.setValue(115);
	}
	else
	{
		ac_tie_bus.setValue(0);
	}

	if(vbus_count==0)
	{
        hot_bat.setValue(battery.get_output_volts());
		main_bat_rly.setValue(getprop("controls/electric/battery-switch"));
		bat.setValue(hot_bat.getValue() * main_bat_rly.getValue());
		if(l_xfr.getValue() > 80)
		{
			l_dc.setValue(l_xfr.getValue() * 28 /115);
			cpt_flt_inst.setValue(l_xfr.getValue() * 28 /115);
			lidg.apply_load(load);
		}
		else
		{
			l_dc.setValue(0);
			cpt_flt_inst.setValue(bat.getValue() * bat_cpt_isln_rely.getValue());
#			battery.apply_load(load);
		}
		load += lh_bus(cpt_flt_inst.getValue());
    }
	else
	{
		if(r_xfr.getValue() > 80)
		{
			r_dc.setValue(r_xfr.getValue() * 28 /115);
			fo_flt_inst.setValue(r_xfr.getValue() * 28 /115);
			ridg.apply_load(load);
		}
		else
		{
			r_dc.setValue(0);
			fo_flt_inst.setValue(cpt_flt_inst.getValue() * cpt_fo_bus_tie_rely.getValue());
#			battery.apply_load(load);
		}
		load += rh_bus(fo_flt_inst.getValue());
    }
	

	
    vbus_count = 1-vbus_count;
    if(l_dc.getValue() > 5 and r_dc.getValue() > 5) xtie=1;
    dc_bus_tie_rly.setValue(xtie);
	if(l_dc.getValue() > 5 or r_dc.getValue() > 5) load += lighting(28);

	if(r_xfr.getValue() > 80)
	{
		DomeLtIntencity.setValue(DomeLtControl.getValue());
	}
	elsif(cpt_flt_inst.getValue() > 24)
	{
		DomeLtIntencity.setValue(0.5);
	}
	else
	{
		DomeLtIntencity.setValue(0);
	}

    return load;
=======
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/dme[0]",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/dme[1]",0,"DOUBLE"));
    append(lbus_load,1);
}


update_virtual_bus = func( dt ) {
    var PWR = getprop("systems/electrical/serviceable");
    var xtie=0;
    load = 0.0;
    power_source = nil;
    if(count==0){
        var battery_volts = battery.get_output_volts();
        lbus_volts = battery_volts;
        power_source = "battery";
        if (extpwr.getValue() and getprop("velocities/groundspeed-kt") < 1)
        {
            power_source = "external";
            lbus_volts = 28;
        }
        elsif (APUgen.getValue())
        {
            power_source = "APU";
            var alternator4_volts = alternator4.get_output_volts();
            lbus_volts = alternator4_volts;
        }
        var alternator1_volts = alternator1.get_output_volts();
        if (alternator1_volts > lbus_volts) {
            lbus_volts = alternator1_volts;
            power_source = "alternator1";
        }
        var alternator2_volts = alternator2.get_output_volts();
        if (alternator2_volts > rbus_volts) {
            rbus_volts = alternator2_volts;
            power_source = "alternator2";
        }
        lbus_volts *=PWR;
        Lbus.setValue(lbus_volts);
        load += lh_bus(lbus_volts);
            alternator1.apply_load(load);
            alternator2.apply_load(load);
    }else{
        var battery_volts = battery.get_output_volts();
        rbus_volts = battery_volts;
        power_source = "battery";
        if (extpwr.getValue() and getprop("velocities/groundspeed-kt") < 1)
        {
            power_source = "external";
            rbus_volts = 28;
        }
        elsif (APUgen.getValue())
        {
            power_source = "APU";
            var alternator4_volts = alternator4.get_output_volts();
            rbus_volts = alternator4_volts;
        }
        var alternator3_volts = alternator3.get_output_volts();
        if (alternator3_volts > rbus_volts) {
            rbus_volts = alternator3_volts;
            power_source = "alternator3";
        }
        var alternator2_volts = alternator2.get_output_volts();
        if (alternator2_volts > rbus_volts) {
            rbus_volts = alternator2_volts;
            power_source = "alternator2";
        }
        rbus_volts *=PWR;
        Rbus.setValue(rbus_volts);
        load += rh_bus(rbus_volts);
        alternator3.apply_load(load);
        alternator2.apply_load(load);
    }
    count=1-count;
    if(rbus_volts > 5 and  lbus_volts>5) xtie=1;
    XTie.setValue(xtie);
    if(rbus_volts > 5 or  lbus_volts>5) load += lighting(24);

    ammeter = 0.0;

return load;
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
}

rh_bus = func(bv) {
    var bus_volts = bv;
    var load = 0.0;
    var srvc = 0.0;

    for(var i=0; i<size(rbus_input); i+=1) {
        var srvc = rbus_input[i].getValue();
        load += rbus_load[i] * srvc;
        rbus_output[i].setValue(bus_volts * srvc);
    }
    return load;
}

<<<<<<< HEAD
ch_bus = func(bv) {
    var bus_volts = bv;
    var load = 0.0;
    var srvc = 0.0;

    for(var i=0; i<size(cbus_input); i+=1) {
        var srvc = cbus_input[i].getValue();
        load += cbus_load[i] * srvc;
        cbus_output[i].setValue(bus_volts * srvc);
    }
    return load;
}

=======
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
lh_bus = func(bv) {
    var load = 0.0;
    var srvc = 0.0;

    for(var i=0; i<size(lbus_input); i+=1) {
        var srvc = lbus_input[i].getValue();
        load += lbus_load[i] * srvc;
        lbus_output[i].setValue(bv * srvc);
    }

<<<<<<< HEAD
    var isEnabled = (bv>20);
    if (AVswitch.getBoolValue()!=isEnabled)
        AVswitch.setBoolValue(isEnabled);
    if (CDUswitch.getBoolValue()!=isEnabled)
        CDUswitch.setBoolValue(isEnabled);
=======
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
    setprop("systems/electrical/outputs/flaps",bv);
    return load;
}

lighting = func(bv) {
    var load = 0.0;
    var srvc = 0.0;
    var ac=bv*4.29;

    for(var i=0; i<size(lights_input); i+=1) {
        var srvc = lights_input[i].getValue();
        load += lights_load[i] * srvc;
        lights_output[i].setValue(bv * srvc);
    }

<<<<<<< HEAD
    return load;
=======
return load;

>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
}

update_electrical = func {
    var scnd = getprop("sim/time/delta-sec");
    update_virtual_bus( scnd );
<<<<<<< HEAD
    settimer(update_electrical, 0.2);
=======
>>>>>>> 7cfb14060b50d8a644f666df80a92ca6992ffc77
}
