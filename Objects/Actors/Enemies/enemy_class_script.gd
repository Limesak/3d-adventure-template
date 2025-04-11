class_name EnemyClass
extends CharacterBody3D

@export_group("Components")
@export var movement_component:MovementComponent
@export var health_component:HealthComponent
@export var awareness_component:AwarenessComponent

@onready var skin:SkeletonSkin = %"3DModel"
@onready var attack_timer = %AttackTimer
@onready var state_machine_core:StateMachineCore = %StateMachineCore

@export var list_of_attacks:Array[AttackClass]

var is_starting_jumping := false
var is_sprinting := false
var defend := false
var on_ground_last_frame := true

var current_temp_effect:EffectClass

func _ready():
	sub_class_ready()

func _process(delta):
	state_machine_core.update_state_machine(delta)
	sub_class_update(delta)

func _physics_process(delta):
	state_machine_core.update_state_machine_physics(delta)
	movement_component.physics_update(delta)
	
	if is_on_floor():
		var ground_speed := velocity.length()
		if ground_speed > 0.0:
			skin.move()
		else :
			skin.idle()
	
	check_attack_possibilities()
	
	on_ground_last_frame = is_on_floor()
	
	sub_class_physics_update(delta)

func check_attack_possibilities():
	if awareness_component.target and attack_timer.is_stopped() and !skin.waiting_looping_action_end:
		var valid_attacks:Array[AttackClass]
		var distance_to_target := global_position.distance_to(awareness_component.target.global_position)
		for attack in list_of_attacks:
			if distance_to_target < attack.prefered_range and distance_to_target > attack.too_close_range:
				valid_attacks.append(attack)
		if valid_attacks.size() > 0:
			var random_attack = valid_attacks[randi_range(0, valid_attacks.size() -1)]
			skin.attack(random_attack)
			trigger_attack_effects_on_self(random_attack)
			if !skin.waiting_looping_action_end:
				start_attack_timer()

func start_attack_timer():
	var rand_time = randf_range(1.5, 7.0)
	attack_timer.start(rand_time)

func trigger_attack_effects_on_self(attack_performed):
	for effect in attack_performed.effects:
		if effect.targeted_object == effect.receivers.targeting_self:
			effect.run_effect(self)
		if !effect.effect_is_temporary:
			return
		if effect.effect_has_duration:
			await get_tree().create_timer(effect.effect_duration).timeout
		else:
			current_temp_effect = effect

func return_to_normal_values(effect_type:EffectClass.modifiers, base_value):
	match effect_type:
		EffectClass.modifiers.speed:
			movement_component.speed_modifier = base_value

func sub_class_ready() -> void:
	pass

func sub_class_update(delta) -> void:
	pass

func sub_class_physics_update(delta) -> void:
	pass
