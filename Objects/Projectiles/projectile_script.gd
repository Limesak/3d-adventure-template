class_name ProjectileClass
extends Node3D

@onready var raycast := $RayCast3D

@export var projectile_speed := 9.5

var direction:Vector3

func _process(delta):
	if raycast.get_collider():
		var collider = raycast.get_collider()
		if "hit" in collider:
			collider.hit()
			queue_free()

func _physics_process(delta):
	global_position += direction * projectile_speed * delta
