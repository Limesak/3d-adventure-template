class_name SkeletonSkin
extends Node3D

@onready var animation_tree = %AnimationTree
@onready var move_state_machine:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MovementStateMachine/playback")
@onready var attack_state_machine:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/AttackStateMachine/playback")
@onready var extra_animation = animation_tree.get_tree_root().get_node("ExtraAnimation")

@onready var attack_timer = %AttackTimer

var performing_action := false
var weapon_in_hand := true
var squash_and_stretch := 1.0:
	set(value):
		squash_and_stretch = value
		var negative = 1.0 + (1.0 - squash_and_stretch)
		scale = Vector3(negative, squash_and_stretch, negative)

func idle() -> void:
	move_state_machine.travel("Idle")

func move() -> void:
	move_state_machine.travel("Walking")

func attack(attack_performed:AttackClass) -> void:
	if !performing_action and attack_timer.is_stopped():
		attack_state_machine.travel(attack_performed.animation_name)
		animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		var rand_time := randf_range(0.5, 5.0)
		attack_timer.start(rand_time)

func action_toggle(value:bool):
	performing_action = value

func hit() -> void:
	# change the extra animation to hit
	extra_animation.animation = "Hit_A"
	animation_tree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	performing_action = false
