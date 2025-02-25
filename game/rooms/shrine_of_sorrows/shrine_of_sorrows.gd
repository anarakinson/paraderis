extends Node2D

@onready var directional_light_2d: DirectionalLight2D = $Light/DirectionalLight2D
@onready var parallax_dust: Control = $Background/ParallaxDust
@onready var color_rect: ColorRect = $"Background/CanvasLayer-10/ColorRect"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.visible = true
	directional_light_2d.visible = true
	parallax_dust.visible = true
