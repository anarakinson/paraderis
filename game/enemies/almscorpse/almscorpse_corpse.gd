extends CharacterBody2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction = 0

func _ready() -> void:
	#visible = false
	pass

func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func set_type(color : String):
	if color == "yellow":
		animated_sprite_2d.play("yellow")
	elif color == "blue":
		animated_sprite_2d.play("blue")
	elif color == "orange":
		animated_sprite_2d.play("orange")
	else:
		animated_sprite_2d.play("yellow")
