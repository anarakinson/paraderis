extends Node2D

signal time_to_die
signal hitted
signal invincibility_start
signal invincibility_stop
signal hitpoints_update

#@onready var player = get_parent()

@onready var hitpoints = GlobalParams.shady_params.hitpoints
@onready var invincibility_time = GlobalParams.shady_params.invincibility_time

var is_invincible : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func decrease(value : int = 1):
	#if is_invincible:
		#return
	hitpoints -= value
	if hitpoints <= 0:
		hitpoints = 0
		time_to_die.emit()
		return
	GlobalParams.hitted.emit()
	hitpoints_update.emit()
	invincibility()
	hitted.emit()

func instant_decrease(value : int = 1):
	hitpoints -= value
	if hitpoints <= 0:
		hitpoints = 0
		time_to_die.emit()
		return
	GlobalParams.hitted.emit()
	hitpoints_update.emit()
	invincibility()

func increase(value : int = 1):
	hitpoints += value
	
	
func invincibility():
	is_invincible += 1
	#print(is_invincible)
	invincibility_start.emit()
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible -= 1
	if is_invincible <= 0:
		is_invincible = 0
		invincibility_stop.emit()


func _on_hitpoints_update() -> void:
	GlobalParams.shady_params.hitpoints = hitpoints
	GlobalParams.ui_update.emit()


func _on_time_to_die() -> void:
	GlobalParams.shady_params.hitpoints = hitpoints
	GlobalParams.ui_update.emit()
	GlobalParams.death.emit()
