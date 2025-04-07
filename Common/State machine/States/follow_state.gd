class_name FollowState
extends State

@export var wanted_distance_from_target := 5.0
@export var timer_check_position:Timer

var target:PlayerCharacter
var wanted_position:Vector3

func enter_state():
	target = parent_enemy.awareness_component.target
	find_position_in_radius()

func update_state_physics(delta:float):
	var direction := parent_enemy.global_position.direction_to(wanted_position)
	var move_direction := Vector3(direction.x, 0.0, direction.z).normalized()
	var distance = parent_enemy.global_position.distance_to(wanted_position)
	
	if distance < 1.0:
		parent_enemy.movement_component._direction = Vector3.ZERO
	else:
		parent_enemy.movement_component._direction = move_direction
	
	var distance_to_target = parent_enemy.global_position.distance_to(target.global_position)
	var distance_difference = abs(wanted_distance_from_target - distance_to_target)
	
	if distance_difference > 2.0 and timer_check_position.is_stopped():
		find_position_in_radius()
	
	for body in parent_enemy.awareness_component.get_overlapping_bodies():
		if body is EnemyClass:
			if body == parent_enemy:
				pass
			else:
				var dist = parent_enemy.global_position.distance_to(body.global_position)
				if dist < 2.0:
					var direction_away_from_ally := -parent_enemy.global_position.direction_to(body.global_position)
					var mv_away_dir := Vector3(direction_away_from_ally.x, 0.0, direction_away_from_ally.z).normalized()
					parent_enemy.movement_component._direction = mv_away_dir
	
	if !parent_enemy.awareness_component.target:
		transitioned.emit(self, "EnemyIdleState")

func find_position_in_radius():
	var r = wanted_distance_from_target * sqrt(randf())
	var theta := randf() * 2 * PI
	wanted_position.x = target.global_position.x + r + cos(theta)
	wanted_position.z = target.global_position.z + r + cos(theta)
	timer_check_position.start()
