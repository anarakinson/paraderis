extends Node2D


@onready var camera_2d = $Camera/SmartCamera2D
@onready var directional_light_2d: DirectionalLight2D = $Light/DirectionalLight2D
@onready var background_rect = $Background/ParallaxBackground/ParallaxLayer1/BackgroundRect
@onready var parallax_dust: Control = $Background/ParallaxDust
@onready var world_environment: WorldEnvironment = $WorldEnvironment




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#world_environment.environment.glow_enabled = true
	
	#directional_light_2d.visible = true
	parallax_dust.visible = true
	background_rect.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
