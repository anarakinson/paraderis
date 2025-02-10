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
	if gravity_scale <= 1:
		gravity_scale += delta


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
		collision_shape.shape.height = 28
		collision_shape.shape.radius = 2
		timer.start(15)
	elif collision_counter == 1:
		timer.stop()
		timer.start(5)


func throw(dir : Vector2, initial_speed : float = 1800):
	direction = dir
	if direction.x > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	linear_velocity = initial_speed * direction
	animated_sprite.play("active")
	#await get_tree().create_timer(0.01).timeout
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
