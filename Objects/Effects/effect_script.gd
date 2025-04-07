@tool
class_name EffectClass
extends Resource

enum receivers{targeting_self, targeting_other}
@export var targeted_object:receivers

enum modifiers{none, health, speed}

func run_effect(caller) -> void:
	pass
