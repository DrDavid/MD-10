# ==============================================================================
# Boeing 747-400 EICAS by Gijs de Rooy
# ==============================================================================

var eng1n1 = {};
var eng1n1ref = {};
var eng2n1 = {};
var eng2n1ref = {};
var eng3n1 = {};
var eng3n1ref = {};
var text5655 = {};
var msgMemo = {};
var msgWarning = {};
var msgCaution = {};
var msgAdvisory = {};
var eng1n1rect = {};
var eng1n1maxLine = {};
var eng1n1refLine = {};
var eng1n1rpmLine = {};
var eng2n1maxLine = {};
var eng2n1refLine = {};
var eng2n1rpmLine = {};
var eng3n1maxLine = {};
var eng3n1refLine = {};
var eng3n1rpmLine = {};
var canvas_group = {};
var primary_dialog = {};
var eng1egt = {};
var eng2egt = {};
var eng3egt = {};
var fuelToRemain = {};
var fuelToRemainL = {};
var fuelTotal = {};
var fuelTemp = {};
var fuelTempL = {};
var text4283 = {};
var gearGrpBox = {};
var gearL = {};
var gearGrp = {};
var gear0 = {};
var gear0box = {};
var gear1 = {};
var gear1box = {};
var gear2 = {};
var gear2box = {};
var gear3 = {};
var gear3box = {};
var gear4 = {};
var gear4box = {};
var flapsLine = {};
var flapsL = {};
var flapsBar = {};
var flapsBar_scale = {};
var flapsBox = {};
var eng1nai = {};
var eng2nai = {};
var eng3nai = {};
var wai = {};
var eng1n1bar = {};
var eng2n1bar = {};
var eng3n1bar = {};
var eng1n1bar_scale = {};
var eng2n1bar_scale = {};
var eng3n1bar_scale = {};
var eng1egtBar = {};
var eng2egtBar = {};
var eng3egtBar = {};
var eng1egtBar_scale = {};
var eng2egtBar_scale = {};
var eng3egtBar_scale = {};
var primary_eicas = {};

