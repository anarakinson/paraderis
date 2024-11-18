extends Node2D

signal hitted


@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D


#################
## r, pos_x, pos_y
var attack_shapes : Dictionary = {
	"basic" : [150, 70, -35],
	"sit" : [85, 115, 50],
	"up" : [150, -5, -75],
	"down" : [150, 20, 15],
	"wall" : [150, -75, -75],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func attack_start(shape: String, direction : int):
	hitbox_collision.shape.radius = attack_shapes[shape][0]
	hitbox_collision.position.x = attack_shapes[shape][1] * direction
	hitbox_collision.position.y = attack_shapes[shape][2]
	hitbox_collision.disabled = false

func attack_end():
	hitbox_collision.disabled = true

func hurtbox_activate():
	#hurtbox.monitorable = true
	hurtbox_collision.disabled = false

func hurtbox_deactivate():
	#hurtbox.monitorable = false
	#hurtbox_collision.disabled = true
	hurtbox_collision.set_deferred("disabled", true)

func set_hurtbox_shape(params):
	hurtbox_collision.shape.radius = params[0]
	hurtbox_collision.shape.height = params[1]
	hurtbox_collision.rotation_degrees = params[2]
	hurtbox_collision.position.y = params[3]

func _on_hurtbox_area_entered(area: Area2D) -> void:
	hitted.emit()
	
	
