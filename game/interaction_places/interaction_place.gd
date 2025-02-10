extends Area2D


@export var is_restplace = false
@onready var label: Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	pass # Replace with function body.



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Shady":
		print("AAAA")
		if is_restplace:
			label.text = "REST"
			label.visible = true
			InteractionManager.interaction_point = InteractionManager.points.RESTPLACE
			

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Shady":
		label.visible = false
		InteractionManager.interaction_point = InteractionManager.points.NONE
