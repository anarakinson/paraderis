extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func play():
	animated_sprite_2d.play("default")
	await animated_sprite_2d.animation_finished
	queue_free()
