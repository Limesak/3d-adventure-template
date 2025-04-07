class_name PlayerSkin
extends Node3D

@onready var animation_tree = %AnimationTree
@onready var move_state_machine:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MovementStateMachine/playback")
@onready var attack_state_machine:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/AttackStateMachine/playback")
@onready var extra_animation = animation_tree.get_tree_root().get_node("ExtraAnimation")

@export var second_attack_timer:Timer

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
	move_state_machine.travel("Running_B")

func sprint() -> void:
	move_state_machine.travel("Running_A")

func jump() -> void:
	move_state_machine.travel("Jump_Start")

func fall() -> void:
	move_state_machine.travel("Jump_Idle")

func land() -> void:
	move_state_machine.travel("Jump_Land")

func attack() -> void:
	if not performing_action:
		attack_state_machine.travel("Slice" if second_attack_timer.time_left else "Chop")
		animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func action_toggle(value:bool):
	performing_action = value

func defend(forward:bool) -> void:
	var tween = create_tween()
	tween.tween_method(defend_change, 1.0 - float(forward), float(forward), 0.25)

func defend_change(value:float) -> void:
	animation_tree.set("parameters/ShieldBlend/blend_amount", value)

func use_item() -> void:
	if not performing_action:
		# change the extra animation to use item
		extra_animation.animation = "Use_Item"
		animation_tree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func toggle_weapon(value:bool) -> void:
	weapon_in_hand = value
	if weapon_in_hand:
		$"Knight/Rig/Skeleton3D/1H_Sword".visible = true
	else:
		$"Knight/Rig/Skeleton3D/1H_Sword".visible = false

func hit() -> void:
	# change the extra animation to hit
	extra_animation.animation = "Hit_A"
	animation_tree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	performing_action = false
