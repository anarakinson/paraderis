extends Camera2D


@onready var blur_rect: ColorRect = $CanvasLayer/Blur
@onready var vignette_rect: TextureRect = $CanvasLayer/Vignette
@onready var vignette_hitted: TextureRect = $CanvasLayer/VignetteHitted

@export_category("Follow character")
@export var player : CharacterBody2D

@export_category("Camera Smoothing")
@export var smoothing_enabled : bool
@export_range(1, 50) var smoothing_distance : float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalParams.connect("hitted", _on_hitted)
	vignette_hitted.visible = false

	#drag_bottom_margin = 0.2 * (1 / zoom.y)
	#drag_top_margin = 0.2 * (1 / zoom.y)
	#drag_left_margin = 0.2 * (1 / zoom.x)
	#drag_right_margin = 0.2 * (1 / zoom.x)
	if player != null:
		global_position = player.global_position
		print(zoom, vignette_rect.scale, vignette_rect.position, drag_right_margin)
		player.camera_position_point /= (zoom.x * 1.)
	else:
		pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player == null:
		return
	$Label.text = str(player.camera_position_point)
	var weight : float = float(smoothing_distance)
	var camera_pos : Vector2
	
	var speed_coeff = abs(global_position.distance_to(player.camera_position.global_position)) / 200
	#print(speed_coeff)
	camera_pos = lerp(global_position, player.camera_position.global_position, weight * delta * speed_coeff)
	global_position = camera_pos.floor()
	
func _on_hitted():
	vignette_hitted.modulate.a = 1
	vignette_hitted.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(vignette_hitted, "modulate:a", 0., 0.15)
	#await get_tree().create_timer(0.07).timeout
	##vignette_hitted.visible = false
	#await get_tree().create_timer(0.01).timeout
	##vignette_hitted.visible = true
	await get_tree().create_timer(0.15).timeout
	vignette_hitted.visible = false
	vignette_hitted.modulate.a = 1
	
