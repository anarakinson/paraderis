extends CharacterBody2D

class_name Shady


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash_sprite_2d: AnimatedSprite2D = $SlashSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var basic_collision_shape_2d = $BasicCollisionShape2D

@onready var hitpoints: Node2D = $Hitpoints
@onready var damage: Node2D = $Damage

@onready var timer: Timer = $Timer

@onready var edge_detection: RayCast2D = $RayCasts/EdgeDetection
@onready var edge_detection_2: RayCast2D = $RayCasts/EdgeDetection2
@onready var wall_ray_cast: RayCast2D = $RayCasts/WallRayCast
@onready var wall_ray_cast_2: RayCast2D = $RayCasts/WallRayCast2
@onready var climb_ray_cast: RayCast2D = $RayCasts/ClimbRayCast
@onready var climb_ray_cast_2: RayCast2D = $RayCasts/ClimbRayCast2
@onready var climb_shape_cast: ShapeCast2D = $RayCasts/ClimbShapeCast
@onready var ceiling_raycast: RayCast2D = $RayCasts/CeilingRaycast
@onready var lyingl_ray_cast: RayCast2D = $RayCasts/LyinglRayCast
@onready var lyingl_ray_cast_2: RayCast2D = $RayCasts/LyinglRayCast2

@onready var wall_ray_cast_lenght = wall_ray_cast.target_position.x
@onready var climb_shape_cast_x = climb_shape_cast.position.x
@onready var camera_position = $CameraPosition

@export_category("Global metrics")
@export_range(1, 10) var gravity_coeff = 1.75
@export_range(0, 5) var critical_fall_lenght = 0.99

@export_category("Personal metrics")
@export_range(1, 10) var is_bored_timer = 2.5
@export var speed = 500.0
@export var jump_velocity = -775.0
@export var speed_blink = 150.0
@export var koyotee_time = 0.1
@export var camera_position_point = 250

@export_category("Effects")
@export_range(0., 2., 0.1) var slash_glowing: float = .9

@export_category("Parameters")
@onready var attack_cooldown_time: float = GlobalParams.shady_params.attack_cooldown_time


enum {
	IDLE,
	BORED,
	MOVE,
	JUMP,
	JUMP_START,
	JUMP_KOYOTEE,
	FALL,
	DEATH,
	CONJURE,
	MAGIC_ATTACK,
	MAGICAL_STATE,
	DISAPPEAR,
	APPEAR,
	SIT,
	DO_NOTHIG,
	STAND_UP,
	REST,
	LYING,
	FADING,
	WAKE_UP,
	LOOK_UP,
	LOOK_DOWN,
	WALL_CLIMB,
	WALL_CLIMB_PROCESS,
	WALL_BOUNCING,
	ATTACK_PROCESS,
	ATTACK,
	ATTACK_SIT,
	ATTACK_WALL,
	ATTACK_END,
}

enum attack_variants {
	FLOOR, JUMP, UP, DOWN, WALL, SIT
}

var state_dict = {
	IDLE : "IDLE",
	BORED : "BORED",
	MOVE : "MOVE",
	JUMP : "JUMP",
	JUMP_START : "JUMP_START",
	JUMP_KOYOTEE : "JUMP_KOYOTEE",
	FALL : "FALL",
	DEATH : "DEATH",
	CONJURE : "CONJURE",
	MAGIC_ATTACK : "MAGIC_ATTACK",
	MAGICAL_STATE : "MAGICAL_STATE",
	DISAPPEAR : "DISAPPEAR",
	APPEAR : "APPEAR",
	SIT : "SIT",
	DO_NOTHIG : "DO_NOTHIG",
	STAND_UP : "STAND_UP",
	REST : "REST",
	LYING : "LYING",
	FADING : "FADING",
	WAKE_UP : "WAKE_UP",
	LOOK_UP : "LOOK_UP",
	LOOK_DOWN : "LOOK_DOWN",
	WALL_CLIMB : "WALL_CLIMB",
	WALL_CLIMB_PROCESS : "WALL_CLIMB_PROCESS",
	WALL_BOUNCING : "WALL_BOUNCING",
	ATTACK_PROCESS : "ATTACK_PROCESS",
	ATTACK : "ATTACK",
	ATTACK_SIT : "ATTACK_SIT",
	ATTACK_WALL : "ATTACK_WALL",
	ATTACK_END : "ATTACK_END",
}


