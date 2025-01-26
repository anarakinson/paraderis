extends RigidBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var collision_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_body_entered(body: Node) -> void:
	gravity_scale = 1
	collision_counter += 1
	hitbox.disable()
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)
	if collision_counter == 1:
		linear_velocity *= Vector2(-0.4, -0.4)
		angular_velocity = 100
		animated_sprite.play("default")
		collision_shape.shape.height = 28
		collision_shape.shape.radius = 2
	elif collision_counter == 2:
		linear_velocity *= Vector2(-0.4, -0.4)
		angular_velocity /= 2


func throw(direction : Vector2):
	if direction.x > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	linear_velocity = 1800 * direction
	collision_shape.shape.height = 10
	collision_shape.shape.radius = 6
	animated_sprite.play("active")
	#await get_tree().create_timer(0.01).timeout
	hitbox.enable()


func _on_body_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		await get_tree().create_timer(0.05).timeout
		queue_free()
