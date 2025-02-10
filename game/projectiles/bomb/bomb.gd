extends RigidBody2D

var pre_explosion = preload("res://game/effects/fireburst/fireburst.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node) -> void:
	explode(0.2)


func explode(after : float):
	call_deferred("explode_deferred", after)
	
func explode_deferred(after : float):
	var explosion = pre_explosion.instantiate()
	get_parent().add_child(explosion)
	await get_tree().create_timer(after).timeout
	explosion.global_position = global_position
	explosion.set_color(Color(1, 0.9, 0.7, 1))
	explosion.explode()
	await get_tree().create_timer(0.05).timeout
	explosion.global_position = global_position
	
	queue_free()


func throw(direction : Vector2, initial_speed : float = 1000):
	linear_velocity = initial_speed * direction
	animated_sprite.play("active")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "Hitbox" and area.get_parent() != self:
		linear_velocity *= Vector2(-1, -0.6)
		explode(0.3)