var state = MOVE

# direction metrics
var face_direction = 1
var direction = 0
var time_to_turn = false
var time_to_climb_up = 0
var fallback_speed = speed / 15

# conditions
var is_in_attack_cooldown = false
var is_in_magical_state = false
var is_floating = false 
var is_bored = false
var is_in_combo = false
var is_koyotee_awailable = false
var is_flickering = false
var full_idle = true
var is_invincible = false
var is_fall_hitted = false

# stater counters
var bored_counter = 0
var fall_counter = 0
var run_counter = 0
var combo_counter = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_coeff


var collider_shape : Dictionary = {
# radius, height, rotation, position_y
	"basic" : [21, 214, 0, 0],
	"run" : [35, 214, 0, 0],
	"lying" : [15, 175, 90, 92],
	"sit" : [60, 120, 0, 47],
	"jump" : [40, 170, 0, 22],
	"on_wall" : [35, 214, 0, 0],
}

func set_collision_shape(shape):
	basic_collision_shape_2d.shape.radius = move_toward(basic_collision_shape_2d.shape.radius, shape[0], 100)
	basic_collision_shape_2d.shape.height = move_toward(basic_collision_shape_2d.shape.height, shape[1], 100)
	basic_collision_shape_2d.rotation_degrees = move_toward(basic_collision_shape_2d.rotation_degrees, shape[2], 100)
	basic_collision_shape_2d.position.y = move_toward(basic_collision_shape_2d.position.y, shape[3], 100)
	damage.set_hurtbox_shape(shape)
	#point_light_2d.global_position = basic_collision_shape_2d.global_position
	#point_light_2d.position.y = move_toward(point_light_2d.position.y, position.y, 5)


func set_direction(coeff = 1, with_sprite=true):
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
	
	set_face_direction(with_sprite)

	if direction < 0:
		face_direction = -1
	elif direction > 0:
		face_direction = 1
	
	camera_position.position.x = camera_position_point * face_direction


func set_face_direction(with_sprite=true):
	if face_direction == -1:
		if with_sprite:
			animated_sprite_2d.flip_h = true 
		wall_ray_cast.target_position.x = -wall_ray_cast_lenght
		climb_ray_cast.target_position.x = -wall_ray_cast_lenght
		climb_ray_cast_2.target_position.x = -wall_ray_cast_lenght
		climb_shape_cast.position.x = -climb_shape_cast_x
	elif face_direction == 1:
		if with_sprite:
			animated_sprite_2d.flip_h = false 
		wall_ray_cast.target_position.x = wall_ray_cast_lenght
		climb_ray_cast.target_position.x = wall_ray_cast_lenght
		climb_ray_cast_2.target_position.x = wall_ray_cast_lenght
		climb_shape_cast.position.x = climb_shape_cast_x


func apply_gravity(delta):
	# Add the gravity.
	if (not is_on_floor() and not is_floating):
		velocity.y += gravity * delta
		if state == WALL_BOUNCING:
			velocity.y = 0
			velocity.x = 0


func _ready() -> void:
	slash_sprite_2d.material.set_shader_parameter("glow_power", slash_glowing)

