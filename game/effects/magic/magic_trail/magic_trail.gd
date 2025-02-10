extends Node2D


@onready var trail: Line2D = $Trail
@onready var spark_particles: CPUParticles2D = $SparkParticles

@export var color : Color = Color(0.7, 0.8, 1, 1)
@export var max_lenght = 5
@export var follow_node : Node2D = null

var queue : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trail.default_color = color * 1.5
	spark_particles.color = color * 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#var pos = get_global_mouse_position()
	#follow(pos)


func follow(pos : Vector2):
	#pos = follow_node.global_position
	spark_particles.global_position = pos
	queue.push_front(pos)
	if queue.size() > max_lenght:
		queue.pop_back()
		
	trail.clear_points()
	for point in queue:
		trail.add_point(point)
