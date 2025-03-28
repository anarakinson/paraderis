extends Node2D


enum {
	NONE,
	BOMB,
	THROWING_KNIFE,
	ELDRITCHBOMB,
	FIREBOMB,
	POTION_PROTECTION,
	SIGIL_MAGIC_BOLT,
	SIGIL_MAGIC_BOLT_SPRAY,
	SIGIL_PROTECTION,
	SIGIL_FIRESTORM,
	WAND,
}


var item_names : Dictionary = {
	NONE : "NONE",
	BOMB : "BOMB",
	THROWING_KNIFE : "THROWING_KNIFE",
	ELDRITCHBOMB : "ELDRITCHBOMB",
	FIREBOMB : "FIREBOMB",
	POTION_PROTECTION : "POTION_PROTECTION",
	SIGIL_MAGIC_BOLT : "SIGIL_MAGIC_BOLT",
	SIGIL_MAGIC_BOLT_SPRAY : "SIGIL_MAGIC_BOLT_SPRAY",
	SIGIL_PROTECTION : "SIGIL_PROTECTION",
	SIGIL_FIRESTORM : "SIGIL_FIRESTORM",
	WAND : "WAND",
}


var item_preloaded : Dictionary = {
	NONE : null,
	BOMB : preload("res://game/projectiles/bomb/bomb.tscn"),
	THROWING_KNIFE : preload("res://game/projectiles/throwing_knife/throwing_knife.tscn"),
	ELDRITCHBOMB : null,
	POTION_PROTECTION : preload("res://game/effects/magic/protection_seal/protection_seal.tscn"),
	SIGIL_MAGIC_BOLT : preload("res://game/projectiles/magic_bolt/magic_bolt.tscn"),
	SIGIL_MAGIC_BOLT_SPRAY : preload("res://game/effects/magic/magic_bolt_spray/magic_bolt_spray.tscn"),
	SIGIL_PROTECTION : null,
	SIGIL_FIRESTORM : null,
	WAND : null,
}

var projectiles : Array = [
	BOMB,
	THROWING_KNIFE,
	ELDRITCHBOMB,
	FIREBOMB,
	SIGIL_MAGIC_BOLT,
	SIGIL_MAGIC_BOLT_SPRAY,
	SIGIL_PROTECTION,
	SIGIL_FIRESTORM,
]

var potions : Array = [
	POTION_PROTECTION,
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func get_new_item(which_item : int, new_position : Vector2):
	if item_preloaded[which_item] == null:
		print("[ERROR] chosen item is NULL")
		return
	var new_projectile = item_preloaded[which_item].instantiate()
	get_parent().add_child(new_projectile)
	new_projectile.global_position = new_position
	return new_projectile
