extends Path2D

@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var loop = false
@export var speed_scale = .5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if curve == null:
		return
		
	if loop:
		animation_player.play("move_loop")
		curve.add_point(Vector2(0, 0))
		#animation_player.get_animation("move").loop_mode = Animation.LOOP_LINEAR
	else:
		animation_player.play("move")
		#animation_player.get_animation("move").loop_mode = Animation.LOOP_PINGPONG
	animation_player.speed_scale = speed_scale
