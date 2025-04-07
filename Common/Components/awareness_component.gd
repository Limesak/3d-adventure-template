class_name AwarenessComponent
extends Area3D

var target:PlayerCharacter = null

signal sight_on_target_changed

func _ready():
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(body:Node3D):
	if body is PlayerCharacter and !target:
		target = body
		sight_on_target_changed.emit()

func on_body_exited(body:Node3D):
	if body is PlayerCharacter and target:
		target = null
		sight_on_target_changed.emit()
