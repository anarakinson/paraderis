extends Area2D

@export var damage = 1
@export var knockback_force = 450

@onready var collision: CollisionShape2D = $CollisionShape2D

func enable():
	collision.set_deferred("disabled", false)
	
func disable():
	collision.set_deferred("disabled", true)
