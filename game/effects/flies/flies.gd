extends CPUParticles2D


var player : CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		return
	else:
		global_position = player.global_position + Vector2(0, -50 * player.scale.y)
		gravity = player.velocity


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Shady":
		player = body
