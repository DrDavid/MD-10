# McDonnell Douglas MD-10
# Multiplayer scripting
#########################

## Publish our properties over the MP network via /sim/multiplay/generic
var vals = props.globals.getNode("sim/multiplay/generic", 1);
var props_file = io.read_properties("Aircraft/MD-10/Systems/MD-10-multiplayer.xml");
foreach (var ref; props_file.getChildren("reference"))
{
	var prop = props.globals.getNode(ref.getNode("property").getValue(), 1);
	var val = vals.getChild(ref.getNode("type").getValue(), ref.getNode("index").getValue(), 1);
	val.alias(prop);
}
