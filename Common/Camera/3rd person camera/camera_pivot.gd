extends Node3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(0.5, 2.0) var right_stick_sensitivity := 1.0

var camera_input_direction := Vector2.ZERO

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode= Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event:InputEvent)-> void:
	var mouse_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if mouse_motion:
		camera_input_direction = event.screen_relative * mouse_sensitivity

func _process(delta):
	var joy_dir = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	if joy_dir.length() > 0:
		camera_input_direction = joy_dir

func _physics_process(delta):	
	if !get_tree().paused:
		rotation.x += camera_input_direction.y * delta
		rotation.x = clamp(rotation.x, -PI / 6.0, PI / 3.0)
		rotation.y -= camera_input_direction.x * delta
		camera_input_direction = Vector2.ZERO
