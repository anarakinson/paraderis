extends RigidBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func throw(velocity: Vector2):
	linear_velocity = velocity
	angular_velocity = 5
	
