# McDonnell Douglas MD-10
# Nasal door system
#########################

var Door =
{
	new: func(name, transit_time)
	{
		return aircraft.door.new("sim/model/door-positions/" ~ name, transit_time);
	}
};
var doors =
{
	pax_l1: Door.new("pax-l1", 3),
	pax_l2: Door.new("pax-l2", 3),
	pax_l3: Door.new("pax-l3", 3),
	pax_l4: Door.new("pax-l4", 3),
	pax_r1: Door.new("pax-r1", 3),
	pax_r2: Door.new("pax-r2", 3),
	pax_r3: Door.new("pax-r3", 3),
	pax_r4: Door.new("pax-r4", 3),
	cargo_fwd: Door.new("cargo-fwd", 3),
	cargo_aft: Door.new("cargo-aft", 3),
	cargo_main: Door.new("cargo-main", 3),
	boom: Door.new("boom", 5)
};
