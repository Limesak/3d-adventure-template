@tool
class_name EffectClass
extends Resource

enum receivers{targeting_self, targeting_other}
@export var targeted_object:receivers

enum modifiers{none, health, speed}
@export var modifier_type:modifiers

@export var effect_is_temporary := false:
	set(value):
		effect_is_temporary = value
		notify_property_list_changed()
var effect_has_duration := false:
	set(value):
		effect_has_duration = value
		notify_property_list_changed()
var effect_duration:float = 0.0

func _get_property_list():
	var properties = []
	var property_usage = PROPERTY_USAGE_NO_EDITOR
	if effect_is_temporary:
		property_usage = PROPERTY_USAGE_DEFAULT
		properties.append({
			"name": "effect_has_duration",
			"type": TYPE_BOOL,
			"usage": property_usage,
		})
		property_usage = PROPERTY_USAGE_NO_EDITOR
		if effect_has_duration:
			property_usage = PROPERTY_USAGE_DEFAULT
		properties.append({
		"name": "effect_duration",
		"type": TYPE_FLOAT,
		"usage": property_usage,
		})
	
	return properties

func run_effect(caller) -> void:
	pass
