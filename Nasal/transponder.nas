# Transponder control script for 747-8 TPR-901 Mode S transponder

var active_dig = 0;
var tmark = 0;

props.globals.initNode("instrumentation/transponder/inputs/clr[0]",0,"BOOL");
props.globals.initNode("instrumentation/transponder/inputs/clr[1]",0,"BOOL");
props.globals.initNode("instrumentation/transponder/inputs/clr[2]",0,"BOOL");
props.globals.initNode("instrumentation/transponder/inputs/clr[3]",0,"BOOL");

props.globals.initNode("instrumentation/transponder/inputs/display[0]",0,"INT");
props.globals.initNode("instrumentation/transponder/inputs/display[1]",0,"INT");
props.globals.initNode("instrumentation/transponder/inputs/display[2]",0,"INT");
props.globals.initNode("instrumentation/transponder/inputs/display[3]",0,"INT");

# Read a squawk code, set display digits
var xpnd_digits = func {
	var squawk = getprop("instrumentation/transponder/id-code");

	var d1 = int(int(squawk) / 1000);
	var d2 = int((int(squawk) - (1000*d1)) / 100);
	var d3 = int((int(squawk) - (1000*d1) - (100*d2)) / 10);
	var d4 = int(int(squawk) - (1000*d1) - (100*d2) - (10*d3));

	setprop("instrumentation/transponder/inputs/display",d1);
	setprop("instrumentation/transponder/inputs/display[1]",d2);
	setprop("instrumentation/transponder/inputs/display[2]",d3);
	setprop("instrumentation/transponder/inputs/display[3]",d4);
}

# Initialize the Transponder when the battery is turned on.
var xpnd_init = func {
	active_dig = 0;
	setprop("instrumentation/transponder/inputs/ident-btn",0);
	xpnd_digits();
	if (getprop("instrumentation/transponder/inputs/knob-pos") == 0) {
	    setprop("instrumentation/transponder/inputs/clr",1);
	    setprop("instrumentation/transponder/inputs/clr[1]",1);
	    setprop("instrumentation/transponder/inputs/clr[2]",1);
	    setprop("instrumentation/transponder/inputs/clr[3]",1);
	} else {
	    setprop("instrumentation/transponder/inputs/clr",0);
	    setprop("instrumentation/transponder/inputs/clr[1]",0);
	    setprop("instrumentation/transponder/inputs/clr[2]",0);
	    setprop("instrumentation/transponder/inputs/clr[3]",0);
	}
}
setlistener("systems/electrical/outputs/transponder", func(batt) {
	var knob = getprop("instrumentation/transponder/inputs/knob-pos");
	var mode = props.globals.getNode("instrumentation/transponder/inputs/knob-mode",1);

	if (batt.getValue() > 15 and mode.getValue() == 0) {
	    setprop("instrumentation/transponder/inputs/clr",0);
	    setprop("instrumentation/transponder/inputs/clr[1]",0);
	    setprop("instrumentation/transponder/inputs/clr[2]",0);
	    setprop("instrumentation/transponder/inputs/clr[3]",0);
	    setprop("instrumentation/transponder/inputs/display",8);
	    setprop("instrumentation/transponder/inputs/display[1]",8);
	    setprop("instrumentation/transponder/inputs/display[2]",8);
	    setprop("instrumentation/transponder/inputs/display[3]",8);
	    setprop("instrumentation/transponder/inputs/ident-btn",1);

	    if (knob == 0) mode.setValue(1);
	    if (knob == 1) mode.setValue(3);
	    if (knob == 2 or knob == 3) mode.setValue(5);
	
	    settimer(xpnd_init, 2);
	}
	if (batt.getValue() < 15) mode.setValue(0);
},0,0);

# If buttons are pushed but a new code is not entered, revert after 6 sec.
var xpnd_restore = func {
	var do_restore = func {
	    var curr_t = getprop("sim/time/elapsed-sec");
	    if (curr_t > (tmark + 5)) {
		xpnd_digits();
	        setprop("instrumentation/transponder/inputs/clr",0);
	        setprop("instrumentation/transponder/inputs/clr[1]",0);
	        setprop("instrumentation/transponder/inputs/clr[2]",0);
	        setprop("instrumentation/transponder/inputs/clr[3]",0);
	        active_dig = 0;
	    }
	}
	settimer(do_restore,6);
}

