extends RigidBody2D

var pre_explosion = preload("res://game/effects/fireburst/fireburst.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node) -> void:
	var explosion = pre_explosion.instantiate()
	get_parent().add_child(explosion)
	await get_tree().create_timer(0.2).timeout
	explosion.global_position = global_position
	explosion.explode()
	await get_tree().create_timer(0.05).timeout
	explosion.global_position = global_position
	queue_free()


func throw(direction : Vector2):
	linear_velocity = 1000 * direction
	animated_sprite.play("active")
