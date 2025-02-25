extends CharacterBody2D


signal hitted 
signal death 
signal target_detected


var corpse_sprite_preload = preload("res://game/enemies/trampcorpse/trampcorpse_dead.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var label: Label = $Label
@onready var edge_detection: RayCast2D = $EdgeDetection
@onready var wall_detection: ShapeCast2D = $WallDetection

@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
#@onready var attack_collision: CollisionShape2D = $EnemyDamage/AttackArea/CollisionShape2D

@onready var vision: Node2D = $Vision


@onready var invincibility_time = (
	GlobalParams.shady_params.attack_cooldown_time * 0.99)
var is_invincible = false
var hit_direction = 0
var knockback_force = 0

@export_group("Parameters")
@export var damage = 1
@export var hitpoints = 3
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
				vision.back = -300
				pass

		if state != PATROL:
			is_awaiting = false
		if state != DO_NOTHING:
			vision.back = -1000
		
		if state == HIT:
			modulate.g = 0.75
			modulate.b = 0.75
			hurtbox.disable()
		elif state != HIT:
			modulate.g = 1
			modulate.b = 1
			hurtbox.enable()


func _ready() -> void:
	set_collision_direction()
	hitbox.damage = damage
	animation_player.play("idle")
	state = PATROL
	hurtbox.set_shape(collision_shape_2d.shape.radius, collision_shape_2d.shape.height)
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
	tracked_character = $Vision.get_tracked_character()
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
	#attack_collision.position.x = 100 * face_direction
	hitbox.collision.position.x = 100 * face_direction
	$PointLight2D.position.x = -1 * face_direction
	$PointLight2D2.position.x = -45 * face_direction
	animated_sprite_2d.flip_h = face_direction < 0	
	$Vision.scale.x = face_direction


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



func full_stop():
	velocity.x = 0
	is_walking = false
	set_collision_direction()

	
func hitted_state():
	full_stop()
	animation_player.play("hit")
	direction = hit_direction
	velocity = (knockback_force * 
				-direction * Vector2(1, 0.25))
	#print(hit_direction, velocity)
	set_collision_direction()
	await animation_player.animation_finished
	if hitpoints > 0:
		awared()



func died():
	full_stop()
	await get_tree().create_timer(0.001).timeout
	var corpse_sprite = corpse_sprite_preload.instantiate()
	get_parent().add_child(corpse_sprite)
	#await animation_player.animation_finished
	corpse_sprite.position = position
	corpse_sprite.animated_sprite_2d.flip_h = animated_sprite_2d.flip_h
	corpse_sprite.visible = true
	corpse_sprite.direction = hit_direction
	corpse_sprite.velocity = (knockback_force * 
				-corpse_sprite.direction * Vector2(1, 0.25))
	corpse_sprite.die()
	call_deferred("queue_free")




func instant_death():
	state = DEATH




func _on_hurtbox_area_entered(area: Area2D) -> void:
	var area_owner = area.get_parent()
	if area.name == "Hitbox" and not is_invincible:
		hitpoints -= area.damage
		knockback_force = area.knockback_force
		hurtbox.invincibility()
		if area_owner.name == "Shady":
			hit_direction = -GlobalParams.shady_params.attack_direction.x
			area_owner.attack_recoil()
		else:
			if global_position < area.global_position:
				hit_direction = 1
			else:
				hit_direction = -1
		if hitpoints <= 0:
			GlobalParams.screenshake.emit(0.15, 10)
			death.emit()
		else:
			GlobalParams.screenshake.emit(0.1, 5)
			hitted.emit()
			
	if area.name == "Hurtbox":
		if area_owner.name == "Shady":
			if area_owner.global_position.x > global_position.x:
				GlobalParams.shady_params.hazard_direction = -1
			elif area_owner.global_position.x < global_position.x:
				GlobalParams.shady_params.hazard_direction = 1
			if not area_owner.hitpoints.is_invincible:
				area_owner.hitpoints.decrease(1)


func _on_death() -> void:
	state = DEATH

func _on_hitted() -> void:
	if state != DEATH:
		state = HIT

func _on_target_detected() -> void:
	if state == CHASE or state == PATROL:
		("attack")
