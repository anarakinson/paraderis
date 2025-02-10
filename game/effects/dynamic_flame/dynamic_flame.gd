extends Node2D

@onready var smoke_particles: CPUParticles2D = $SmokeParticles
@onready var fire_particles: CPUParticles2D = $FireParticles
@onready var spartk_particles: CPUParticles2D = $SpartkParticles
@onready var timer: Timer = $Timer

@export var sparks_on = true
@export var color : Color = Color(1, 1, 1, 1)

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fire_particles.color = color * 2
	if sparks_on:
		spartk_particles.color = color * 2
		var random_delay = rng.randf_range(0.1, 0.7)
		timer.start(random_delay)
		spartk_particles.emitting = true


func _on_timer_timeout() -> void:
	var random_delay = rng.randf_range(2.5, 3.7)
	timer.start(random_delay)
	spartk_particles.emitting = true
