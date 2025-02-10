extends Node2D


@onready var camera_2d = $Camera/SmartCamera2D
@onready var camera_2d_2 = $Camera/SmartCamera2D2
@onready var directional_light_2d: DirectionalLight2D = $Light/DirectionalLight2D
#@onready var background_rect: Sprite2D = $"Background/CanvasLayer-50/BackgroundRect"
@onready var background_rect: ColorRect = $Background/CanvasLayer/BackgroundRect
@onready var parallax_dust: Control = $Background/ParallaxDust
#@onready var world_environment: WorldEnvironment = $WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready():
 
	directional_light_2d.visible = true

	parallax_dust.visible = true
	background_rect.visible = true
	
	camera_list[camera_number].set_deferred("enabled", true)
	camera_list[camera_number].set_deferred("visible", true)

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

var camera_number: int = 0
@onready var camera_list : Array = [
	$Camera/SmartCamera2D,
	$Camera/SmartCamera2D2,
	$Camera/SmartCamera2D3,
	$Camera/SmartCamera2D4,
]
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		#if event.as_text() == InputMap.action_get_events("camera_change"):
		if event.as_text() == "P":
			camera_list[camera_number].set_deferred("enabled", false)
			camera_list[camera_number].set_deferred("visible", false)
			camera_number += 1
			if camera_number >= len(camera_list):
				camera_number = 0
			camera_list[camera_number].set_deferred("enabled", true)
			camera_list[camera_number].set_deferred("visible", true)
		if event.as_text() == "O":
			var explosion = preload("res://game/effects/fireburst/fireburst.tscn").instantiate()
			get_parent().add_child(explosion)
			#await animation_player.animation_finished
			explosion.position = $Shady.global_position
			explosion.explode()




	#for camera in camera_list:
		#print(camera, " ", camera.enabled, " ", camera.pause_menu.is_active)
