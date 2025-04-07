class_name StateMachineCore
extends Node

@export var initial_state:State

var current_state:State
var states:Dictionary = {}

var _parent:EnemyClass

func _ready() -> void:
	_parent = get_parent()
	
	for node in get_children():
		if node is State:
			states[node.name.to_lower()] = node
			node.parent_enemy = _parent
			node.transitioned.connect(on_state_transition)
	
	if initial_state:
		initial_state.enter_state()
		current_state = initial_state

func update_state_machine(delta: float) -> void:
	if current_state:
		current_state.update_state(delta)

func update_state_machine_physics(delta: float) -> void:
	if current_state:
		current_state.update_state_physics(delta)

func on_state_transition(state:State, new_state_name:String):
	if state != current_state:
		return
	
	var new_state:State = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit_state()
	
	new_state.enter_state()
	
	current_state = new_state
