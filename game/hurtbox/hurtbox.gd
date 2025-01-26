extends Area2D

@onready var collision: CollisionShape2D = $CollisionShape2D

@export var invincibility_time = 1.
@export var hitpoints = 5

var is_invincible = false

func invincibility():
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout 
	is_invincible = false
	

func disable():
	collision.set_deferred("disabled", true)
	
func enable():
	collision.set_deferred("disabled", false)
