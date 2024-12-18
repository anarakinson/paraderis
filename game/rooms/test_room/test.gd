extends Node2D


@onready var camera_2d = $Camera/SmartCamera2D
@onready var camera_2d_2 = $Camera/SmartCamera2D2
@onready var directional_light_2d: DirectionalLight2D = $Light/DirectionalLight2D
@onready var background_rect = $Background/ParallaxBackground/ParallaxLayer1/BackgroundRect
@onready var parallax_dust: Control = $Background/ParallaxDust
@onready var world_environment: WorldEnvironment = $WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready():
 
	world_environment.environment.glow_enabled = true
	
	directional_light_2d.visible = true
	parallax_dust.visible = true
	background_rect.visible = true
	
	camera_2d.visible = true
	camera_2d.enabled = true
	camera_2d_2.visible = false
	camera_2d_2.enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		#if event.as_text() == InputMap.action_get_events("camera_change"):
		if event.as_text() == "P":
			camera_2d.enabled = !camera_2d.enabled
			camera_2d.visible = !camera_2d.visible
			camera_2d_2.enabled = !camera_2d_2.enabled
			camera_2d_2.visible = !camera_2d_2.visible
	
