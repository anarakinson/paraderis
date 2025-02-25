extends AnimatedSprite2D

@onready var animated_sprite_2d: AnimatedSprite2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.frame = randi() % animated_sprite_2d.frames.get_frame_count("default")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