var canvas_primary = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_primary] };
		
		var eicasP = canvas_group;
		
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(eicasP, "Aircraft/747-400/Models/Cockpit/Instruments/EICAS/primary.svg", {'font-mapper': font_mapper});
		
		eng1n1 = eicasP.getElementById("eng1n1");
		eng1n1ref = eicasP.getElementById("eng1n1ref");
		eng2n1 = eicasP.getElementById("eng2n1");
		eng2n1ref = eicasP.getElementById("eng2n1ref");
		eng3n1 = eicasP.getElementById("eng3n1");
		eng3n1ref = eicasP.getElementById("eng3n1ref");
		text5655 = eicasP.getElementById("text5655");
		msgMemo = eicasP.getElementById("msgMemo");
		msgWarning = eicasP.getElementById("msgWarning");
		msgCaution = eicasP.getElementById("msgCaution");
		msgAdvisory = eicasP.getElementById("msgAdvisory");
		eng1n1rect = eicasP.getElementById("eng1n1rect");
		eng1n1maxLine = eicasP.getElementById("eng1n1maxLine");
		eng1n1refLine = eicasP.getElementById("eng1n1refLine");
		eng1n1rpmLine = eicasP.getElementById("eng1n1rpmLine");
		eng2n1maxLine = eicasP.getElementById("eng2n1maxLine");
		eng2n1refLine = eicasP.getElementById("eng2n1refLine");
		eng2n1rpmLine = eicasP.getElementById("eng2n1rpmLine");
		eng3n1maxLine = eicasP.getElementById("eng3n1maxLine");
		eng3n1refLine = eicasP.getElementById("eng3n1refLine");
		eng3n1rpmLine = eicasP.getElementById("eng3n1rpmLine");
		rect3032 =  eicasP.getElementById("rect3032");
		eng1egt =  eicasP.getElementById("eng1egt");
		eng2egt =  eicasP.getElementById("eng2egt");
		eng3egt =  eicasP.getElementById("eng3egt");
		fuelToRemain =  eicasP.getElementById("fuelToRemain");
		fuelToRemainL =  eicasP.getElementById("fuelToRemainL");
		fuelTemp =  eicasP.getElementById("fuelTemp");
		fuelTempL =  eicasP.getElementById("fuelTempL");
		fuelTotal =  eicasP.getElementById("fuelTotal");
		text4283=  eicasP.getElementById("text4283");
		gearGrpBox =  eicasP.getElementById("gearBox");
		gearL =  eicasP.getElementById("gearL");
		gearGrp =  eicasP.getElementById("gear");
		gear0 =  eicasP.getElementById("gear0");
		gear0box =  eicasP.getElementById("gear0box");
		gear1 =  eicasP.getElementById("gear1");
		gear1box =  eicasP.getElementById("gear1box");
		gear2 =  eicasP.getElementById("gear2");
		gear2box =  eicasP.getElementById("gear2box");
		gear3 =  eicasP.getElementById("gear3");
		gear3box =  eicasP.getElementById("gear3box");
		gear4 =  eicasP.getElementById("gear4");
		gear4box =  eicasP.getElementById("gear4box");
		flapsLine =  eicasP.getElementById("flapsLine");
		flapsL =  eicasP.getElementById("flapsL");
		flapsBar =  eicasP.getElementById("flapsBar");
		flapsBox =  eicasP.getElementById("flapsBox");
		eng1nai=  eicasP.getElementById("eng1nai");
		eng2nai=  eicasP.getElementById("eng2nai");
		eng3nai=  eicasP.getElementById("eng3nai");
		wai=  eicasP.getElementById("wai");
		eng1n1bar = eicasP.getElementById("eng1n1bar").updateCenter();
		eng2n1bar = eicasP.getElementById("eng2n1bar").updateCenter();
		eng3n1bar = eicasP.getElementById("eng3n1bar").updateCenter();
		eng1egtBar = eicasP.getElementById("eng1egtBar").updateCenter();
		eng2egtBar = eicasP.getElementById("eng2egtBar").updateCenter();
		eng3egtBar = eicasP.getElementById("eng3egtBar").updateCenter();
		
		var c1 = eng1n1bar.getCenter();
		eng1n1bar.createTransform().setTranslation(-c1[0], -c1[1]);
		eng1n1bar_scale = eng1n1bar.createTransform();
		eng1n1bar.createTransform().setTranslation(c1[0], c1[1]);
		var c2 = eng2n1bar.getCenter();
		eng2n1bar.createTransform().setTranslation(-c2[0], -c2[1]);
		eng2n1bar_scale = eng2n1bar.createTransform();
		eng2n1bar.createTransform().setTranslation(c2[0], c2[1]);
		var c3 = eng3n1bar.getCenter();
		eng3n1bar.createTransform().setTranslation(-c3[0], -c3[1]);
		eng3n1bar_scale = eng3n1bar.createTransform();
		eng3n1bar.createTransform().setTranslation(c3[0], c3[1]);
		
		var c5 = eng1egtBar.getCenter();
		eng1egtBar.createTransform().setTranslation(-c5[0], -c5[1]);
		eng1egtBar_scale = eng1egtBar.createTransform();
		eng1egtBar.createTransform().setTranslation(c5[0], c5[1]);
		var c6 = eng2egtBar.getCenter();
		eng2egtBar.createTransform().setTranslation(-c6[0], -c6[1]);
		eng2egtBar_scale = eng2egtBar.createTransform();
		eng2egtBar.createTransform().setTranslation(c6[0], c6[1]);
		var c7 = eng3egtBar.getCenter();
		eng3egtBar.createTransform().setTranslation(-c7[0], -c7[1]);
		eng3egtBar_scale = eng3egtBar.createTransform();
		eng3egtBar.createTransform().setTranslation(c7[0], c7[1]);
		
		var c9 = flapsBar.getCenter();
		flapsBar.createTransform().setTranslation(-c9[0], -c9[1]);
		flapsBar_scale = flapsBar.createTransform();
		flapsBar.createTransform().setTranslation(c9[0], c9[1]);

		var timerFlaps = maketimer(10.0, func { text4283.hide();flapsLine.hide();flapsL.hide();flapsBar.hide();flapsBox.hide(); });
		setlistener("surface-positions/flap-pos-norm", func() {
			if (getprop("surface-positions/flap-pos-norm") == 0) {
				timerFlaps.singleShot = 1;
				timerFlaps.start(); # start the timer (with 1 second inverval)
			} else {
				timerFlaps.stop();
			}
		});
		timerFlaps.stop();
		
		var timerGear = maketimer(10.0, func { gearGrp.hide();gearL.hide();gearGrpBox.hide(); });
		setlistener("gear/gear/position-norm", func() {
			if (getprop("gear/gear/position-norm") == 0) {
				timerGear.singleShot = 1;
				timerGear.start(); # start the timer (with 1 second inverval)
			} else {
				timerGear.stop();
			}
		});
		
		return m;
	},
	update: func()
	{	
		var egt = [getprop("engines/engine/egt-degf"),getprop("engines/engine[1]/egt-degf"),getprop("engines/engine[2]/egt-degf")];
		var flaps = getprop("controls/flight/flaps");
		var flapPos = getprop("surface-positions/flap-pos-norm");
		var n1 = [getprop("engines/engine[0]/n1"),getprop("engines/engine[1]/n1"),getprop("engines/engine[2]/n1")];
		var throttle = [getprop("controls/engines/engine/throttle"),getprop("controls/engines/engine[1]/throttle"),getprop("controls/engines/engine[2]/throttle")];
		
		var engn1 = [eng1n1,eng2n1,eng3n1];
		var engn1maxLine = [eng1n1maxLine,eng2n1maxLine,eng3n1maxLine];
		var engn1rpmLine = [eng1n1rpmLine,eng2n1rpmLine,eng3n1rpmLine];
		var engn1ref = [eng1n1ref,eng2n1ref,eng3n1ref];
		var engn1refLine = [eng1n1refLine,eng2n1refLine,eng3n1refLine];
		var engn1bar = [eng1n1bar,eng2n1bar,eng3n1bar];
		var engn1bar_scale = [eng1n1bar_scale,eng2n1bar_scale,eng3n1bar_scale];
		var engegt = [eng1egt,eng2egt,eng3egt];
		var engegtBar = [eng1egtBar,eng2egtBar,eng3egtBar];
		var engegtBar_scale = [eng1egtBar_scale,eng2egtBar_scale,eng3egtBar_scale];
		var engnai = [eng1nai,eng2nai,eng3nai];
		
		for(var n = 0; n<=3; n+=1){
			if (getprop("controls/engines/engine["~n~"]/reverser")) {
				engn1ref[n].setText("REV");
				if (getprop("engines/engine["~n~"]/reverser-pos-norm") != 1) {
					engn1ref[n].setColor(1,0.5,0);
				} else {
					engn1ref[n].setColor(0,1.0,0);
				}
				engn1refLine[n].hide();
			} else {
				engn1ref[n].setText(sprintf("%3.01f",92.5*throttle[n]+25));
				engn1refLine[n].show();
				engn1refLine[n].setTranslation(0,-150.957*throttle[n]-64.043);
			}
			engn1[n].setText(sprintf("%3.01f",n1[n]));
			engn1maxLine[n].setTranslation(0,-175);
			engn1rpmLine[n].setTranslation(0,-215);
			if (n1[n] != nil){
				engn1bar_scale[n].setScale(1, n1[n]/117.5);
				if(n1[n] >= 117.5) {
					engn1bar[n].setColor(1,0,0);
				} else {
					engn1bar[n].setColor(1,1,1);
				}
			}
			if (egt[n] != nil) {
				engegt[n].setText(sprintf("%3.0f",(egt[n]-32)/1.8));
				engegtBar_scale[n].setScale(1, ((egt[n]-32)/1.8)/960);
				if ((egt[n]-32)/1.8 >= 960) {
					engegt[n].setColor(1,0,0);
					engegtBar[n].setColor(1,0,0);
				} elsif ((egt[n]-32)/1.8 >= 925) {
					engegt[n].setColor(1,0.5,0);
					engegtBar[n].setColor(1,0.5,0);
				} else {
					engegt[n].setColor(1,1,1);
					engegtBar[n].setColor(1,1,1);
				}
			}
			if (getprop("controls/anti-ice/engine["~n~"]/inlet-heat")) {
				engnai[n].show();
			} else {
				engnai[n].hide();
			}
		}
		
		text5655.setText(sprintf("%+03.0f",getprop("environment/temperature-degc")));
		fuelTotal.setText(sprintf("%03.01f",getprop("consumables/fuel/total-fuel-lbs")*LB2KG/1000));
		
		msgWarning.setText(getprop("instrumentation/eicas/msg/warning"));
		msgCaution.setText(getprop("instrumentation/eicas/msg/caution"));
		msgAdvisory.setText(getprop("instrumentation/eicas/msg/advisory"));
		msgMemo.setText(getprop("instrumentation/eicas/msg/memo"));

		if (flapPos != 0 or flaps != 0) {
			text4283.show();
			flapsLine.show();
			flapsL.show();
			flapsBar.show();
			flapsBox.show();
			text4283.setText(sprintf("%2.0f",flaps*30));
			flapsLine.setTranslation(0,157*flaps);
			text4283.setTranslation(0,157*flaps);
			flapsBar_scale.setScale(1, flapPos);
		}
		if (flaps != flapPos) {
			text4283.setColor(1,0,1);
			flapsLine.setColor(1,0,1);
		} else {
			text4283.setColor(0,1,0);
			flapsLine.setColor(0,1,0);
		}
		
		if (getprop("controls/anti-ice/wing-heat")) {
			wai.show();
		} else {
			wai.hide();
		}
		
		var gear = [gear0, gear1, gear2, gear3, gear4];
		var gearBox = [gear0box, gear1box, gear2box, gear3box, gear4box];
		var gearStuck = [getprop("/controls/failures/gear[0]/stuck"),getprop("/controls/failures/gear[1]/stuck"),getprop("/controls/failures/gear[2]/stuck"),getprop("/controls/failures/gear[3]/stuck"),getprop("/controls/failures/gear[4]/stuck")];
		var gearPos = [getprop("gear/gear[0]/position-norm"),getprop("gear/gear[1]/position-norm"),getprop("gear/gear[2]/position-norm"),getprop("gear/gear[3]/position-norm"),getprop("gear/gear[4]/position-norm")];
		
		if (gearStuck[0] or gearStuck[1] or gearStuck[2] or gearStuck[3] or gearStuck[4]) {
			
			gearGrp.hide();
			gearGrpBox.hide();
			gearL.show();
			
			for(var g = 0; g <= 4; g+=1){
				gear[g].show();
				gearBox[g].show();
				if(gearPos[g] == 1) {
					gear[g].setColor(0,1,0);
					gear[g].setText("DN");
					gearBox[g].setColor(0,1,0);
				} else {
					gear[g].setColor(1,1,1);
					if (gearPos[g] == 0)
						gear[g].setText("UP");
					else 
						gear[g].setText("");
					gearBox[g].setColor(1,1,1);
				}
			}
		} else {
			for(var g = 0; g <= 4; g+=1){
				gear[g].hide();
				gearBox[g].hide();
			}
			
			if (gearPos[0] == 0 and gearPos[1] == 0 and gearPos[2] == 0 and gearPos[3] == 0 and gearPos[4] == 0) {
				gearGrp.setText("UP");
				gearGrp.setColor(1,1,1);
				gearGrpBox.setColor(1,1,1);
			} elsif (gearPos[0] == 1 and gearPos[1] == 1 and gearPos[2] == 1 and gearPos[3] == 1 and gearPos[4] == 1) {
				gearGrp.setText("DOWN");
				gearGrp.setColor(0,1,0);
				gearGrpBox.setColor(0,1,0);
			}
		}
		
		settimer(func me.update(), 0);
	}
};

setlistener("/nasal/canvas/loaded", func {
	primary_eicas = canvas.new({
		"name": "EICASPrimary",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	primary_eicas.addPlacement({"node": "Upper-EICAS-Screen"});
	var group = primary_eicas.createGroup();
	var demo = canvas_primary.new(group);
	demo.update();
}, 1);

var showPrimaryEicas = func() {
	var dlg = canvas.Window.new([400, 400], "dialog");
	dlg.setCanvas(primary_eicas);
}