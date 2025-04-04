extends Camera2D


@onready var blur_rect: ColorRect = $CanvasLayer/Blur
@onready var vignette_rect: TextureRect = $CanvasLayer/Vignette
@onready var vignette_hitted: TextureRect = $CanvasLayer/VignetteHitted
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var zoom_label: Label = $CanvasLayer/Zoom
@onready var fps_label: Label = $CanvasLayer/FPSLabel


@export_category("Follow character")
@export var player : CharacterBody2D

@export_category("Camera Smoothing")
#@export var smoothing_enabled : bool
@export_range(0, 50) var basic_smoothing_distance : float = 2.
@export_range(100, 700) var speedup_threshold : float = 350
var smoothing_distance = basic_smoothing_distance
var speed_coeff : float = 1
var camera_position_point = 0


var is_dead = false
@export var basic_offset_y = -100. 


@export_category("screenshake")
@export var shake_coeff: float = 1.
@export var shake_fade: float = 4.0
var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.

@export_category("utils")
@export var display_fps: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalParams.connect("hitted", _on_hitted)
	GlobalParams.connect("death", _on_death)
	GlobalParams.connect("screenshake", _on_screenshake)
	if self.is_current():
		visible = true
	else:
		visible = false
	$CanvasLayer.visible = visible
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
	
	offset.y = basic_offset_y
	drag_top_margin = 0.01 * (zoom.y)
	drag_bottom_margin = 0.01 * (zoom.y)
	drag_left_margin = 0.1 * (zoom.x)
	drag_right_margin = 0.1 * (zoom.x)

	limit_left += int(offset.x)
	limit_right += int(offset.x)
	limit_top -= int(offset.y)
	limit_bottom -= int(offset.y)

	if player != null:
		#force_update_scroll()
		global_position = player.camera_position.global_position
		print(zoom, vignette_rect.scale, vignette_rect.position, drag_right_margin)
		camera_position_point = player.camera_position_point * (1-zoom.x)
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
	if global_position.distance_to(player_camera_position + offset * 1.3) > 2.5 * speedup_threshold * zoom.x:
		speed_coeff = lerp(speed_coeff, 50., 1.5 * delta)
	elif global_position.distance_to(player_camera_position + offset * 1.3) > speedup_threshold * zoom.x:
		speed_coeff = lerp(speed_coeff, 1.8, 1.5 * delta)
	else:
		speed_coeff = lerp(speed_coeff, 1., 2. * delta)
	#print(speed_coeff)
	camera_pos = lerp(global_position, player_camera_position, weight * delta * speed_coeff)
	global_position = camera_pos#.floor()
	$CanvasLayer/ColorRect/Label.text = "%.3f" % global_position.distance_to(player_camera_position) + " " + str(speed_coeff)
	#print(global_position, vignette_hitted.global_position)
	
	
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		offset = random_offset() + Vector2(0, basic_offset_y)
	
	
	if display_fps:
		fps_label.set_text("FPS " + str(Engine.get_frames_per_second()))


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
	if !self.is_current():
		return
	elif (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		if event.as_text() == "K":
			zoom -= Vector2(0.005, 0.005)
			#offset.y -= basic_offset_y * zoom.y
			zoom_label.text = "zoom: %.2f" % zoom.x
		if event.as_text() == "L":
			zoom += Vector2(0.005, 0.005)
			#offset.y += basic_offset_y * zoom.y
			zoom_label.text = "zoom: %.2f" % zoom.x
		if event.is_action("pause"):
			#print("escape")
			pause_menu.activate()


func _on_visibility_changed() -> void:
	$CanvasLayer.visible = visible

func _on_death():
	is_dead = true

func _on_screenshake(duration, strenght):
	#print("screenshake %f" % duration)
	Input.vibrate_handheld(duration / 10)
	Input.start_joy_vibration(0, 0.9 , 0.9 , duration)
	Input.start_joy_vibration(1, 0.6 , 0.8 , duration)
	shake_strength = strenght * shake_coeff
	await get_tree().create_timer(duration).timeout
	shake_strength = 0

func random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength), 
		rng.randf_range(-shake_strength, shake_strength)
	)



@onready var button: Button = $CanvasLayer/Button

var button_flag = true
func _on_button_pressed() -> void:
	if button_flag:
		button.set_deferred("text", "aaaaaaa")
	else:
		button.set_deferred("text", "FUCK")
	button_flag = !button_flag
