class_name SkeletonSkin
extends Node3D

@onready var animation_tree = %AnimationTree
@onready var move_state_machine:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MovementStateMachine/playback")
@onready var attack_state_machine:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/AttackStateMachine/playback")
@onready var extra_animation = animation_tree.get_tree_root().get_node("ExtraAnimation")

var waiting_looping_action_end := false

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
	attack_state_machine.travel(attack_performed.animation_name)
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if attack_performed.attack_is_looping:
		waiting_looping_action_end = true

func end_looping_action():
	waiting_looping_action_end = false
	attack_state_machine.travel("End")

func hit() -> void:
	# change the extra animation to hit
	extra_animation.animation = "Hit_A"
	animation_tree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func do_squash_and_stretch(value:float, duration:float = 0.1):
	var tween = create_tween()
	tween.tween_property(self, "squash_and_stretch", value, duration)
	tween.tween_property(self, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)
