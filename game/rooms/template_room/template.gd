extends Node2D


@onready var camera_2d = $Camera/SmartCamera2D
@onready var camera_2d_2: Camera2D = $Camera/SmartCamera2D2
@onready var directional_light_2d: DirectionalLight2D = $Light/DirectionalLight2D
@onready var point_light_2d_2: PointLight2D = $Shady/PointLight2D2
@onready var background_rect: ColorRect = $Background/BackgroundRect


# Called when the node enters the scene tree for the first time.
func _ready():
	camera_2d.visible = true
	camera_2d_2.visible = false
	directional_light_2d.visible = true
	camera_2d.visible = true
	camera_2d_2.visible = false
	background_rect.visible = true
	$Interface/IngameInterface.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		#if event.as_text() == InputMap.action_get_events("camera_change"):
		if event.as_text() == "P":
			camera_2d.enabled = !camera_2d.enabled
			camera_2d_2.enabled = !camera_2d_2.enabled
			camera_2d.visible = !camera_2d.visible
			camera_2d_2.visible = !camera_2d_2.visible
