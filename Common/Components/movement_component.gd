## Attach this class to a node to give it movement properties.
class_name MovementComponent
extends Node

@onready var _parent:CharacterBody3D = get_parent().get_parent()

@export_group("Movement speed")
@export var running_speed := 5.0
@export var sprinting_speed := 7.5
@export var defending_speed := 3.0
@export var acceleration := 12.0
@export var stoping_speed := 1.0
@export var rotation_speed := 12.0
@export var jump_force := 12.0
var speed_modifier := 1.0

var _direction := Vector3.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0

func physics_update(delta):
	var y_velocity := _parent.velocity.y
	_parent.velocity.y = 0.0
	var speed:float = sprinting_speed if _parent.is_sprinting else running_speed
	speed = defending_speed if _parent.defend else speed
	speed = speed * speed_modifier
	# If a direction is given, we calculate a new velocity to apply to the parent.
	_parent.velocity = _parent.velocity.move_toward(_direction * speed, acceleration * delta)
	
	if is_equal_approx(_direction.length(), 0.0) and _parent.velocity.length() < stoping_speed:
		_parent.velocity = Vector3.ZERO
	
	if !_parent.on_ground_last_frame:
		_parent.velocity.y = y_velocity + _gravity * delta
	
	if _parent.is_starting_jumping:
		_parent.do_squash_and_stretch(1.2, 0.15)
		_parent.velocity.y += jump_force
	
	_parent.move_and_slide()
	
	# When the parent moves, we store the new direction and rotate it
	if _direction.length() > 0.2:
		# The target angle is the direction the parent should face given its last movement
		var target_angle := Vector3.BACK.signed_angle_to(_direction, Vector3.UP)
		# We change the rotation of the parent so it corresponds to the [target_angle]
		_parent.skin.rotation.y = rotate_toward(_parent.skin.rotation.y, target_angle, rotation_speed * delta)

func stop_movement(start_duration:float, end_duration:float):
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)