# CLR button control - clear the digits, replace with ----.
var xpnd_clr = func {
	setprop("instrumentation/transponder/inputs/clr",1);
	setprop("instrumentation/transponder/inputs/clr[1]",1);
	setprop("instrumentation/transponder/inputs/clr[2]",1);
	setprop("instrumentation/transponder/inputs/clr[3]",1);
	
	active_dig = 0;

	tmark = getprop("sim/time/elapsed-sec");
	xpnd_restore();
}
	
# Numbered button controls.
var xpnd_btns = func(btn) {
	var disp0 = props.globals.getNode("instrumentation/transponder/inputs/display",1);
	var disp1 = props.globals.getNode("instrumentation/transponder/inputs/display[1]",1);
	var disp2 = props.globals.getNode("instrumentation/transponder/inputs/display[2]",1);
	var disp3 = props.globals.getNode("instrumentation/transponder/inputs/display[3]",1);

	if (active_dig == 0) {
	    xpnd_clr();
	    setprop("instrumentation/transponder/inputs/clr",0);
	    disp0.setValue(btn);
	    active_dig = 1;
	}
	elsif (active_dig == 1) {
	    setprop("instrumentation/transponder/inputs/clr[1]",0);
	    disp1.setValue(btn);
	    tmark = getprop("sim/time/elapsed-sec");
	    xpnd_restore();
	    active_dig = 2;
	}
	elsif (active_dig == 2) {
	    setprop("instrumentation/transponder/inputs/clr[2]",0);
	    disp2.setValue(btn);
	    tmark = getprop("sim/time/elapsed-sec");
	    xpnd_restore();
	    active_dig = 3;
	}
	elsif (active_dig == 3) {
	    setprop("instrumentation/transponder/inputs/clr[3]",0);
	    disp3.setValue(btn);
	    tmark = getprop("sim/time/elapsed-sec");
	
	    var code = (1000*disp0.getValue()) + (100*disp1.getValue()) + (10*disp2.getValue()) + disp3.getValue();

	    setprop("instrumentation/transponder/id-code",(sprintf ("%04i", code)));
	    
	    active_dig = 0;
	}
}

# IDENT button control.
var xpnd_ident = func {
	var ident = props.globals.getNode("instrumentation/transponder/inputs/ident-btn",1);

	if (!(ident.getBoolValue())) {
	    ident.setBoolValue(1);
	    settimer(func { ident.setBoolValue(0); },18);
	}
}

# Mode knob control.
setlistener("instrumentation/transponder/inputs/knob-pos", func(knob) {
        var mode = props.globals.getNode("instrumentation/transponder/inputs/knob-mode",1);

	if (getprop("systems/electrical/outputs/transponder") < 15) {
	    mode.setValue(0);
	} else {
	    if (knob.getValue() == 0) mode.setValue(1);
	    if (knob.getValue() == 1) mode.setValue(3);
	    if (knob.getValue() == 2 or knob.getValue() == 3) mode.setValue(5);
	    if (knob.getValue() != 0) {
		setprop("instrumentation/transponder/inputs/clr",0);
		setprop("instrumentation/transponder/inputs/clr[1]",0);
		setprop("instrumentation/transponder/inputs/clr[2]",0);
		setprop("instrumentation/transponder/inputs/clr[3]",0);
	    }
	}
},0,0);

# Dialog control
setlistener("instrumentation/transponder/id-code", func (squawk) {
	xpnd_digits();
# Emergency code announce.
	if (squawk.getValue() == '7500') setprop("/sim/messages/copilot","Transponder squawking 7500 - Hijacking code!");
	if (squawk.getValue() == '7600') setprop("/sim/messages/copilot","Transponder squawking 7600 - LostComms code!");
	if (squawk.getValue() == '7700') setprop("/sim/messages/copilot","Transponder squawking 7700 - Emergency code!");
},0,0);

