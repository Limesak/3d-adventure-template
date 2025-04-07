class_name AttackState
extends State

# @export var actions:Array[ActionData]

func enter_state():
	parent_enemy.action_cooldown = 100.0

func update_state(delta):
	if parent_enemy.action_cooldown > 0:
		transitioned.emit(self, "FollowState")

# func prepare_action(action_data:ActionData):
# 	var targets_in_range:Array
# 
# 	# Finds all the enemies stored in the current combat scene listed in the game manager class.
# 	# For each enemy found, compares distance from player to the action range. If the distance is
# 	# under the action_range, adds it as a valid target for the action.
# 	for b in action_data.get_target(self):
# 		if parent_enemy.global_position.distance_to(b.global_position) <= action_data.action_range:
# 			targets_in_range.append(b)
# 	
# 	action_data.run_action(parent_enemy, targets_in_range)
