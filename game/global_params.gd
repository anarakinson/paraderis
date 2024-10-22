extends Node2D

signal ui_update

var last_checkpoint : Node2D = null
var last_savekpoint : Node2D = null

var gravity_coeff = 1.75


class ShadyParams:
	var hitpoints : int = 5
	var damage : int = 1
	var max_hitpoints : int = 5
	
	var current_state : int = Shady.MOVE
	var transition_state : int = Shady.MOVE
	
	var knockback_force = 400
	var attack_direction = Vector2(0, 0)
	var recoil_force = Vector2(-250, -500)
	var hazard_direction = 0

var shady_params : ShadyParams

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shady_params = ShadyParams.new()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
