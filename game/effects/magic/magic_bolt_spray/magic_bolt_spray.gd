extends Node2D

@export var bolt_amount = 5

const magic_bolt_preload = preload("res://game/projectiles/magic_bolt/magic_bolt.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func throw(dir : Vector2, initial_speed : int = 3000):
	for i in bolt_amount:
		#await get_tree().create_timer(randf_range(0.01,0.04)).timeout
		var bolt = ItemManager.get_new_item(ItemManager.SIGIL_MAGIC_BOLT, global_position)
		bolt.flight_variance = 0.25
		if i % 2 != 0:
			i = -i
		i = float(i)
		var dir_corrected = dir + Vector2(dir.y * (i/bolt_amount), 
										-dir.x * (i/bolt_amount))
		bolt.throw(dir_corrected, initial_speed)
	queue_free()
