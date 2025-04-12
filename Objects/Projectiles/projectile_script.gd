class_name ProjectileClass
extends Node3D

@onready var raycast := $RayCast3D

@export var projectile_speed := 9.5

var attack_data:AttackClass

var effects_to_apply:Array[EffectClass]
var damage_to_deal:int

var direction:Vector3

func _ready():
	for effect in attack_data.effects:
		if effect.targeted_object == effect.receivers.targeting_other:
			effects_to_apply.append(effect)
	
	damage_to_deal = attack_data.damage_to_deal

func _process(delta):
	if raycast.get_collider():
		var collider = raycast.get_collider()
		if "hit" in collider:
			collider.hit(damage_to_deal, effects_to_apply)
			queue_free()

func _physics_process(delta):
	global_position += direction * projectile_speed * delta
