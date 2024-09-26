extends Area2D

@export var notice = ""
@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	label.text = notice

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Shady":
		label.visible = true
		label.modulate.a = 0
		var tween = get_tree().create_tween()
		tween.tween_property(label, "modulate:a", 1, 0.5)



func _on_body_exited(body: Node2D) -> void:
	if body.name == "Shady":
		var tween = get_tree().create_tween()
		tween.tween_property(label, "modulate:a", 0, 0.5)
		#tween.tween_property(label, "isplayerturn", false, 0.0)

		tween.tween_callback(func(): label.visible = false)
