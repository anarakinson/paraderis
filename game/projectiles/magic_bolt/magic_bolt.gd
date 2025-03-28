extends RigidBody2D

@export var color : Color = Color(0.7, 0.8, 1, 1)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var magic_trail: Node2D = $MagicTrail
@onready var hitbox: Area2D = $Hitbox
@onready var timer: Timer = $Timer
@onready var timer_sin: Timer = $TimerSin
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var flight_variance = 0.05

const pre_explosion = preload("res://game/effects/magic/magic_puff/magic_puff.tscn")

var direction : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	magic_trail.color = color
	animated_sprite.modulate = color * 1.5
	collision_shape.shape = collision_shape.shape.duplicate(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var pos = self.global_position
	#magic_trail.follow(animated_sprite.global_position)
	#animated_sprite.global_position = pos
	rotation_degrees = get_degrees()
	
	
	
func get_degrees():
	if abs(linear_velocity.x) > abs(2*linear_velocity.y):
		return 0
	elif abs(linear_velocity.y) > abs(2*linear_velocity.x):
		return 90
	else:
		if linear_velocity.y >= 0 and linear_velocity.x >= 0: 
			return 45
		elif linear_velocity.y < 0 and linear_velocity.x >= 0: 
			return -45
		elif linear_velocity.y >= 0 and linear_velocity.x < 0: 
			return -45
		elif linear_velocity.y < 0 and linear_velocity.x < 0: 
			return 45


func _on_body_entered(body: Node) -> void:
	call_deferred("explode_deferred")
	
func explode_deferred():
	var explosion = pre_explosion.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	#explosion.set_color(Color(1, 0.9, 0.7, 1))
	explosion.explode()
	explosion.global_position = global_position
	
	queue_free()


func throw(dir : Vector2, initial_speed : int = 3000):
	direction = dir
	if direction.x > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	if direction.x != 0 and direction.y != 0:
		direction *= 0.65
	linear_velocity = initial_speed * direction
	animated_sprite.play("active2")
	timer.start(0.5)
	await get_tree().create_timer(0.02).timeout
	hitbox.enable()


func _on_timer_timeout() -> void:
	call_deferred("explode_deferred")
	#queue_free()
	
	#linear_velocity = Vector2(0,0)
	#global_position = Vector2(0,0)
	


func _on_timer_sin_timeout() -> void:
	timer_sin.start(randf_range(0.01, 0.03))
	linear_velocity.x += linear_velocity.y * randf_range(-flight_variance, flight_variance)
	linear_velocity.y += linear_velocity.x * randf_range(-flight_variance, flight_variance)
	pass # Replace with function body.
