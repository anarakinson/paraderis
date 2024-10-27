extends Area2D


#@export var next_room : Resource
@export_file() var next_room : String


func _on_body_entered(body: Node2D) -> void:
	#print("TRANSITION: ", next_room)
	if body.name == "Shady" and next_room != null:
		#next_room.get_path()
		SceneTransition.change_scene_to_file(next_room)
