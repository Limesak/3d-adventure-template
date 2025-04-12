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

@export var enemy_weapon:WeaponClass

var is_starting_jumping := false
var is_sprinting := false
var defend := false
var on_ground_last_frame := true

var current_temp_effect:EffectClass
var current_projectile_attack:AttackClass

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
			if random_attack.creates_projectile:
				current_projectile_attack = random_attack
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

func hit(damage_dealt:int, effects_dealt:Array[EffectClass]):
	if !%InvulTimer.time_left:
		%InvulTimer.start()
		skin.hit()
		health_component.current_health -= damage_dealt
		skin.do_squash_and_stretch(1.2, 0.5)
		movement_component.stop_movement(0.1, 0.6)

func can_damage(value:bool):
	enemy_weapon.can_damage = value

func create_projectile():
	if current_projectile_attack:
		var new_projectile:ProjectileClass =  current_projectile_attack.projectile.instantiate()
		new_projectile.attack_data = current_projectile_attack
		get_tree().root.add_child(new_projectile)
		new_projectile.look_at_from_position(enemy_weapon.projectile_point.global_position, awareness_component.target.global_position, Vector3.UP, true)
		new_projectile.rotation.y = new_projectile.rotation.y
		new_projectile.direction = global_position.direction_to(awareness_component.target.global_position)

func sub_class_ready() -> void:
	pass

func sub_class_update(delta) -> void:
	pass

func sub_class_physics_update(delta) -> void:
	pass
