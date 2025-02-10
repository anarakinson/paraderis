extends Area2D

@onready var collision: CollisionShape2D = $CollisionShape2D

@export var invincibility_time = 1.
@export var hitpoints = 5
#@export var harmless = false

var is_invincible = false

func _ready() -> void:
	collision.shape = collision.shape.duplicate(true)

func invincibility():
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout 
	is_invincible = false
	

func disable():
	collision.set_deferred("disabled", true)
	
func enable():
	collision.set_deferred("disabled", false)

func set_shape(r : int, h : int):
	collision.shape.radius = r
	collision.shape.height = h
	
