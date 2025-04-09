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
var waiting_contact := false

func _ready():
	SignalsBus.action_effect_transmitted.connect(process_effect_on_self)
	skin.waiting_contact.connect(toggle_contact_detection)
	skin.applied_action_effect_to_self.connect(trigger_attack_effects)

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
	
	if waiting_contact:
		if awareness_component.target:
			var distance_from_target := global_position.distance_to(awareness_component.target.position)
			if distance_from_target < 2.0:
				skin.contact_made.emit()
	
	on_ground_last_frame = is_on_floor()

func attempt_attack(attack_performed:AttackClass):
	skin.attack(attack_performed)
	#movement_component.stop_movement(0.2, 0.4)

func trigger_attack_effects(attack_performed):
	for effect in attack_performed.effects:
		if effect.targeted_object == effect.receivers.targeting_self:
			effect.run_effect(self)

func process_effect_on_self(caller, target, effect:EffectClass, outcome):
	var original_value
	if target == self:
		match effect.modifier_type:
			EffectClass.modifiers.speed:
				original_value = movement_component.speed_modifier
				movement_component.speed_modifier = outcome
	else:
		return
	
	if !effect.effect_is_temporary:
		return
	
	if effect.effect_has_duration:
		await get_tree().create_timer(effect.effect_duration).timeout
	else:
		await skin.contact_made
	return_to_normal_values(effect.modifier_type, original_value)

func return_to_normal_values(effect_type:EffectClass.modifiers, base_value):
	match effect_type:
		EffectClass.modifiers.speed:
			movement_component.speed_modifier = base_value

func toggle_contact_detection(value:bool):
	waiting_contact = value
