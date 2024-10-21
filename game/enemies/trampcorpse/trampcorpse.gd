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


@export_group("Parameters")
@export var damage = 1
@export var hitpoints = 5

@export_category("Personal metrics")
@export var speed = 2000.0
@export var jump_velocity = -775.0
@export var hit_inertion = 1500
@export var idle_stand : bool = false 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * GlobalParams.gravity_coeff

var direction = 1
var is_walking = false
var tracked_character : CharacterBody2D = null
var tracked_character_position : Vector2 = Vector2(0, 0)

var is_awaiting = false
#var is_knocked_back = false 


enum {
	IDLE,
	STAND,
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
				pass
			STAND:
				pass


func _ready() -> void:
	enemy_damage.hitpoints = hitpoints
	enemy_damage.damage = damage
	animation_player.play("idle")
	state = PATROL
	if idle_stand:
		state = STAND

func _physics_process(delta: float) -> void:
	#print(state)
	
	if state == DEATH:
		return
	elif state == CHASE:
		chase_state()
	elif state == PATROL:
		patrol_state()
	elif state == HIT:
		velocity.x = move_toward(velocity.x, 0, hit_inertion * delta)
		#velocity.y = move_toward(velocity.y, 0, hit_inertion * delta)
	if state == HIT:
		modulate.g = 0
		modulate.b = 0
		$EnemyDamage/Hurtbox/CollisionShape2D.disabled = true
	else:
		modulate.g = 1
		modulate.b = 1
		$EnemyDamage/Hurtbox/CollisionShape2D.disabled = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if (not edge_detection.is_colliding() or wall_detection.is_colliding()) and state != HIT:
		full_stop()
	elif is_walking and edge_detection.is_colliding() and not wall_detection.is_colliding():
		make_move(delta)
	
	
	#if tracked_character != null:
		#tracked_character_position = tracked_character.global_position
	
	move_and_slide()



func make_move(delta):
	if direction:
		velocity.x = direction * speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, speed *  delta)


func set_collision_direction():
		wall_detection.target_position.x = 80 * direction
		edge_detection.position.x = 50 * direction
		attack_collision.position.x = 100 * direction
		hitbox_collision.position.x = 100 * direction


func change_direction():
	#print("change direction")
	if animated_sprite_2d.flip_h == true:
		animated_sprite_2d.flip_h = false
		direction = 1
	elif animated_sprite_2d.flip_h == false:
		animated_sprite_2d.flip_h = true
		direction = -1
	set_collision_direction()


func chase_state():
	if tracked_character != null:
		is_walking = true
		if global_position.x > tracked_character.global_position.x + 10:
			animated_sprite_2d.flip_h = true
			direction = -1
		elif global_position.x < tracked_character.global_position.x - 10:
			animated_sprite_2d.flip_h = false
			direction = 1
		else:
			direction = 0

	if velocity.x == 0:
		animation_player.play("idle")
	elif velocity.x != 0:
		animation_player.play("walk")

	set_collision_direction()

func patrol_state():
	if (not edge_detection.is_colliding() or wall_detection.is_colliding()) and not is_awaiting:
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

	if is_walking:
		animation_player.play("walk")
	elif not is_walking:
		animation_player.play("idle")
	#if velocity.x == 0:
		#animation_player.play("idle")
	#elif velocity.x != 0:
		#animation_player.play("walk")


func awared():
	state = IDLE
	animation_player.play("idle")
	label.text = "see ya!"
	full_stop()
	timer.stop()
	timer.start(0.5)
	await timer.timeout
	label.text = ""
	state = CHASE

func distracted():
	state = IDLE
	animation_player.play("idle")
	label.text = "wtf..."
	full_stop()
	timer.stop()
	timer.start(0.5)
	await timer.timeout
	label.text = ""
	state = PATROL


func _on_sight_area_2d_body_entered(body: Node2D) -> void:
	if state == DEATH:
		return
	if body.name == "Shady":
		awared()
		tracked_character = body

func _on_sight_area_2d_body_exited(body: Node2D) -> void:
	if state == DEATH:
		return
	if body.name == "Shady":
		distracted()
		tracked_character = null


func full_stop():
	velocity.x = 0
	is_walking = false


func _on_enemy_damage_hitted() -> void:
	if state == DEATH:
		return
	print("AAAA")
	state = HIT
	full_stop()
	animation_player.play("hit")
	direction = GlobalParams.shady_params.attack_direction.x
	velocity = (GlobalParams.shady_params.knockback_force * 
				direction * Vector2(1, 0.25))
	await animation_player.animation_finished
	if enemy_damage.hitpoints > 0:
		full_stop()
		state = PATROL
		if tracked_character != null:
			state = CHASE


func died():
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
	print("attack")


func instant_death():
	state = DEATH
