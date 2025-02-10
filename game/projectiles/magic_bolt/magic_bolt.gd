extends RigidBody2D

@export var color : Color = Color(0.7, 0.8, 1, 1)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var magic_trail: Node2D = $MagicTrail
@onready var hitbox: Area2D = $Hitbox
@onready var timer: Timer = $Timer

var direction : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	magic_trail.color = color
	animated_sprite.modulate = color * 1.5
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#var pos = self.global_position
	#magic_trail.follow(pos)
	#animated_sprite.global_position = pos


#func _input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed:
		#if event.as_text() == "Y":
			#var pos = get_global_mouse_position()
			#global_position = pos
			#throw(Vector2(1, 0), 1200)


func throw(dir : Vector2, initial_speed : int):
	direction = dir
	if direction.x > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	linear_velocity = initial_speed * direction
	animated_sprite.play("active")
	#await get_tree().create_timer(0.01).timeout
	hitbox.enable()
	timer.start(0.21)


func _on_timer_timeout() -> void:
	queue_free()
	
	#linear_velocity = Vector2(0,0)
	#global_position = Vector2(0,0)
	
