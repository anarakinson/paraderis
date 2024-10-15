extends CharacterBody2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var edge_detection: RayCast2D = $EdgeDetection


@export_category("Personal metrics")
@export var speed = 2000.0
@export var jump_velocity = -775.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * GlobalParams.gravity_coeff

var direction = 0
var is_walking = false
var tracked_character : CharacterBody2D = null
var tracked_character_position : Vector2 = Vector2(0, 0)

var is_awaiting = false

enum {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	RUNAWAY,
	FALL,
	HIT,
	DIE,
}

var state : int = IDLE:
	set(value):
		state = value
		match state:
			IDLE:
				pass
			PATROL:
				patrol_state()
			CHASE:
				chase_state()
			RUNAWAY:
				runaway_state()
			ATTACK:
				pass
			HIT:
				pass
			DIE:
				pass


func _ready() -> void:
	state = PATROL


func _physics_process(delta: float) -> void:
	
	if state == CHASE:
		chase_state()
	elif state == PATROL:
		patrol_state()


	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not edge_detection.is_colliding():
		full_stop()
	elif is_walking and edge_detection.is_colliding():
		make_move(delta)
	
	#if tracked_character != null:
		#tracked_character_position = tracked_character.global_position
	
	move_and_slide()



func make_move(delta):
	if direction:
		velocity.x = direction * speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, speed *  delta)


func change_direction():
	#print("change direction")
	if animated_sprite_2d.flip_h == true:
		animated_sprite_2d.flip_h = false
		direction = 1
		edge_detection.position.x = 50
	elif animated_sprite_2d.flip_h == false:
		animated_sprite_2d.flip_h = true
		direction = -1
		edge_detection.position.x = -50


func chase_state():
	if tracked_character != null:
		is_walking = true
		if global_position.x > tracked_character.global_position.x + 10:
			animated_sprite_2d.flip_h = true
			direction = -1
			edge_detection.position.x = -50
		elif global_position.x < tracked_character.global_position.x - 10:
			animated_sprite_2d.flip_h = false
			direction = 1
			edge_detection.position.x = 50
		else:
			direction = 0


func patrol_state():
	if not edge_detection.is_colliding() and not is_awaiting:
		full_stop()
		is_awaiting = true
		timer.start(1)
	elif is_awaiting:
		if timer.time_left <= 0:
			is_awaiting = false
			var thresh = randf()
			#print(thresh)
			if thresh > 0.5:
				change_direction()
	elif not is_walking and not is_awaiting:
		var time = randf_range(2, 5)
		timer.start(time)
		is_walking = true
	elif is_walking and not is_awaiting:
		if timer.time_left <= 0:
			is_walking = false
			is_awaiting = true
			full_stop()
			var time = randf_range(1, 4)
			timer.start(time)


func runaway_state():
	pass

func awared():
	state = IDLE
	full_stop()
	timer.stop()
	timer.start(0.5)
	await timer.timeout
	state = CHASE

func distracted():
	state = IDLE
	full_stop()
	timer.stop()
	timer.start(0.5)
	await timer.timeout
	state = PATROL


func _on_sight_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Shady":
		awared()
		tracked_character = body

func _on_sight_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Shady":
		distracted()
		tracked_character = null


func full_stop():
	velocity.x = 0
	is_walking = false
