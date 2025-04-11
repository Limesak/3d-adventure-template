@tool
class_name AttackClass
extends Resource

@export var animation_name:String
@export var prefered_range:float
@export var too_close_range:float
@export var damage_to_deal:int
@export var effects:Array[EffectClass]
@export var attack_is_looping := false:
	set(value):
		attack_is_looping = value
		notify_property_list_changed()

enum stoping_conditions{OVER_TIME, AT_CONTACT}
var stopping_condition:String

func _get_property_list() -> Array:
	var properties:Array = []
	if attack_is_looping:
		properties.append({
			"name": "stopping_condition",
			"type": TYPE_STRING_NAME,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(stoping_conditions.keys())
		})
	
	return properties
