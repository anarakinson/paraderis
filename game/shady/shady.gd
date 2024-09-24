extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var camera_2d = $Camera2D
@onready var edge_detection = $EdgeDetection
@onready var edge_detection_2 = $EdgeDetection2

@onready var wall_ray_cast = $WallRayCast
@onready var climb_ray_cast = $ClimbRayCast
@onready var climb_ray_cast_2 = $ClimbRayCast2


@export_category("Global metrics")
@export_range(1, 10) var gravity_coeff = 1.75
@export_range(0, 5) var critical_fall_lenght = 0.8

@export_category("Personal metrics")
@export_range(1, 10) var is_bored_timer = 2.5
@export var speed = 500.0
@export var jump_velocity = -750
@export var speed_blink = 150

@export var health = 5


@onready var basic_collision_shape_2d = $BasicCollisionShape2D


enum {
	IDLE,
	BORED,
	MOVE,
	JUMP,
	JUMP_START,
	FALL,
	DEATH,
	CONJURE,
	MAGIC_ATTACK,
	MAGICAL_STATE,
	DISAPPEAR,
	APPEAR,
	SIT,
	STAND_UP,
	REST,
	LYING,
	FADING,
	WAKE_UP,
	LOOK_UP,
	LOOK_DOWN,
	WALL_CLIMB,
	WALL_BOUNCING,
	ATTACK,
	ATTACK_JUMP,
	ATTACK_WALL,
}


# direction metrics
var face_direction = 1
var direction = 0
var time_to_turn = false

var state = MOVE

# conditions
var is_in_magical_state = false
var is_floating = false 
var is_bored = false
var full_idle = true

# stater counters
var bored_counter = 0
var fall_counter = 0
var run_counter = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_coeff


var collider_shape : Dictionary = {
# radius, height, rotation, position_y
	"basic" : [21, 214, 0, 0],
	"run" : [35, 214, 0, 0],
	"lying" : [21, 224, 90, 86],
	"sit" : [61, 122, 0, 46],
	"jump" : [47, 152, 0, 0],
	"on_wall" : [35, 200, 0, 0],
}

func set_collision_shape(shape):
	basic_collision_shape_2d.shape.radius = move_toward(basic_collision_shape_2d.shape.radius, shape[0], 200)
	basic_collision_shape_2d.shape.height = move_toward(basic_collision_shape_2d.shape.height, shape[1], 200)
	basic_collision_shape_2d.rotation_degrees = move_toward(basic_collision_shape_2d.rotation_degrees, shape[2], 200)
	basic_collision_shape_2d.position.y = move_toward(basic_collision_shape_2d.position.y, shape[3], 200)


func set_direction(coeff = 1):
	#print(direction)
	# Get the input direction and handle the movement/deceleration.
	if ((direction > 0 and face_direction == -1) or
		(direction < 0 and face_direction == 1)):
		time_to_turn = true
		run_counter = 0
		velocity.x = 0
	else:
		#time_to_turn = false
		velocity.x = direction * speed * coeff
	
	if face_direction == -1:
		animated_sprite_2d.flip_h = true 
		wall_ray_cast.target_position.x = -55
		climb_ray_cast.target_position.x = -55
		climb_ray_cast_2.target_position.x = -55
	elif face_direction == 1:
		animated_sprite_2d.flip_h = false 
		wall_ray_cast.target_position.x = 55
		climb_ray_cast.target_position.x = 55
		climb_ray_cast_2.target_position.x = 55
	
	if direction < 0:
		face_direction = -1
	elif direction > 0:
		face_direction = 1



