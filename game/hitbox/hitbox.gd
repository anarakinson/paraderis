extends Area2D

@export var damage = 1
@export var knockback_force = 450
var direction = 0

@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	set_deferred("collision.shape", collision.shape.duplicate(true))


func enable():
	collision.set_deferred("disabled", false)
	
func disable():
	collision.set_deferred("disabled", true)