func _physics_process(delta):
	#print(state_dict[state], " ", combo_counter, " ", fall_counter, " ", is_in_attack_cooldown)
	$Label.text = state_dict[state] + " " + str(is_invincible) + " " + str(hitpoints.is_invincible)
	match state:
		DEATH:
			death_state()
			return
		IDLE:
			idle_state()
			apply_gravity(delta)
			move_and_slide()
			return
		FALL:
			set_collision_shape(collider_shape["jump"])
			fall_state()
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
			set_collision_shape(collider_shape["sit"])
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
			climb_ledge_state(delta)
		WALL_CLIMB_PROCESS:
			set_collision_shape(collider_shape["on_wall"])
			climb_ledge_process(delta)
		WALL_BOUNCING:
			set_collision_shape(collider_shape["on_wall"])
			wall_bouncing_state()
		ATTACK:
			climb_ray_cast.target_position.x = 0
			set_collision_shape(collider_shape["run"])
			attack_state()
		ATTACK_SIT:
			set_collision_shape(collider_shape["sit"])
			attack_sit_state()
		ATTACK_WALL:
			set_collision_shape(collider_shape["on_wall"])
			attack_wall_state()
		ATTACK_PROCESS:
			climb_ray_cast.target_position.x = 0
			attack_process_state()
		ATTACK_END:
			set_collision_shape(collider_shape["basic"])
			attack_end_state()
	
	# Apply gravity
	apply_gravity(delta)
	
	if velocity.y > 0: 
		if state != ATTACK_PROCESS:
			state = FALL
		fall_counter += 1 * delta
	elif velocity.y == 0:
		if fall_counter >= critical_fall_lenght:
			fall_hit_state()
		fall_counter = 0
	

	# DISABLE INPUT
	if state != IDLE:
		direction = Input.get_axis("left", "right")
	
	if is_on_floor() and ceiling_raycast.is_colliding() and state != ATTACK_PROCESS:
		if (state == IDLE or state == MOVE or state == BORED or
			state == LOOK_DOWN or state == LOOK_UP):
			sit_down()
		else:
			state = SIT
	
	##########################
	### Handle actions
	##########################
	if (state == MOVE or state == BORED or
		state == LOOK_DOWN or state == LOOK_UP):
		if Input.is_action_just_pressed("l2_button"):
			disappear()
		if Input.is_action_just_pressed("y_button"):
			interaction_state()
		
		# Conjuring 
		if Input.is_action_pressed("trick"):
			state = CONJURE
		if Input.is_action_pressed("down") and is_on_floor():
			sit_down()
		if Input.is_action_pressed("fading"):
			state = FADING
	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and (state == MOVE or 
			state == STAND_UP or state == BORED or
			state == LOOK_DOWN or state == LOOK_UP):
			state = JUMP_START
			jump_start()
		# koyotee timme
		elif (state == FALL and fall_counter < koyotee_time and is_koyotee_awailable):
			state = JUMP_KOYOTEE
			koyotee_jump_start()
	
	# handle attack
	if Input.is_action_just_pressed("attack"):
		if (state == MOVE or state == BORED or
			state == LOOK_DOWN or state == LOOK_UP or
			state == FALL or state == JUMP):
			state = ATTACK
		
		elif state == WALL_CLIMB:
			state = ATTACK_WALL
		elif state == SIT:
			state = ATTACK_SIT
	
	# wall bouncing
	if (not is_on_floor() and 
		climb_ray_cast.is_colliding() and wall_ray_cast.is_colliding()
		and Input.is_action_just_pressed("jump") 
		and (state == FALL or state == JUMP)):
		velocity.y = 0
		velocity.x = 0
		wall_bouncing()
	
	# ledge climb
	if (
		not is_on_floor() and 
		#(state == FALL or state == JUMP or state == WALL_CLIMB) and
		climb_ray_cast.is_colliding() and 
		not climb_ray_cast_2.is_colliding() and 
		not ceiling_raycast.is_colliding()
	):
		velocity.x = 100 * face_direction
		velocity.y = -jump_velocity
		state = WALL_CLIMB
	
	
	if state == FALL:
		$ClimbCollision.disabled = true
	elif state == WALL_CLIMB:
	#else:
		$ClimbCollision.disabled = false
	
	
	if Input.is_anything_pressed():
		is_bored = false
		bored_counter = 0
	
	
	if (state == IDLE and 
		edge_detection.is_colliding() != edge_detection_2.is_colliding()):
		velocity.x += speed * delta * face_direction
	
	
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
		flickering()
	elif direction == 0 and Input.is_action_pressed("look_down"):
		state = LOOK_DOWN
		


func idle_state():
	pass

func bored_state():
	full_stop()
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
		state = FALL

func jump_start():
	is_koyotee_awailable = false
	velocity.x = 0
	animation_player.play("jump_start")
	await animation_player.animation_finished
	velocity.y = jump_velocity
	animation_player.play("jump")
	state = JUMP
	
func koyotee_jump_start():
	velocity.x = 0
	velocity.y = jump_velocity
	animation_player.play("jump")
	state = JUMP
	is_koyotee_awailable = false


