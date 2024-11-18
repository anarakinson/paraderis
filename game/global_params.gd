extends Node2D

signal ui_update
signal hitted
signal death
signal screenshake(duration : float)

var last_checkpoint : Node2D = null
var last_savekpoint : Node2D = null

var gravity_coeff = 1.75


class ShadyParams:
	var speed = 500.0
	var jump_velocity = -775.0

	var hitpoints : int = 5
	var damage : int = 1
	var max_hitpoints : int = 5
	var invincibility_time = 1.6

	var attack_cooldown_time = 0.25
	var knockback_force = 400
	var recoil_force = Vector2(-150, -350)
	
	var current_state : int = Shady.MOVE
	var transition_state : int = Shady.MOVE
	
	var attack_direction = Vector2(0, 0)
	var hazard_direction = 0
	

var shady_params : ShadyParams

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shady_params = ShadyParams.new()
	
	var resolution = Vector2(1920, 1080)
	DisplayServer.window_set_size(resolution)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	


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
