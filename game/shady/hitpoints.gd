extends Node2D

signal time_to_die
signal hitted
signal invincibility_start
signal invincibility_stop
signal hitpoints_update

#@onready var player = get_parent()

@onready var hitpoints = GlobalParams.shady_params.hitpoints
@export var invincibility_time = 0.5

var is_invincible : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func decrease(value : int = 1):
	if is_invincible:
		return
	hitpoints -= value
	hitpoints_update.emit()
	if hitpoints <= 0:
		hitpoints = 0
		time_to_die.emit()
		return
	invincibility()
	hitted.emit()

func instant_decrease(value : int = 1):
	hitpoints -= value
	hitpoints_update.emit()
	if hitpoints <= 0:
		hitpoints = 0
		time_to_die.emit()
		return
	invincibility()

func increase(value : int = 1):
	hitpoints += value
	
	
func invincibility():
	is_invincible = true
	invincibility_start.emit()
	print("INVINCIBLE")
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false
	invincibility_stop.emit()


func _on_hitpoints_update() -> void:
	GlobalParams.shady_params.hitpoints = hitpoints
	GlobalParams.ui_update.emit()
