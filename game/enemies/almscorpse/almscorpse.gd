extends CharacterBody2D


@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Area2D = $Hurtbox
@onready var vision: Node2D = $Vision
@onready var label: Label = $Label

var skull_sprite_preload = preload("res://game/enemies/almscorpse/almscorpse_skull.tscn")
var bone_sprite_preload = preload("res://game/enemies/almscorpse/almscorpse_bones.tscn")

#@export_enum("orange", "blue", "yellow") var corpse_type = "yellow"
@export var begger = false
@export_range(-1, 1, 2) var direction = 1

var hit_direction = 0
var knockback_force = 0

var tracked_character = null
var counter : float = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * GlobalParams.gravity_coeff


enum {
	IDLE,
	DO_NOTHING,
	OBSERVE,
	SLEEP,
	BEGGING,
	DEATH,
} 


var statename = {
	IDLE : "IDLE",
	DO_NOTHING : "DO_NOTHING",
	OBSERVE : "OBSERVE",
	SLEEP : "SLEEP",
	BEGGING : "BEGGING",
	DEATH : "DEATH",
} 

var state : int:
	set(value):
		state = value
		set_direction()


func set_direction():
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true



func _ready() -> void:
	#label.visible = true
	vision.chase_time = 1
	set_direction()
	hurtbox.set_shape(collision_shape.shape.radius, collision_shape.shape.height)
	pass



func _physics_process(delta: float) -> void:
	#label.text = statename[state]
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if state != DEATH:
		counter += 1 * delta
		if counter > 1:
			counter = 0
			# check visions
			check_visions()
	
	if state == OBSERVE:
		observe_state()
	elif state == SLEEP:
		sleep_state()
	
	move_and_slide()




func died():
	state = DEATH
	animated_sprite.play("die")
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, false)
	
	await get_tree().create_timer(0.02).timeout
	var skull_sprite = skull_sprite_preload.instantiate()
	get_parent().add_child(skull_sprite)
	var bone_sprite = bone_sprite_preload.instantiate()
	get_parent().add_child(bone_sprite)
	var bone_sprite2 = bone_sprite_preload.instantiate()
	get_parent().add_child(bone_sprite2)
	
	bone_sprite.animated_sprite.play("bone1")
	bone_sprite2.animated_sprite.play("bone2")
	if "Yellow" in self.name:
		skull_sprite.animated_sprite.play("yellow")
	elif "Blue" in self.name:
		skull_sprite.animated_sprite.play("blue")
		bone_sprite.animated_sprite.play("cap")
	elif "Orange" in self.name:
		skull_sprite.animated_sprite.play("orange")
	
	skull_sprite.global_position = global_position
	skull_sprite.animated_sprite.flip_h = animated_sprite.flip_h
	skull_sprite.visible = true
	skull_sprite.throw(knockback_force * 
				-hit_direction * Vector2(1, 0.25))

	bone_sprite.global_position = global_position
	bone_sprite.animated_sprite.flip_h = animated_sprite.flip_h
	bone_sprite.visible = true
	bone_sprite.throw(knockback_force * 
				-hit_direction * Vector2(1, 0.25))

	bone_sprite2.global_position = global_position
	bone_sprite2.animated_sprite.flip_h = animated_sprite.flip_h
	bone_sprite2.visible = true
	bone_sprite2.throw(knockback_force * 
				-hit_direction * Vector2(1.1, 0.3))


	vision.is_active = false
	tracked_character = null



func observe_state():
	if tracked_character != null:
		if tracked_character.global_position.x > global_position.x + 50:
			if direction > 0:
				animated_sprite.play("look_right")
			elif direction < 0:
				animated_sprite.play("look_left")
		elif tracked_character.global_position.x < global_position.x - 50:
			if direction > 0:
				animated_sprite.play("look_left")
			elif direction < 0:
				animated_sprite.play("look_right")
		else:
			animated_sprite.play("idle")


func sleep_state():
	animated_sprite.play("sleep")


func check_visions():
	# check visions
	tracked_character = vision.get_tracked_character()
	
	if tracked_character != null:
		if tracked_character.state == Shady.REST:
			if state == OBSERVE:
				await get_tree().create_timer(0.5).timeout
			tracked_character = null
			go_to_sleep()
		else:
			awared()
	elif tracked_character == null:
		go_to_sleep()


func awared():
	if state != OBSERVE:
		state = DO_NOTHING
		animated_sprite.play("idle")
		await get_tree().create_timer(0.2).timeout
		state = OBSERVE

func go_to_sleep():
	if state != SLEEP:
		state = DO_NOTHING
		animated_sprite.play("idle")
		await get_tree().create_timer(0.2).timeout
		state = SLEEP



func _on_hurtbox_area_entered(area: Area2D) -> void:
	var area_owner = area.get_parent()
	if area.name == "Hitbox":
		hurtbox.disable()
		knockback_force = area.knockback_force
		if area_owner.name == "Shady":
			hit_direction = -GlobalParams.shady_params.attack_direction.x
			area_owner.attack_recoil()
		else:
			if global_position < area.global_position:
				hit_direction = 1
			else:
				hit_direction = -1
		GlobalParams.screenshake.emit(0.15, 10)
		#state = DO_NOTHING
		died()
			
