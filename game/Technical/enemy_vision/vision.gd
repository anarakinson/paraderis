extends Node2D

@onready var vision_ray_1: RayCast2D = $RayCasts/VisionRay1
@onready var vision_ray_2: RayCast2D = $RayCasts/VisionRay2
@onready var vision_ray_3: RayCast2D = $RayCasts/VisionRay3
@onready var vision_ray_4: RayCast2D = $RayCasts/VisionRay4

@export var is_active = true
@export_category("Vision parameters")
@export var chase_time = 5
@export var frequency = 3

@export var top = -200
@export var bottom = 200
@export var back = -1000
@export var front = 1500

var time_to_check = false
var counter = 0
var lost_counter = 0
var tracked_character = null

var forward_counting = true 
var downward_counting = true 
var x_counter = -1
var y_counter = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_active:
		tracked_character = null
		return
	counter += 1
	lost_counter += delta
	if counter >= frequency:
		counter = 0
		check_visions(delta)
	if lost_counter >= chase_time:
		lost_counter = 0
		tracked_character = null
	#$Label.text = "%.2f" % (vision_ray.target_position.distance_to(Vector2(left, 0)))


func check_visions(delta):
	for raycast in $RayCasts.get_children():
		if raycast.is_colliding():
			if raycast.get_collider().name == "Shady":
				tracked_character = raycast.get_collider()
				lost_counter = 0
				return
			
	delta = delta * frequency * 3.
	
	if forward_counting and downward_counting:
		x_counter += delta
		if x_counter >= 1:
			forward_counting = false
	elif not forward_counting and downward_counting:
		y_counter += delta 
		if y_counter >= 1:
			downward_counting = false
	elif not forward_counting and not downward_counting:
		x_counter -= delta 
		if x_counter <= -1:
			forward_counting = true
	elif forward_counting and not downward_counting:
		y_counter -= delta 
		if y_counter <= -1:
			downward_counting = true
	
	var x1 = (back * (1 - x_counter)/2 + front * (1 + x_counter)/2)
	var y1 = (top * (1 - y_counter)/2 + bottom * (1 + y_counter )/2)
	var x2 = (back * (1 + x_counter)/2 + front * (1 - x_counter)/2)
	var y2 = (top * (1 + y_counter)/2 + bottom * (1 - y_counter )/2)
	
	vision_ray_1.target_position = Vector2(x1, y1) #* (1 + abs(x_counter * y_counter))
	vision_ray_2.target_position = Vector2(x2, y2) #* (1 + abs(x_counter * y_counter))
	vision_ray_3.target_position = Vector2(x1, y2) #* (1 + abs(x_counter * y_counter))
	vision_ray_4.target_position = Vector2(x2, y1) #* (1 + abs(x_counter * y_counter))
	


func get_tracked_character():
	if is_instance_valid(tracked_character):
		return tracked_character
	return null
