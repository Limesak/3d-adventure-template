class_name WeaponClass
extends Node3D

@onready var raycast = $RayCast3D
@onready var projectile_point = $ProjectilePoint

var can_damage:bool = false

signal hit_something

func _process(delta: float) -> void:
	if can_damage:
		var collider = raycast.get_collider()
		if collider and "hit" in collider:
			collider.hit()
			hit_something.emit()
