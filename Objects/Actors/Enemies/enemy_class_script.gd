class_name EnemyClass
extends CharacterBody3D

@export_group("Components")
@export var movement_component:MovementComponent
@export var health_component:HealthComponent
@export var awareness_component:AwarenessComponent

@onready var skin:SkeletonSkin = %"3DModel"
@onready var state_machine_core:StateMachineCore = %StateMachineCore

@export var list_of_attacks:Array[AttackClass]

var is_starting_jumping := false
var is_sprinting := false
var defend := false
var on_ground_last_frame := true

func _ready():
	SignalsBus.action_effect_transmitted.connect(process_effect_on_self)

func _process(delta):
	state_machine_core.update_state_machine(delta)

func _physics_process(delta):
	state_machine_core.update_state_machine_physics(delta)
	
	movement_component.physics_update(delta)
	
	if awareness_component.target and !skin.performing_action:
		var valid_attacks:Array[AttackClass]
		var distance_to_target := global_position.distance_to(awareness_component.target.global_position)
		for attack in list_of_attacks:
			if distance_to_target < attack.prefered_range and distance_to_target > attack.too_close_range:
				valid_attacks.append(attack)
		if valid_attacks.size() > 0:
			var random_attack = valid_attacks[randi_range(0, valid_attacks.size() -1)]
			attempt_attack(random_attack)
	
	if is_on_floor():
		var ground_speed := velocity.length()
		if ground_speed > 0.0:
			skin.move()
		else :
			skin.idle()
	
	on_ground_last_frame = is_on_floor()

func attempt_attack(attack_performed:AttackClass):
	var tween = create_tween()
	# The target angle is the direction the parent should face given its last movement
	var target_angle := Vector3.BACK.signed_angle_to(global_position.direction_to(awareness_component.target.global_position), Vector3.UP)
	var target_rotation := Vector3(skin.rotation.x, target_angle, skin.rotation.z)
	tween.tween_property(skin, "rotation", target_rotation, 0.4)
	skin.attack(attack_performed)
	for effect in attack_performed.effects:
		if effect.targeted_object == effect.receivers.targeting_self:
			effect.run_effect(self)

func process_effect_on_self(caller, target, effect_type:EffectClass.modifiers, outcome):
	if target == self:
		match effect_type:
			EffectClass.modifiers.speed:
				movement_component.speed_modifier = outcome
