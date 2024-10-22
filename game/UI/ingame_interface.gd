extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalParams.connect("ui_update", _on_ui_update)
	
	_on_ui_update()


func _process(delta: float) -> void:
	pass


func display_hp():
	$HP.text = "HP: " + str(GlobalParams.shady_params.hitpoints) + "/" + str(GlobalParams.shady_params.max_hitpoints)


func _on_ui_update():
	display_hp()
