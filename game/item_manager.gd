extends Node2D


enum {
	NONE,
	FIREBOMB,
	THROWING_KNIFE,
	ELDRITCHBOMB,
}


var item_names : Dictionary = {
	NONE : "NONE",
	FIREBOMB : "FIREBOMB",
	THROWING_KNIFE : "THROWING_KNIFE",
	ELDRITCHBOMB : "ELDRITCHBOMB",
}


var item_preloaded : Dictionary = {
	NONE : null,
	FIREBOMB : preload("res://game/projectiles/firebomb/fire_bomb.tscn"),
	THROWING_KNIFE : preload("res://game/projectiles/throwing_knife/throwing_knife.tscn"),
	ELDRITCHBOMB : null,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func throw(which_item : int, new_position : Vector2, direction : Vector2):
	if item_preloaded[which_item] == null:
		print("[ERROR] chosen item is NULL")
		return
	var new_projectile = item_preloaded[which_item].instantiate()
	get_parent().add_child(new_projectile)
	new_projectile.global_position = new_position
	new_projectile.throw(direction)
