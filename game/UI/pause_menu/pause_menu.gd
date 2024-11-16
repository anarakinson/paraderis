extends Control

var is_active = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pass # Replace with function body.


func activate():
	if is_active == true:
		visible = false
		is_active = false
		get_tree().paused = false
	elif is_active == false:
		visible = true
		is_active = true
		get_tree().paused = true
	

func _on_resume_pressed() -> void:
	activate()
	
func _on_options_pressed() -> void:
	pass # Replace with function body.
	
func _on_quit_pressed() -> void:
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		if event.is_action("pause"):
			print("escape")
			visible = false
			is_active = false
			get_tree().paused = false
