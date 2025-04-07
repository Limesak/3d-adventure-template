class_name PlayerCharacter
extends CharacterBody3D

@export_category("Components")
@export var movement_component:MovementComponent
@export var health_component:HealthComponent

var is_starting_jumping:bool
var on_ground_last_frame:bool
var is_sprinting:bool
var defend := false:
	set(value):
		if not defend and value:
			skin.defend(true)
		if defend and not value:
			skin.defend(false)
		defend = value

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

var camera_input_direction := Vector2.ZERO
@onready var _camera_pivot:Node3D = %CameraPivot # The camera attached to the player
@onready var _camera:Camera3D = %Camera3D # The camera attached to the player

@onready var skin:PlayerSkin = %"3DModel"

func _ready():
	health_component.health_decreased.connect(hit)

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode= Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event:InputEvent)-> void:
	var is_camera_motion:= (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		camera_input_direction = event.screen_relative * mouse_sensitivity

func _process(delta):
	# When the game is paused, we don't want the player to be able to move or use actions
	if !get_tree().paused:
		# Get direction inputed by player
		var input_dir = Input.get_vector("move_left","move_right", "move_forward", "move_back")
		var forward := _camera.global_basis.z
		var right := _camera.global_basis.x
		
		is_starting_jumping = Input.is_action_pressed("jump") and is_on_floor()
		is_sprinting = Input.is_action_pressed("sprint_button") and is_on_floor()
		
		action_logic()
		
		var move_direction:Vector3 = forward * input_dir.y + right * input_dir.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized()
		
		movement_component._direction = move_direction

func _physics_process(delta:float):
	if !get_tree().paused:
		_camera_pivot.rotation.x += camera_input_direction.y * delta
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
		_camera_pivot.rotation.y -= camera_input_direction.x * delta
		camera_input_direction = Vector2.ZERO
		movement_component.physics_update(delta)
		
		if is_starting_jumping:
			skin.jump()
		elif not is_on_floor() and velocity.y < 0:
			skin.fall()
		elif is_on_floor():
			var ground_speed := velocity.length()
			if ground_speed > 0.0:
				skin.sprint() if is_sprinting else skin.move()
			else:
				skin.idle()
	
	on_ground_last_frame = is_on_floor()

func action_logic() -> void:
	if Input.is_action_just_pressed("attack_button"):
		skin.attack()
		movement_component.stop_movement(0.05, 0.5)
	if Input.is_action_just_pressed("use_item_button"):
		skin.use_item()
		movement_component.stop_movement(0.05, 0.5)
	
	defend = Input.is_action_pressed("block_button")

func hit():
	skin.hit()
	do_squash_and_stretch(1.2, 0.15)
	movement_component.stop_movement(0.2, 0.3)

func do_squash_and_stretch(value:float, duration:float = 0.1):
	var tween = create_tween()
	tween.tween_property(skin, "squash_and_stretch", value, duration)
	tween.tween_property(skin, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)