func fall_hit_state():
	state = DO_NOTHIG
	velocity.y = 0
	full_stop()
	is_fall_hitted = true
	hitpoints.decrease(1)
	fall_counter = 0
	set_collision_shape(collider_shape["sit"])
	animation_player.play("fall_hit")
	await animation_player.animation_finished
	state = DO_NOTHIG
	set_collision_shape(collider_shape["lying"])
	await get_tree().create_timer(1).timeout
	hitpoints.invincibility()
	is_fall_hitted = false
	state = LYING


func fall_state():
	time_to_turn = false
	if velocity.y == 0 and is_on_floor():
		if edge_detection.is_colliding() != edge_detection_2.is_colliding():
			velocity.x += speed * face_direction
		if fall_counter < critical_fall_lenght and fall_counter > 0.25:
			full_stop()
			state = DO_NOTHIG
			animation_player.play("landing")
			await animation_player.animation_finished
			state = SIT
		elif fall_counter < 0.25:
			state = MOVE
		else:
			fall_hit_state()
	elif velocity.y > 0:
		set_direction()
		animation_player.play("fall")


func conjure_state():
	full_stop()
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
	$ClimbCollision.disabled = true
	velocity.x = 0
	animation_player.play("throw")
	await animation_player.animation_finished
	state = MOVE


func disappear():
	state = IDLE
	full_stop()
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
	state = DO_NOTHIG
	full_stop()
	if ceiling_raycast.is_colliding():
		animation_player.play("sit_rest_transition")
	else:
		animation_player.play("rest_start")
	await animation_player.animation_finished 
	state = REST 



func rest_state():
	animation_player.play("rest")
	
	if Input.is_anything_pressed():
		state = DO_NOTHIG

		if ceiling_raycast.is_colliding():
			animation_player.play("rest_sit_transition")
			await animation_player.animation_finished
			state = SIT 
		else:
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
	state = DO_NOTHIG
	full_stop()
	set_collision_shape(collider_shape["sit"])
	animation_player.play("sit_start")
	await animation_player.animation_finished
	state = SIT

func sit_state():
	if not Input.is_action_pressed("down") and not ceiling_raycast.is_colliding():
		stand_up()
		await animation_player.animation_finished
		state = MOVE
		return
	if direction:
		full_idle = false
		animation_player.play("sit_walk")
		time_to_turn = false
		set_direction(0.5)
	else:
		animation_player.play("sit_state")
		velocity.x = move_toward(velocity.x, 0, speed)

	if Input.is_action_just_pressed("attack"):
		#stand_up()
		#await animation_player.animation_finished
		state = ATTACK_SIT

	if not ceiling_raycast.is_colliding():
		if Input.is_action_just_pressed("jump"):
			state = JUMP_START
			jump_start()
		#if Input.is_action_just_pressed("y_button"):
			#pass
		if Input.is_action_pressed("trick"):
			stand_up()
			await animation_player.animation_finished
			conjure_state()
			state = CONJURE
		if Input.is_action_just_pressed("l2_button"):
			stand_up()
			await animation_player.animation_finished
			disappear()
		if Input.is_action_just_pressed("y_button"):
			stand_up()
			await animation_player.animation_finished
			interaction_state()

	elif ceiling_raycast.is_colliding():
		if Input.is_action_just_pressed("y_button"):
			interaction_state()




func stand_up():
	state = STAND_UP
	full_stop()
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
	state = DO_NOTHIG 
	full_stop()
	animation_player.play("wake_up")
	await animation_player.animation_finished
	state = MOVE 


func lying_state():
	animation_player.play("lying")
	if Input.is_anything_pressed():
		state = WAKE_UP
		

func fading_state():
	state = DO_NOTHIG 
	full_stop()
	animation_player.play("fading")
	await animation_player.animation_finished
	set_collision_shape(collider_shape["lying"])
	await get_tree().create_timer(2).timeout
	state = LYING


