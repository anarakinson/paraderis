extends Camera2D

#@onready var player = $"../Deserter"
@export_category("Follow character")
@export var player : CharacterBody2D

@export_category("Camera Smoothing")
@export var smoothing_enabled : bool
@export_range(1, 50) var smoothing_distance : float = 3


#var smoothing_distance : int = 900

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = player.global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player == null:
		return
	
	var weight : float 
	
	var camera_pos : Vector2 
	
	weight = float(smoothing_distance)
	
	camera_pos = lerp(global_position, player.global_position, weight * delta)
	
	global_position = camera_pos.floor()
