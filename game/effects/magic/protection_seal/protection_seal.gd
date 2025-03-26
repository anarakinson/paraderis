extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var followed_owner : Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("default")
	await animated_sprite_2d.animation_finished
	queue_free()
	pass # Replace with function body.


 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = followed_owner.global_position


func follow(new_owner : Node2D):
	followed_owner = new_owner
