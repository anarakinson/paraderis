extends Camera2D


@onready var blur_rect: ColorRect = $CanvasLayer/Blur
@onready var vignette_rect: TextureRect = $CanvasLayer/Vignette
@onready var vignette_hitted: TextureRect = $CanvasLayer/VignetteHitted
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var zoom_label: Label = $CanvasLayer/Zoom


@export_category("Follow character")
@export var player : CharacterBody2D

@export_category("Camera Smoothing")
#@export var smoothing_enabled : bool
@export_range(0, 50) var basic_smoothing_distance : float = 3.
@export_range(100, 700) var speedup_threshold : float = 400
var smoothing_distance = basic_smoothing_distance
var speed_coeff : float = 1
var camera_position_point = 0


var is_dead = false


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalParams.connect("hitted", _on_hitted)
	GlobalParams.connect("death", _on_death)
	vignette_hitted.visible = false
	pause_menu.visible = false
	zoom_label.text = "zoom: %.2f" % zoom.x
	$CanvasLayer/Corpserobber.visible = false
	
	var win_size = get_viewport().get_visible_rect().size
	vignette_hitted.size = win_size 
	vignette_rect.size = win_size 
	color_rect.size = win_size / 50

	vignette_hitted.position = Vector2(0, 0)
	vignette_rect.position = Vector2(0, 0)
	color_rect.position = win_size / 2
	pause_menu.position = Vector2(0, 0)

	if player != null:
		global_position = player.camera_position.global_position
		print(zoom, vignette_rect.scale, vignette_rect.position, drag_right_margin)
		camera_position_point = player.camera_position_point * (1-zoom.x)
		#drag_top_margin = 0.1 * (1-zoom.y)
		#drag_bottom_margin = 0.1 * (1-zoom.y)
		drag_left_margin = 0.1 * (zoom.x)
		drag_right_margin = 0.1 * (zoom.x)
		smoothing_distance = basic_smoothing_distance * zoom.x
		print(smoothing_distance, " ", (1-zoom.x))
	else:
		pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player == null:
		return
	$Label.text = str(player.camera_position_point)
	var weight : float = float(smoothing_distance)
	var camera_pos : Vector2
	
	#speed_coeff = abs(global_position.distance_to(player.camera_position.global_position)) / 250
	var player_camera_position = player.camera_position.global_position + Vector2(camera_position_point * player.face_direction, 0)
	if global_position.distance_to(player_camera_position) > speedup_threshold:
		speed_coeff = lerp(speed_coeff, 3., 0.5 * delta)
	else:
		speed_coeff = lerp(speed_coeff, 1., 0.5 * delta)
	#print(speed_coeff)
	camera_pos = lerp(global_position, player_camera_position, weight * delta * speed_coeff)
	global_position = camera_pos.floor()
	
	#print(global_position, vignette_hitted.global_position)


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
	

func _input(event: InputEvent) -> void:
	if !self.is_current() or is_dead:
		return
	if (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		if event.as_text() == "K":
			zoom -= Vector2(0.005, 0.005)
			zoom_label.text = "zoom: %.2f" % zoom.x
		if event.as_text() == "L":
			zoom += Vector2(0.005, 0.005)
			zoom_label.text = "zoom: %.2f" % zoom.x
		#if event.keycode == KEY_ESCAPE:
		if event.is_action("pause"):
			#print("escape")
			pause_menu.activate()


func _on_visibility_changed() -> void:
	$CanvasLayer.visible = visible

func _on_death():
	is_dead = true
	
