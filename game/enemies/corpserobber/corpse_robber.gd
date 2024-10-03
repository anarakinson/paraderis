extends CharacterBody2D


@onready var sight_area_2d: Area2D = $SightArea2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_category("Personal metrics")
@export var speed = 400.0
@export var jump_velocity = -775.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * GlobalParams.gravity_coeff

var direction = 0


enum {
	IDLE,
	PATROL,
	CHASE,
	RUNAWAY,
	AWARE,
	DIE,
}


var state = PATROL


func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			pass
		PATROL:
			pass
		CHASE:
			pass
		RUNAWAY:
			pass
		AWARE:
			pass
		DIE:
			pass


	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta


	#if direction:
		#velocity.x = direction * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _on_sight_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Shady":
		print("see ya")
		state = AWARE
