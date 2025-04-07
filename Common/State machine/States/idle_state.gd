class_name EnemyIdleState
extends State

func enter_state():
	parent_enemy.movement_component._direction = Vector3.ZERO

func update_state_physics(delta:float):
	if parent_enemy.awareness_component.target is PlayerCharacter:
		transitioned.emit(self, "FollowState")
	else:
		parent_enemy.movement_component._direction = Vector3.ZERO