func climb_ledge_state(delta):
	#print("IS ON WALL")
	fall_counter = 0
	$ClimbCollision.disabled = false
	#$ClimbCollision.set_deferred("disabled", false)
	
	if Input.is_action_just_pressed("down"):
		$ClimbCollision.disabled = true
		#$ClimbCollision.set_deferred("disabled", true)
		state = DO_NOTHIG
		animation_player.play("out_wall")
		face_direction = -face_direction
		direction = face_direction
		set_direction()
		await get_tree().create_timer(0.01).timeout
		state = FALL
	elif time_to_climb_up > 0.2 and not climb_shape_cast.is_colliding():
		time_to_climb_up = 0
		full_stop()
		state = WALL_CLIMB_PROCESS
		if not wall_ray_cast.is_colliding():
			animation_player.play("climb2")
		elif wall_ray_cast.is_colliding():
			animation_player.play("climb")
		await animation_player.animation_finished 
		set_collision_shape(collider_shape["sit"])
		$ClimbCollision.disabled = true
		#$ClimbCollision.set_deferred("disabled", true)
		position.x += climb_shape_cast.position.x * scale.x
		position.y += climb_shape_cast.position.y * scale.y
		state = SIT
		
	elif wall_ray_cast.is_colliding():
		animation_player.play("on_wall")
		if Input.is_action_just_pressed("jump"):
			wall_bouncing()
	elif not wall_ray_cast.is_colliding():
		animation_player.play("on_wall2")
	
	if direction == face_direction:
		time_to_climb_up += 1 * delta
	if Input.is_action_pressed("up"):
		time_to_climb_up += 5 * delta 
	elif direction != face_direction:
		time_to_climb_up = 0


func climb_ledge_process(delta):
		#$ClimbCollision.disabled = true
		climb_ray_cast.target_position.x = 0
		climb_ray_cast_2.target_position.x = 0


func wall_bouncing():
	fall_counter = 0
	state = DO_NOTHIG
	velocity.x = 0
	velocity.y = 0
	face_direction = -face_direction
	direction = face_direction
	set_direction()
	state = WALL_BOUNCING

func wall_bouncing_state():
	animation_player.play("wall_jump_start")
	if wall_ray_cast.is_colliding():
		face_direction = -face_direction
		direction = face_direction
		set_direction()
	await animation_player.animation_finished

	animation_player.play("wall_jump")
	velocity.y = jump_velocity * 1.3
	velocity.x = -jump_velocity * face_direction * 0.7
	#await animation_player.animation_finished
	velocity.y = move_toward(velocity.y, 0, -jump_velocity / 2)
	fall_counter = 0
	state = FALL


func attack_state():
	$ClimbCollision.set_deferred("disabled", true)
	if is_in_attack_cooldown:
		state = MOVE
		return
	state = ATTACK_PROCESS 
	if is_on_floor():
		full_stop()

	if Input.is_action_pressed("up"):
		attack_animation(attack_variants.UP)
		damage.attack_start("up", face_direction)
	elif Input.is_action_pressed("down") and not is_on_floor():
		attack_animation(attack_variants.DOWN)
		damage.attack_start("down", face_direction)
	else:
		if is_on_floor():
			#position.x = move_toward(position.x, position.x + face_direction * speed / 15, speed)
			var velocity_addition = GlobalParams.shady_params.attack_direction.x * speed * 2
			velocity.x = velocity_addition
			print(velocity_addition)
			attack_animation(attack_variants.FLOOR)
		else:
			attack_animation(attack_variants.JUMP)
		damage.attack_start("basic", face_direction)
	await animation_player.animation_finished
	state = MOVE

func attack_animation(attack_variant):
	slash_sprite_2d.flip_h = animated_sprite_2d.flip_h
	slash_sprite_2d.visible = true
	match attack_variant:
		attack_variants.FLOOR:
			if combo_counter == 0:
				slash_sprite_2d.play("attack1")
				animation_player.play("attack1")
				combo_counter = 1
			elif combo_counter == 1:
				slash_sprite_2d.play("attack2")
				animation_player.play("attack2")
				combo_counter = 0
			GlobalParams.shady_params.attack_direction = Vector2(face_direction, 0)
		attack_variants.JUMP:
			if combo_counter == 0:
				slash_sprite_2d.play("attack1")
				animation_player.play("attack_jump1")
				combo_counter = 1
			elif combo_counter == 1:
				slash_sprite_2d.play("attack2")
				animation_player.play("attack_jump2")
				combo_counter = 0
			GlobalParams.shady_params.attack_direction = Vector2(face_direction, 0)
		attack_variants.UP:
			slash_sprite_2d.play("attack_up")
			animation_player.play("attack_up")
			GlobalParams.shady_params.attack_direction = Vector2(0, -1)
		attack_variants.DOWN:
			slash_sprite_2d.play("attack_down")
			animation_player.play("attack_down")
			GlobalParams.shady_params.attack_direction = Vector2(0, 1)
		attack_variants.WALL:
			slash_sprite_2d.play("attack_wall")
			animation_player.play("attack_wall")
			GlobalParams.shady_params.attack_direction = Vector2(face_direction, 0)
		attack_variants.SIT:
			slash_sprite_2d.play("attack2")
			animation_player.play("attack2")
			GlobalParams.shady_params.attack_direction = Vector2(face_direction, 0)
	await slash_sprite_2d.animation_finished
	damage.attack_end()
	attack_cooldown()
	slash_sprite_2d.visible = false