func _physics_process(delta):
	print(state)
	#print(direction, face_direction)
	match state:
		IDLE:
			idle_state()
		FALL:
			set_collision_shape(collider_shape["jump"])
			fall_state(delta)
		MOVE:
			set_collision_shape(collider_shape["basic"])
			move_state(delta)
		BORED:
			set_collision_shape(collider_shape["basic"])
			bored_state()
		SIT:
			set_collision_shape(collider_shape["sit"])
			sit_state()
		STAND_UP:
			set_collision_shape(collider_shape["sit"])
			pass
		JUMP:
			set_collision_shape(collider_shape["jump"])
			jump_state()
		JUMP_START:
			set_collision_shape(collider_shape["basic"])
			pass
		CONJURE:
			set_collision_shape(collider_shape["basic"])
			conjure_state()
		MAGIC_ATTACK:
			set_collision_shape(collider_shape["basic"])
			magic_attack_state()
		REST:
			set_collision_shape(collider_shape["sit"])
			rest_state()
		FADING:
			set_collision_shape(collider_shape["sit"])
			fading_state()
		LYING:
			set_collision_shape(collider_shape["lying"])
			lying_state()
		WAKE_UP:
			set_collision_shape(collider_shape["sit"])
			wake_up_state()
		LOOK_UP:
			set_collision_shape(collider_shape["basic"])
			look_up_state()
		LOOK_DOWN:
			set_collision_shape(collider_shape["basic"])
			look_down_state()
		WALL_CLIMB:
			set_collision_shape(collider_shape["on_wall"])
			climb_ledge_state()
		WALL_BOUNCING:
			pass
	
	
	
	# Add the gravity.
	if (not is_on_floor() and not is_floating):
		velocity.y += gravity * delta
		if state == WALL_BOUNCING:
			velocity.y = 0
			velocity.x = 0
	
	if velocity.y > 0:
		state = FALL
	
	if health <= 0:
		animation_player.play("collapse_start")
		health = 0
		state = DEATH
	

	# DISABLE INPUT
	direction = Input.get_axis("left", "right")
	
	
	# Handle jump.
	if (is_on_floor() and Input.is_action_just_pressed("jump")
	 	and (state == MOVE or state == SIT or state == STAND_UP or state == BORED
			or state == LOOK_DOWN or state == LOOK_UP)):
		state = JUMP_START
		jump_start()
	
	# wall bouncing
	if (not is_on_floor() and 
		climb_ray_cast.is_colliding() and wall_ray_cast.is_colliding()
		and Input.is_action_just_pressed("jump") 
		and (state == FALL or state == JUMP)):
		velocity.y = 0
		velocity.x = 0
		wall_bouncing()
	
	# ledge climb
	if ((state == FALL or state == JUMP) and
		climb_ray_cast.is_colliding() and not climb_ray_cast_2.is_colliding()):
		velocity.x = 100 * face_direction
		velocity.y = -jump_velocity
		state = WALL_CLIMB
	
	
	if state == FALL:
		$ClimbCollision.disabled = true
	elif state == WALL_CLIMB:
		$ClimbCollision.disabled = false
	
	
	if Input.is_anything_pressed():
		is_bored = false
		bored_counter = 0

	###################################
	# Handle actions
	if (state == MOVE or state == BORED or
		state == LOOK_DOWN or state == LOOK_UP):
		if Input.is_action_just_pressed("l2_button"):
			disappear()
		if Input.is_action_just_pressed("y_button"):
			interaction_state()
		
		# Conjuring 
		if Input.is_action_pressed("trick"):
			state = CONJURE
		if Input.is_action_pressed("down"):
			sit_down()
		if Input.is_action_pressed("fading"):
			state = FADING
	
	
	move_and_slide()


func move_state(delta):
	
	# Run
	if direction:
		set_collision_shape(collider_shape["run"])
		full_idle = false
		run_counter += 1 * delta
		set_direction()
		if velocity.y == 0:
			if time_to_turn:
				animation_player.play("run_turn")
				velocity.x = 0
				if run_counter >= animation_player.current_animation_length:
					time_to_turn = false
			else:
				animation_player.play("run")
	else:
		time_to_turn = false
		velocity.x = move_toward(velocity.x, 0, speed / 4)
		if velocity.y == 0:
			if full_idle or run_counter <= 0.2:
				run_counter = 0
				animation_player.play("idle")
				bored_counter += 1 * delta
				#print(bored_counter)
				if (bored_counter > is_bored_timer or 
					not edge_detection.is_colliding() or 
					not edge_detection_2.is_colliding()):
					state = BORED
			else:
				animation_player.play("run_stop")
				await animation_player.animation_finished
				full_idle = true

	if direction == 0 and Input.is_action_pressed("look_up"):
		state = LOOK_UP
	elif direction == 0 and Input.is_action_pressed("look_down"):
		state = LOOK_DOWN


func idle_state():
	pass

func bored_state():
	if Input.is_anything_pressed():
		state = MOVE
	if is_bored:
		animation_player.play("bored")
	elif not is_bored:
		animation_player.play("bored_trans_idle")
		await animation_player.animation_finished
		is_bored = true


func jump_state():
	set_direction()
	if not Input.is_action_pressed("jump"):
		velocity.y = move_toward(velocity.y, 0, -jump_velocity / 2)
		#velocity.y = -jump_velocity / 2
		state = FALL

func jump_start():
	velocity.x = 0
	animation_player.play("jump_start")
	await animation_player.animation_finished
	velocity.y = jump_velocity
	animation_player.play("jump")
	state = JUMP

func fall_state(delta):
	time_to_turn = false
	if velocity.y == 0:
		velocity.x = 0
		full_idle = true
		if fall_counter >= critical_fall_lenght:
			state = IDLE
			set_collision_shape(collider_shape["lying"])
			animation_player.play("fall_hit")
			await animation_player.animation_finished
			await get_tree().create_timer(1).timeout
			state = LYING
		else:
			animation_player.play("landing")
			await animation_player.animation_finished
			state = SIT
		fall_counter = 0
	elif velocity.y > 0:
		#print(fall_counter)
		fall_counter += 1 * delta
		set_direction()
		animation_player.play("fall")


func conjure_state():
	velocity.x = 0
	full_idle = true
	animation_player.play("conjure")
	if Input.is_action_just_released("trick"):
		state = MOVE
	if Input.is_action_just_pressed("attack"):
		set_direction()
		state = MAGIC_ATTACK

	#if timer.is_stopped():
		#state = IDLE
		#timer.start(1)
		#await timer.timeout
		#disappear()


