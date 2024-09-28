extends Camera2D


@onready var blur_rect: ColorRect = $Blur
@onready var vignette_rect: TextureRect = $Vignette

@export_category("Follow character")
@export var player : CharacterBody2D

@export_category("Camera Smoothing")
@export var smoothing_enabled : bool
@export_range(1, 50) var smoothing_distance : float = 3


#var smoothing_distance : int = 900

# Called when the node enters the scene tree for the first time.
func _ready():
	blur_rect.scale = Vector2(1/zoom.x, 1/zoom.y)
	vignette_rect.scale = Vector2(1/zoom.x, 1/zoom.y)
	blur_rect.position *= blur_rect.scale
	vignette_rect.position *= vignette_rect.scale

	if player != null:
		global_position = player.global_position
		print(zoom, vignette_rect.scale, vignette_rect.position)
	else:
		vignette_rect.visible = false
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
