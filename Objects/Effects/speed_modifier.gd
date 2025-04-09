@tool
class_name SpeedModifierClass
extends EffectClass

@export_range(0.0, 10.0) var speed_modifier:float

func run_effect(caller) -> void:
	var target
	if targeted_object == receivers.targeting_self:
		target = caller
	notify_speed_change(caller, target)

func notify_speed_change(caller, target):
	SignalsBus.action_effect_transmitted.emit(caller, target, self, speed_modifier)
