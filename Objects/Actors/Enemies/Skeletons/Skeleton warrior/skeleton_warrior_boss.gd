class_name SkeletonWarriorBoss
extends EnemyClass

@onready var idle_state:EnemyIdleState = %EnemyIdleState
@onready var follow_state:FollowState = %FollowState 
@onready var combat_state:CombatReadyState = %CombatReadyState 

var waiting_contact := false

func sub_class_ready() -> void:
	pass

func sub_class_update(delta) -> void:
	pass

func sub_class_physics_update(delta) -> void:
	if skin.attack_state_machine.get_current_node() == "Spinning":
		chase_target()
		movement_component.allow_rotation = false
		if awareness_component.target:
			movement_component._direction = global_position.direction_to(awareness_component.target.global_position)
		else:
			skin.end_looping_action()

func chase_target() -> void:
	if awareness_component.target:
		var distance_from_target := global_position.distance_to(awareness_component.target.position)
		if distance_from_target < 3.0:
			skin.end_looping_action()
			current_temp_effect.revert_effect(self)
			movement_component.allow_rotation = true
