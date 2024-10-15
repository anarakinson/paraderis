extends Node2D

signal hitted 
signal death 
signal target_detected

@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D

@export_group("parameters")
@export var damage = 1
@export var hitpoints = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox_collision.disabled = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "Hitbox":
		hitpoints -= GlobalParams.shady_params.damage
		if hitpoints <= 0:
			death.emit()
		else:
			hitted.emit()


#func _on_hitbox_body_entered(body: Node2D) -> void:
	#if body.name == "Shady":
		#body.hitpoints.hitted.decrease(damage)
		#print("ATTACK")


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Shady":
		target_detected.emit()
