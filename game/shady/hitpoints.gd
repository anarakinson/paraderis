extends Node2D

signal time_to_die
signal hitted
signal invincibility_start
signal invincibility_stop

#@onready var player = get_parent()

@export var hitpoints = 5
@export var invincibility_time = 0.4

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
	if hitpoints <= 0:
		hitpoints = 0
		time_to_die.emit()
		return
	invincibility()
	hitted.emit()
	
func increase(value : int = 1):
	hitpoints += value
	
	
func invincibility():
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false
