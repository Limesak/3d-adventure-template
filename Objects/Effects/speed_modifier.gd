@tool
class_name SpeedModifierClass
extends EffectClass

@export_range(0.0, 10.0) var speed_modifier:float

var original_speed_modifier := 1.0

func run_effect(caller) -> void:
	var target
	if targeted_object == receivers.targeting_self:
		target = caller
	notify_speed_change(caller, target)

func notify_speed_change(caller, target):
	original_speed_modifier = target.movement_component.speed_modifier
	target.movement_component.speed_modifier = speed_modifier

func revert_effect(target):
	target.movement_component.speed_modifier = original_speed_modifier
