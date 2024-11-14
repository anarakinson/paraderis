extends Control

@onready var particles0: CPUParticles2D = $Parallax0/ParallaxLayer/CPUParticles2D
@onready var particles1: CPUParticles2D = $Parallax1/ParallaxLayer/CPUParticles2D
@onready var particles2: CPUParticles2D = $Parallax2/ParallaxLayer/CPUParticles2D
@onready var particles3: CPUParticles2D = $Parallax3/ParallaxLayer/CPUParticles2D
@onready var particles4: CPUParticles2D = $Parallax4/ParallaxLayer/CPUParticles2D
@onready var particles5: CPUParticles2D = $Parallax5/ParallaxLayer/CPUParticles2D


@export var init_amount = 8


func _ready() -> void:
	var win_size = size
	
	particles0.global_position = global_position + win_size / 2
	particles0.set_emission_rect_extents(win_size)

	particles1.global_position = global_position + win_size / 2
	particles1.set_emission_rect_extents(win_size)

	particles2.global_position = global_position + win_size / 2
	particles2.set_emission_rect_extents(win_size)

	particles3.global_position = global_position + win_size / 2
	particles3.set_emission_rect_extents(win_size)

	particles4.global_position = global_position + win_size / 2
	particles4.set_emission_rect_extents(win_size)

	particles5.global_position = global_position + win_size / 2
	particles5.set_emission_rect_extents(win_size)


	particles0.scale_amount_min *= 0.5
	particles0.scale_amount_max *= 0.5

	particles1.scale_amount_min *= 0.75
	particles1.scale_amount_max *= 0.75

	particles2.scale_amount_min *= 0.1
	particles2.scale_amount_max *= 0.1

	particles3.scale_amount_min *= 1.1
	particles3.scale_amount_max *= 1.1

	particles4.scale_amount_min *= 1.5
	particles4.scale_amount_max *= 1.5

	particles5.scale_amount_min *= 2.
	particles5.scale_amount_max *= 2.


	var win_size_x = 1152
	var win_size_y = 648

	particles0.amount = int(
		win_size.x / win_size_x * init_amount / 2) * \
		int(win_size.y / win_size_y * init_amount / 4 * \
		1.
	)
	particles1.amount = int(
		win_size.x / win_size_x * init_amount / 2) * \
		int(win_size.y / win_size_y * init_amount / 4 * \
		0.9
	)
	particles2.amount = int(
		win_size.x / win_size_x * init_amount / 2) * \
		int(win_size.y / win_size_y * init_amount / 4 * \
		0.8
	)
	particles3.amount = int(
		win_size.x / win_size_x * init_amount / 2) * \
		int(win_size.y / win_size_y * init_amount / 4 * \
		0.7
	)
	particles4.amount = int(
		win_size.x / win_size_x * init_amount / 2) * \
		int(win_size.y / win_size_y * init_amount / 4 * \
		0.6
	)

	particles5.amount = int(
		win_size.x / win_size_x * init_amount / 2) * \
		int(win_size.y / win_size_y * init_amount / 4 * \
		0.5
	)

	print("particles 0: ", particles0.amount)
	print("particles 1: ", particles1.amount)
	print("particles 2: ", particles2.amount)
	print("particles 3: ", particles3.amount)
	print("particles 4: ", particles4.amount)
	print("particles 5: ", particles5.amount)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
