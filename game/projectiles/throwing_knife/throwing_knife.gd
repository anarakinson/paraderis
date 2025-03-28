extends RigidBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer


var collision_counter = 0
var direction = Vector2(1, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape.shape = collision_shape.shape.duplicate(true)
	pass # Replace with function body.


func _process(delta: float) -> void:
	if collision_counter == 0:
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
	if collision_counter == 0:
		gravity_scale = 1
		collision_counter += 1
		hitbox.disable()
		set_collision_mask_value(2, false)
		set_collision_mask_value(3, false)
		linear_velocity.x = 200 * -direction.x
		linear_velocity.y = -150
		angular_velocity = 100
		animated_sprite.play("default")
		timer.stop()
		timer.start(5)
	elif collision_counter == 1:
		timer.stop()
		timer.start(5)


func throw(dir : Vector2, initial_speed : float = 2300):
	direction = dir
	if direction.x > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	if direction.x != 0 and direction.y != 0:
		direction *= 0.65
	linear_velocity = initial_speed * direction
	animated_sprite.play("active")
	timer.start(1)
	await get_tree().create_timer(0.02).timeout
	hitbox.enable()



func _on_body_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		#await get_tree().create_timer(0.01).timeout
		call_deferred("queue_free")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "Hitbox" and area.get_parent() != self:
		linear_velocity *= Vector2(-1, -0.8)


func _on_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.3)
	tween.tween_callback(queue_free)