func attack_process_state():
	if is_on_floor():
		full_stop()
	else:
		set_direction(0.95, false)
	

func attack_end_state():
	#state = IDLE
	full_stop()
	if Input.is_anything_pressed():
		state = MOVE
	animation_player.play("attack_finished")
	await animation_player.animation_finished
	state = MOVE


func attack_wall_state():
	if is_in_attack_cooldown or !wall_ray_cast.is_colliding():
		state = WALL_CLIMB
		return
	state = ATTACK_PROCESS
	attack_animation(attack_variants.WALL)
	damage.attack_start("basic", -face_direction)
	await animation_player.animation_finished
	state = WALL_CLIMB

func attack_sit_state():
	if is_in_attack_cooldown:
		state = SIT
		return
	state = ATTACK_PROCESS
	attack_animation(attack_variants.SIT)
	damage.attack_start("sit", face_direction)
	await animation_player.animation_finished
	state = SIT

func attack_cooldown():
	is_in_attack_cooldown = true
	await get_tree().create_timer(attack_cooldown_time).timeout
	is_in_attack_cooldown = false

func attack_recoil():
	fall_counter = 0
	#velocity = Vector2(0,0)
	velocity.y = 0
	velocity += GlobalParams.shady_params.recoil_force * GlobalParams.shady_params.attack_direction

func full_stop():
	velocity.x = 0 
	full_idle = true
	run_counter = 0
	bored_counter = 0
	is_koyotee_awailable = true
	
func return_to_checkpoint():
	print("return to checkpoint")
	is_floating = true
	velocity.y = 0
	full_stop()
	fall_counter = 0
	if state == DEATH:
		return
	if GlobalParams.last_checkpoint == null:
		hitpoints.hitpoints = 0 
		hitpoints.decrease(1)
		return
	state = IDLE
	animation_player.play("collapse_start")
	await animation_player.animation_finished
	global_position = GlobalParams.last_checkpoint.global_position
	animation_player.play("collapse_end")
	await animation_player.animation_finished
	hitpoints.invincibility()
	is_floating = false
	state = MOVE
	

func _on_hitpoints_hitted() -> void:
	#print("HIT!")
	if is_fall_hitted:
		return
	state = IDLE
	fall_counter = 0
	full_stop()
	velocity = Vector2(0,0)
	if GlobalParams.shady_params.hazard_direction != 0:
		face_direction = GlobalParams.shady_params.hazard_direction
	velocity = Vector2(-face_direction * speed * 1., -speed * 0.5)
	set_face_direction()
	animation_player.play("hit")
	await get_tree().create_timer(0.25).timeout
	state = MOVE


func _on_hitpoints_time_to_die() -> void:
	death_process()

func death_state():
	pass
	
func death_process():
	print("DIE!")
	state = DEATH
	animation_player.play("collapse_start")
	await animation_player.animation_finished
	visible = false
	queue_free()



func _on_hitpoints_invincibility_start() -> void:
	if is_invincible == true: 
		return
	damage.hurtbox_deactivate()
	is_invincible = true
	is_flickering = true
	flickering()

func _on_hitpoints_invincibility_stop() -> void:
	if is_invincible == false: 
		return
	damage.hurtbox_activate()
	is_invincible = false
	is_flickering = false

func flickering():
	while is_flickering:
		await get_tree().create_timer(0.2).timeout
		animated_sprite_2d.material.set("shader_parameter/quantity", 0.5);
		await get_tree().create_timer(0.2).timeout
		animated_sprite_2d.material.set("shader_parameter/quantity", 0.);
	
