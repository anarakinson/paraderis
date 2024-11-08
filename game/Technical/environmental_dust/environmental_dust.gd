extends Node2D

@onready var particles: CPUParticles2D = $CPUParticles2D

@export var init_amount = 8
@export var scale_coeff = 1.
@export var win_size = Vector2(512, 512)
@export var emission_rect : ColorRect = null

func _ready() -> void:
	particles.scale_amount_min * scale_coeff
	particles.scale_amount_max * scale_coeff
	#var win_size = size
	if emission_rect != null:
		win_size = emission_rect.size
		particles.global_position = emission_rect.position + win_size / 2
	else:
		particles.position = win_size / 2
	particles.set_emission_rect_extents(win_size / 2)
	particles.amount = int(win_size.x / 1152 * init_amount / 2) * int(win_size.y / 648 * init_amount / 4)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
