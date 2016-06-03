# McDonnell Douglas MD-10
# Engine control system
#########################

# NOTE: Update functions are called in systems.nas

# default fuel density (for YASim jets this is 6.72 lb/gal)
var fuel_density = 6.72;

var engine =
{
	new: func(no)
	{
		var m =
		{
			parents: [engine]
		};
		m.number = no;
		m.started = 0;
		m.max_start_n1 = 5.21;
		m.throttle_at_idle = 0.02;
		
		m.cutoff = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/cutoff", 1);
		m.cutoff.setBoolValue(0);
		m.fuel_flow_gph = props.globals.getNode("engines/engine[" ~ no ~ "]/fuel-flow-gph", 1);
		m.fuel_flow_gph.setValue(0);
		m.fuel_flow_pph = props.globals.getNode("engines/engine[" ~ no ~ "]/fuel-flow_pph", 1);
		m.fuel_flow_pph.setValue(0);
		m.n1 = props.globals.getNode("engines/engine[" ~ no ~ "]/n1", 1);
		m.n1.setValue(0);
		m.out_of_fuel = props.globals.getNode("engines/engine[" ~ no ~ "]/out-of-fuel", 1);
		m.out_of_fuel.setBoolValue(0);
		m.on_fire = props.globals.getNode("engines/engine[" ~ no ~ "]/on-fire", 1);
		m.on_fire.setBoolValue(0);
		m.reverser = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/reverser", 1);
		m.reverser.setBoolValue(0);
		m.rpm = props.globals.getNode("engines/engine[" ~ no ~ "]/rpm", 1);
		m.rpm.setValue(0);
		m.running = props.globals.getNode("engines/engine[" ~ no ~ "]/running", 1);
		m.running.setBoolValue(0);
		m.serviceable = props.globals.getNode("sim/failure-manager/engines/engine[" ~ no ~ "]/serviceable", 1);
		m.serviceable.setBoolValue(1);
		m.starter = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/starter", 1);
		m.starter.setBoolValue(0);
		m.throttle = props.globals.getNode("fcs/throttle-cmd-norm[" ~ no ~ "]", 1);
		m.throttle.setValue(0);
		m.throttle_lever = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/throttle-lever", 1);
		m.throttle_lever.setValue(0);

		return m;
	},
	update: func
	{
		if (me.running.getBoolValue() and !me.started)
		{
			me.running.setBoolValue(0);
		}
		if (me.on_fire.getBoolValue())
		{
			me.serviceable.setBoolValue(0);
		}
		if (me.cutoff.getBoolValue() or !me.serviceable.getBoolValue() or me.out_of_fuel.getBoolValue())
		{
			var rpm = me.rpm.getValue();
			if (me.starter.getBoolValue())
			{
				rpm += getprop("sim/time/delta-realtime-sec") * 2;
				me.rpm.setValue(rpm >= me.max_start_n1 ? me.max_start_n1 : rpm);
			}
			else
			{
				rpm -= getprop("sim/time/delta-realtime-sec") * 4;
				me.rpm.setValue(rpm <= 0 ? 0 : rpm);
				me.running.setBoolValue(0);
				me.throttle_lever.setValue(0);
				me.started = 0;
			}
		}
		elsif (me.starter.getBoolValue())
		{
			var rpm = me.rpm.getValue();
			if (rpm >= 3)
			{
				rpm += getprop("sim/time/delta-realtime-sec") * 4;
				me.rpm.setValue(rpm);
				if (rpm >= me.n1.getValue())
				{
					me.running.setBoolValue(1);
					me.starter.setBoolValue(0);
					me.started = 1;
				}
				else
				{
					me.running.setBoolValue(0);
				}
			}
		}
		elsif (me.running.getBoolValue())
		{
			me.throttle_lever.setValue(me.throttle_at_idle + (1 - me.throttle_at_idle) * me.throttle.getValue());
			me.rpm.setValue(me.n1.getValue());
		}
		
		var total_fuel_gal = props.globals.getNode("consumables/fuel/total-fuel-gal_us", 1).getValue();
		var total_fuel_lbs = props.globals.getNode("consumables/fuel/total-fuel-lbs", 1).getValue();
		var density = total_fuel_lbs / total_fuel_gal or fuel_density;
		me.fuel_flow_pph.setValue(me.fuel_flow_gph.getValue() * density);
	},
	reverse_thrust: func
	{
		var reversing = me.reverser.getBoolValue();
		if (me.throttle.getValue() == 0)
		{
			# Reverse thrust on engine #2 can only be activated when the nose gear is down
			if (me.number == 1)
			{
				if (props.globals.getNode("gear/gear[0]/wow").getBoolValue() or reversing)
				{
					me.reverser.setBoolValue(!reversing);
					return;
				}
			}
			me.reverser.setBoolValue(!reversing);
		}
	}
};
var engine1 = engine.new(0);
var engine2 = engine.new(1);
var engine3 = engine.new(2);
