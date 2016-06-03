var nd_display = {};

var myCockpit_switches = {
	# symbolic alias : relative property (as used in bindings), initial value, type
	'toggle_range': 	{path: '/inputs/range-nm', value:40, type:'INT'},
	'toggle_weather': 	{path: '/inputs/wxr', value:0, type:'BOOL'},
	'toggle_airports': 	{path: '/inputs/arpt', value:0, type:'BOOL'},
	'toggle_stations': 	{path: '/inputs/sta', value:0, type:'BOOL'},
	'toggle_waypoints': 	{path: '/inputs/wpt', value:0, type:'BOOL'},
	'toggle_position': 	{path: '/inputs/pos', value:0, type:'BOOL'},
	'toggle_data': 		{path: '/inputs/data',value:0, type:'BOOL'},
	'toggle_terrain': 	{path: '/inputs/terr',value:0, type:'BOOL'},
	'toggle_traffic': 		{path: '/inputs/tfc',value:0, type:'BOOL'},
	'toggle_centered': 		{path: '/inputs/nd-centered',value:0, type:'BOOL'},
	'toggle_lh_vor_adf':	{path: '/inputs/lh-vor-adf',value:0, type:'INT'},
	'toggle_rh_vor_adf':	{path: '/inputs/rh-vor-adf',value:0, type:'INT'},
	'toggle_display_mode': 	{path: '/mfd/display-mode', value:'MAP', type:'STRING'},
	'toggle_display_type': 	{path: '/mfd/display-type', value:'CRT', type:'STRING'},
	'toggle_true_north': 	{path: '/mfd/true-north', value:0, type:'BOOL'},
	'plan-wpt-index':	{path: '/inputs/plan/wpt-index', value:0, type:'INT'}
# add new switches here
};

var _list = setlistener("sim/signals/fdm-initialized", func() {

	var ND = common.NavScreen;
	var NDCpt = ND.new("instrumentation/efis", myCockpit_switches);
	
	nd_display.cpt = canvas.new({
		"name": "ND",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});

	nd_display.cpt.addPlacement({"node": "blackbkd"});
	var group = nd_display.cpt.createGroup();
	NDCpt.newNav(group, nd_display.cpt, "boeing");
	NDCpt.update();
	
#	var NDFo = ND.new("instrumentation/efis[1]", myCockpit_switches);

#	nd_display.fo = canvas.new({
#		"name": "ND",
#		"size": [1024, 1024],
#		"view": [1024, 1024],
#		"mipmapping": 1
#	});

#	nd_display.fo.addPlacement({"node": "ndScreenR"});
#	var group = nd_display.fo.createGroup();
#	NDFo.newNav(group, nd_display.fo, "boeing");
#	NDFo.update();

	removelistener(_list); #run ONCE because its only for waiting tillt he FDM is initialized
});

var showNd = func(pilot='cpt') {
	var dlg = canvas.Window.new([400, 400], "dialog");
	dlg.setCanvas( nd_display[pilot] );
}
