extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var st_fr = int(randi() % 6)
	animated_sprite_2d.set_deferred("frame", st_fr)
	pass # Replace with function body.
