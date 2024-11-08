extends PointLight2D

@export_category("Follow character")
@export var player : CharacterBody2D
var smoothing_distance : float = 22.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	global_position = player.global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		return
	
	var weight : float = float(smoothing_distance)
	var light_pos : Vector2 = lerp(global_position, player.global_position, weight * delta)
	global_position = light_pos.floor()
