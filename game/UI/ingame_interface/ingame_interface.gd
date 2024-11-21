extends Control

@onready var blur_rect: ColorRect = $Blur
@onready var blood_rect = $BloodRect
@onready var HP: Label = $HP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalParams.connect("ui_update", _on_ui_update)
	GlobalParams.connect("death", _on_death)
	_on_ui_update()
	
	visible = true
	
	blood_rect.visible = false
	blur_rect.visible = false


func display_hp():
	HP.text = "HP: " + str(GlobalParams.shady_params.hitpoints) + "/" + str(GlobalParams.shady_params.max_hitpoints)


func _on_ui_update():
	display_hp()


func _on_death():
	HP.visible = false
	blood_rect.visible = true
	blood_rect.modulate.a = 0.
	blur_rect.material.set("shader_parameter/amount", 0.);
	blur_rect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(blur_rect, "material:shader_parameter/amount", 2.5, 8.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(blood_rect, "modulate:a", 0.5, 7.5)
	
