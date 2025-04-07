## The health component is responsible for keeping track of the health of an entity.
## It stores max health, current health, health changes and triggers death behaviours when needed.
class_name HealthComponent
extends Node

## The maximum health of the entity. 
@export var max_health:int
## The current health of the entity. It is set through a function that clamps it between 0 and the maximum health.
## When it reaches 0, we trigger the death effects.
var current_health:int:
	set(value):
		var previous_health = current_health
		
		if current_health + value >= max_health:
			current_health = max_health
		else:
			current_health += value
		
		if current_health < previous_health:
			health_decreased.emit()
		
		if current_health <= 0:
			death_trigger()
	get:
		return current_health

signal health_decreased

func _ready():
	# The starting health is set to max_health
	current_health = max_health

## This function is used to "kill" the parent of the [HealthComponent]. It emits a signal to
## notify the change and it frees the parent scene from the Tree.s
func death_trigger():
	pass
