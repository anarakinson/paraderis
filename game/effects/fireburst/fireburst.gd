extends Node2D

@onready var smoke_particles: CPUParticles2D = $SmokeParticles
@onready var explosion_particles: CPUParticles2D = $ExplosionParticles
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var hitbox: Area2D = $Hitbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox.knockback_force = 600
	hitbox.damage = 2
	pass # Replace with function body.



func explode():
	#print("explode", hitbox.damage, hitbox.knockback_force)
	explosion_particles.emitting = true
	await get_tree().create_timer(0.2).timeout
	hitbox.collision.disabled = false
	smoke_particles.emitting = true
	point_light_2d.enabled = true
	GlobalParams.screenshake.emit(0.7, 25)
	await get_tree().create_timer(0.1).timeout
	hitbox.collision.disabled = true
	point_light_2d.enabled = false
	await smoke_particles.finished
	queue_free()
