extends CharacterBody2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var label: Label = $Label
@onready var edge_detection: RayCast2D = $EdgeDetection
@onready var wall_detection: ShapeCast2D = $WallDetection
@onready var enemy_damage: Node2D = $EnemyDamage

@onready var hurtbox_collision: CollisionShape2D = $EnemyDamage/Hurtbox/CollisionShape2D
@onready var hitbox_collision: CollisionShape2D = $EnemyDamage/Hitbox/CollisionShape2D
@onready var attack_collision: CollisionShape2D = $EnemyDamage/AttackArea/CollisionShape2D

@onready var forward_vision_ray: ShapeCast2D = $Vision/ForwardVisionRay
@onready var back_vision_ray: ShapeCast2D = $Vision/BackVisionRay


@export_group("Parameters")
@export var damage = 1
@export var hitpoints = 4
@export var direction = 1


@export_category("Personal metrics")
@export var speed = 2000.0
@export var speed_chase = 2500.
@export var jump_velocity = -775.0
@export var hit_inertion = 1500
@export var idle_stand : bool = false 
@export var chase_modifier = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * GlobalParams.gravity_coeff

var face_direction = 1
var is_walking = false
var tracked_character : CharacterBody2D = null
var tracked_character_position : Vector2 = Vector2(0, 0)

var is_awaiting = false
#var is_knocked_back = false 

var counter : float = 0

enum {
	IDLE,
	DO_NOTHING,
	PATROL,
	CHASE,
	ATTACK,
	HIT,
	DEATH,
} 

var state : int = IDLE:
	set(value):
		state = value
		match state:
			DEATH:
				died()
			IDLE:
				pass
			PATROL:
				patrol_state()
			CHASE:
				chase_state()
			ATTACK:
				pass
			HIT:
				hitted_state()
			DO_NOTHING:
				back_vision_ray.target_position.x = 50

		if state != PATROL:
			is_awaiting = false
			
		if state == HIT:
			modulate.g = 0.75
			modulate.b = 0.75
			$EnemyDamage/Hurtbox/CollisionShape2D.disabled = true
		elif state != HIT:
			modulate.g = 1
			modulate.b = 1
			$EnemyDamage/Hurtbox/CollisionShape2D.disabled = false


func _ready() -> void:
	$Vision.visible = true
	set_collision_direction()
	enemy_damage.hitpoints = hitpoints
	enemy_damage.damage = damage
	animation_player.play("idle")
	state = PATROL
	if idle_stand:
		state = DO_NOTHING

func _physics_process(delta: float) -> void:
	#print(state)
	
	label.text = str(state) + " " + str(tracked_character)
	if state == DEATH:
		return
	elif state == CHASE:
		chase_state()
	elif state == PATROL:
		patrol_state()
	elif state == HIT:
		velocity.x = move_toward(velocity.x, 0, hit_inertion * delta)
		#velocity.y = move_toward(velocity.y, 0, hit_inertion * delta)
	#if state == HIT:
		#modulate.g = 0.75
		#modulate.b = 0.75
		#$EnemyDamage/Hurtbox/CollisionShape2D.disabled = true
	#else:
		#modulate.g = 1
		#modulate.b = 1
		#$EnemyDamage/Hurtbox/CollisionShape2D.disabled = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	elif is_on_floor():
		if state != HIT and state != DEATH:
			if velocity.x == 0:
				animation_player.play("idle")
			elif velocity.x != 0:
				animation_player.play("walk")
	
	if (not edge_detection.is_colliding() or wall_detection.is_colliding()) and state != HIT:
		full_stop()
	elif is_walking and edge_detection.is_colliding() and not wall_detection.is_colliding():
		make_move(delta)
	
	counter += 1 * delta
	if counter > 1 * chase_modifier:
		counter = 0
		# check visions
		check_visions()
	
	move_and_slide()


func check_visions():
	# check visions
	get_tracked_character()
	if tracked_character != null and (state == PATROL or state == DO_NOTHING):
		awared()
	elif tracked_character == null and state == CHASE:
		distracted()



func make_move(delta):
	if direction:
		velocity.x = direction * speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, speed *  delta)


