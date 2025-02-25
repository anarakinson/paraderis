extends Control

var is_active = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	process_mode = Node.PROCESS_MODE_ALWAYS


func activate():
	print("activate ", is_active)
	if is_active == true:
		visible = false
		is_active = false
		get_tree().paused = false
	elif is_active == false:
		visible = true
		is_active = true
		get_tree().paused = true
	

func _on_resume_pressed() -> void:
	#print("resume")
	activate()
	
func _on_options_pressed() -> void:
	#print("options")
	pass # Replace with function body.
	
func _on_quit_pressed() -> void:
	#print("quit")
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		if get_tree().paused and event.is_action("pause"):
			await get_tree().create_timer(0.01).timeout
			activate()


func _on_visibility_changed() -> void:
	$CanvasLayer.visible = visible
