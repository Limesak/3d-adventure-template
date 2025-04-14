class_name CombatReadyState
extends State

var target:Node3D

func enter_state():
	if parent_enemy.awareness_component.target:
		target = parent_enemy.awareness_component.target
	
	parent_enemy.movement_component.allow_rotation = false

func exit_state():
	parent_enemy.movement_component.allow_rotation = true

func update_state(_delta:float):
	if !parent_enemy.awareness_component.target:
		transitioned.emit(self, "EnemyIdleState")
	
	var distance_to_target := parent_enemy.global_position.distance_to(target.global_position)
	var should_reposition := false
	var previous_attack:AttackClass
	for attack in parent_enemy.list_of_attacks:
		var attack_to_compare:AttackClass
		if previous_attack:
			attack_to_compare = previous_attack if previous_attack.prefered_range > attack.prefered_range else attack
		else:
			attack_to_compare = attack
		if distance_to_target > attack_to_compare.prefered_range or distance_to_target <= attack_to_compare.too_close_range:
			should_reposition = true
		previous_attack = attack
	
	if should_reposition:
		transitioned.emit(self, "FollowState")

func update_state_physics(_delta:float):
	rotate_towards_target(_delta)

func rotate_towards_target(delta):
	if target:
		var target_direction := parent_enemy.global_position.direction_to(target.global_position)
		# The target angle is the direction the parent should face given its last movement
		var target_angle := Vector3.BACK.signed_angle_to(target_direction, Vector3.UP)
		# We change the rotation of the parent so it corresponds to the [target_angle]
		parent_enemy.skin.rotation.y = rotate_toward(parent_enemy.skin.rotation.y, target_angle, 5.0 * delta)
