extends Node2D

signal ui_update
signal hitted
signal death
signal screenshake(duration : float)


@onready var world_environment: WorldEnvironment = $WorldEnvironment

var last_checkpoint : Node2D = null
var last_savekpoint : Node2D = null

var gravity_coeff = 1


class ShadyParams:
	var speed = 550.0
	var jump_velocity = -775.0

	var hitpoints : int = 5
	var damage : int = 1
	var max_hitpoints : int = 5
	var invincibility_time = 1.6

	var attack_cooldown_time = 0.2
	var knockback_force = 400
	var recoil_force = Vector2(-200, -400)
	
	var current_state : int = Shady.MOVE
	var transition_state : int = Shady.MOVE
	
	var attack_direction = Vector2(0, 0)
	var hazard_direction = 0
	
	#var current_item = ItemManager.NONE
	var current_item_id = 0
	var current_item = ItemManager.NONE
	var available_items : Array = [
		#ItemManager.NONE,
		ItemManager.BOMB, 
		ItemManager.THROWING_KNIFE, 
		ItemManager.POTION_PROTECTION,
		ItemManager.WAND,
		ItemManager.SIGIL_MAGIC_BOLT,
		ItemManager.SIGIL_MAGIC_BOLT_SPRAY,
	]

var shady_params : ShadyParams


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shady_params = ShadyParams.new()
	
	#ProjectSettings.set_setting("physics/2d/default_gravity", ProjectSettings.get_setting("physics/2d/default_gravity") * 1.75)
	#print(ProjectSettings.get_setting("physics/2d/default_gravity"))
	
	var resolution = Vector2(1920, 1080)
	DisplayServer.window_set_size(resolution)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	world_environment.environment.glow_enabled = true

	pass # Replace with function body.



#func _input(event)
	#if(event is InputEventKey):
		## Do stuff
	#elif(event is InputEventJoypadButton):
		## Do stuff
	#elif(event is InputMouseButton):
		## Do stuff
	#elif(event is InputEventScreenTouch):
		## Do stuff
	#else:
		## Do stuff
	#print(Input.get_joy_name(0))
	#print(Input.get_joy_name(1))
	#print(Input.get_joy_name(2))


var time_counter : float = 0
var hour_counter : float = 0
var minute_counter : float = 0
var second_counter : float = 0

func update_timer(delta):
	time_counter += delta
	#var msec = fmod(time_counter, 1) * 100
	second_counter = fmod(time_counter, 60)
	minute_counter = fmod(time_counter, 3600) / 60
	if minute_counter >= 60:
		hour_counter += 1
		time_counter = 0
	
func get_time_str() -> String:
	return ("%02d" % hour_counter) + (":%02d" % minute_counter) + (":%02d." % second_counter)# + ("%03d" % msec)
	