func magic_attack_state():
	velocity.x = 0
	animation_player.play("throw")
	await animation_player.animation_finished
	state = MOVE


func disappear():
	state = IDLE
	velocity.x = 0
	full_idle = true
	is_floating = true
	animation_player.play("collapse_start")
	#is_in_magical_state = true 
	await animation_player.animation_finished
	appear()

func appear():
	position.x += speed_blink * face_direction
	animation_player.play("collapse_end")
	await animation_player.animation_finished
	is_floating = false
	state = SIT

func interaction_state():
	
	##########################
	# !!!if restplace near!!!
	##########################
	state = IDLE
	velocity.x = 0
	full_idle = true
	animation_player.play("rest_start")
	await animation_player.animation_finished 
	state = REST 
	
func rest_state():
	animation_player.play("rest")
	
	if Input.is_anything_pressed():
		state = IDLE
		animation_player.play("rest_awake")
		await animation_player.animation_finished
		state = MOVE


func look_up_state():
	animation_player.play("look_up")
	if Input.is_action_just_released("look_up"):
		state = MOVE
	if direction or is_any_button_pressed():
		state = MOVE

func look_down_state():
	animation_player.play("look_down")
	if Input.is_action_just_released("look_down"):
		state = MOVE
	if direction or is_any_button_pressed():
		state = MOVE

func sit_down():
	state = IDLE
	velocity.x = 0
	full_idle = true
	set_collision_shape(collider_shape["sit"])
	animation_player.play("sit_start")
	await animation_player.animation_finished
	state = SIT

func sit_state():
	if not Input.is_action_pressed("down"):
		stand_up()
		await animation_player.animation_finished
		state = MOVE
	if direction:
		full_idle = false
		animation_player.play("sit_walk")
		set_direction(0.5)
	else:
		animation_player.play("sit_state")
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if Input.is_action_just_pressed("attack"):
		pass
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#await animation_player.animation_finished
		#jump_start()
	#if Input.is_action_just_pressed("y_button"):
		#pass
	if Input.is_action_just_pressed("trick"):
		stand_up()
		await animation_player.animation_finished
		conjure_state()
		state = CONJURE
	if Input.is_action_just_pressed("l2_button"):
		stand_up()
		await animation_player.animation_finished
		disappear()
	

func stand_up():
	state = STAND_UP
	velocity.x = 0
	full_idle = true
	animation_player.play("sit_end")


func is_any_button_pressed():
	return (
		Input.is_action_just_pressed("attack") or 
		Input.is_action_just_pressed("jump") or 
		Input.is_action_just_pressed("y_button") or 
		Input.is_action_just_pressed("trick") or 
		Input.is_action_just_pressed("r2_button") or 
		Input.is_action_just_pressed("l2_button")
	)


func wake_up_state():
	state = IDLE 
	velocity.x = 0 
	full_idle = true
	animation_player.play("wake_up")
	await animation_player.animation_finished
	state = MOVE 


func lying_state():
	animation_player.play("lying")
	if Input.is_anything_pressed():
		state = WAKE_UP
		

func fading_state():
	state = IDLE 
	velocity.x = 0 
	full_idle = true
	animation_player.play("fading")
	await animation_player.animation_finished
	set_collision_shape(collider_shape["lying"])
	await get_tree().create_timer(2).timeout
	state = LYING



func climb_ledge_state():
	#print("IS ON WALL")
	fall_counter = 0
	$ClimbCollision.disabled = false
	
	if wall_ray_cast.is_colliding():
		animation_player.play("on_wall")
		if Input.is_action_just_pressed("jump"):
			wall_bouncing()
	elif not wall_ray_cast.is_colliding():
		#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		animation_player.play("on_wall")
	if Input.is_action_just_pressed("down"):
		animation_player.play("out_wall")
		face_direction = -face_direction
		direction = face_direction
		set_direction()
	elif Input.is_action_just_pressed("up"):
		state = IDLE
		animation_player.play("climb")
		await animation_player.animation_finished 
		position.x += 98 * face_direction * scale.x
		position.y -= 198 * scale.y
		animation_player.play("climb_finish")
		await animation_player.animation_finished 
		stand_up()
		await animation_player.animation_finished
		state = MOVE



func wall_bouncing():
	state = WALL_BOUNCING
	velocity.x = 0
	velocity.y = 0

	face_direction = -face_direction
	direction = face_direction
	set_direction()
	
	animation_player.play("wall_jump_start")
	await animation_player.animation_finished
	state = IDLE
	animation_player.play("wall_jump")
	velocity.y = jump_velocity * 1.3
	velocity.x = -jump_velocity * face_direction * 0.7
	#await animation_player.animation_finished
	velocity.y = move_toward(velocity.y, 0, -jump_velocity / 2)
	fall_counter = 0
	state = FALL








