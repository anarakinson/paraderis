extends Node2D


var interaction_point = points.NONE
enum points {
	NONE,
	RESTPLACE,
	ITEM,
	LEVER,
	BUTTON,
	PERSON,
} 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
