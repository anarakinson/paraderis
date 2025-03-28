extends Node2D


@onready var dust_particles: CPUParticles2D = $DustParticles
@onready var cloud_particles: CPUParticles2D = $CloudParticles
@onready var spark_particles: CPUParticles2D = $SparkParticles
@onready var point_light_2d: PointLight2D = $PointLight2D

@export var color : Color = Color(0.7, 0.8, 1, 0.4)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dust_particles.color = color * 1.5
	cloud_particles.color = color * 1.5
	spark_particles.color = color * 2
	point_light_2d.color = color
	point_light_2d.color.a = 1
	pass # Replace with function body.

		
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("attack"):
		#explode()

func explode():
	point_light_2d.visible = true
	point_light_2d.enabled = true
	dust_particles.emitting = true
	cloud_particles.emitting = true
	spark_particles.emitting = true
	await get_tree().create_timer(0.1).timeout
	point_light_2d.visible = false
	point_light_2d.enabled = false

func set_color(new_color : Color):
	cloud_particles.color_ramp.set_color(0, new_color)
	dust_particles.color_ramp.set_color(0, new_color)
	point_light_2d.color = new_color