func set_collision_direction():
	if direction:
		face_direction = direction
	wall_detection.target_position.x = 80 * face_direction
	edge_detection.position.x = 55 * face_direction
	attack_collision.position.x = 100 * face_direction
	hitbox_collision.position.x = 100 * face_direction
	forward_vision_ray.target_position.x = 1024 * face_direction
	back_vision_ray.target_position.x = -512 * face_direction
	$PointLight2D.position.x = -1 * face_direction
	$PointLight2D2.position.x = -45 * face_direction
	animated_sprite_2d.flip_h = face_direction < 0


func change_direction():
	if animated_sprite_2d.flip_h == true:
		direction = 1
	elif animated_sprite_2d.flip_h == false:
		direction = -1
	set_collision_direction()



func chase_state():
	if tracked_character == null:
		distracted()
	elif tracked_character != null:
		is_walking = true
		if global_position.x > tracked_character.global_position.x + 10:
			direction = -1
		elif global_position.x < tracked_character.global_position.x - 10:
			direction = 1
		else:
			direction = 0

	set_collision_direction()


func patrol_state():
	
	if tracked_character != null:
		state = CHASE
	if (not edge_detection.is_colliding() or wall_detection.is_colliding()) and not is_awaiting:
		full_stop()
		is_awaiting = true
		timer.start(1)
	elif is_awaiting:
		if timer.time_left <= 0:
			is_awaiting = false
			var thresh = randf()
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
	


func awared():
	state = IDLE
	animation_player.play("idle")
	label.text = "see ya!"
	full_stop()
	timer.stop()
	timer.start(0.25)
	await timer.timeout
	label.text = ""
	state = CHASE

func distracted():
	state = DO_NOTHING
	#animation_player.play("idle")
	label.text = "wtf..."
	#full_stop()
	timer.stop()
	timer.start(2)
	await timer.timeout
	label.text = ""
	state = PATROL
	patrol_state()


#func _on_sight_area_2d_body_entered(body: Node2D) -> void:
	#if state == CHASE or state == PATROL:
		#if body.name == "Shady":
				#awared()
				#tracked_character = body
#
#func _on_sight_area_2d_body_exited(body: Node2D) -> void:
	#if state == CHASE or state == PATROL:
		#if body.name == "Shady":
			#distracted()
			#tracked_character = null


func full_stop():
	velocity.x = 0
	is_walking = false
	set_collision_direction()

func _on_enemy_damage_hitted() -> void:
	#GlobalParams.screenshake.emit(0.1, 5)
	if state != DEATH:
		state = HIT
	
func hitted_state():
	print("AAAA")
	full_stop()
	animation_player.play("hit")
	direction = -GlobalParams.shady_params.attack_direction.x
	velocity = (GlobalParams.shady_params.knockback_force * 
				-direction * Vector2(1, 0.25))
	set_collision_direction()
	await animation_player.animation_finished
	if enemy_damage.hitpoints > 0:
		awared()
		#state = PATROL
		##distracted()
		#if tracked_character != null:
			#state = CHASE
			##awared()


func died():
	#GlobalParams.screenshake.emit(0.1, 10)
	full_stop()
	print("NOOOOOOOO")
	#animation_player.play("die")
	var corpse_sprite = preload("res://game/enemies/trampcorpse/trampcorpse_dead.tscn").instantiate()
	get_parent().add_child(corpse_sprite)
	#await animation_player.animation_finished
	corpse_sprite.position = position
	corpse_sprite.animated_sprite_2d.flip_h = animated_sprite_2d.flip_h
	corpse_sprite.visible = true
	direction = GlobalParams.shady_params.attack_direction.x
	corpse_sprite.velocity = (GlobalParams.shady_params.knockback_force * 
				direction * Vector2(1, 0.25))
	corpse_sprite.die()
	queue_free()


func _on_enemy_damage_death() -> void:
	state = DEATH
	#pass


func _on_enemy_damage_target_detected() -> void:
	if state == CHASE or state == PATROL:
		print("attack")


func instant_death():
	state = DEATH


func get_tracked_character():
	if forward_vision_ray.get_collider(0) != null:
		tracked_character = forward_vision_ray.get_collider(0)
	elif back_vision_ray.get_collider(0) != null:
		tracked_character = back_vision_ray.get_collider(0)
	else:
		tracked_character = null
