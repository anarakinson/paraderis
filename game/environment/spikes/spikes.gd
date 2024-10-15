extends ColorRect

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape_2d.shape.extents = size/2
	collision_shape_2d.global_position = global_position + size/2
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("HIT!")
	if body.name == "Shady":
		body.hitpoints.decrease(1)
		body.return_to_checkpoint()
	elif body.is_in_group("enemies"):
		body.died()

#func _on_area_2d_area_entered(area: Area2D) -> void:
	#if body.name == "Hurtbox":
		#body.hitpoints.decrease(1)
		#body.return_to_checkpoint()
