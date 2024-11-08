extends Node2D

signal hitted 
signal death 
signal target_detected

@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D

@export_group("parameters")
@export var damage = 1
@export var hitpoints = 5
@onready var invincibility_time = GlobalParams.shady_params.attack_cooldown_time
var is_invincible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox_collision.disabled = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_hurtbox_area_entered(area: Area2D) -> void:
	var owner = area.get_parent().get_parent()
	if area.name == "Hitbox" and not is_invincible:
		hitpoints -= GlobalParams.shady_params.damage
		invincibility()
		if hitpoints <= 0:
			death.emit()
		else:
			hitted.emit()
		if owner.name == "Shady":
			owner.attack_recoil()
	if area.name == "Hurtbox":
		if owner.name == "Shady":
			if owner.global_position.x > global_position.x:
				GlobalParams.shady_params.hazard_direction = -1
			elif owner.global_position.x < global_position.x:
				GlobalParams.shady_params.hazard_direction = 1
			owner.hitpoints.decrease(1)


#func _on_hitbox_body_entered(body: Node2D) -> void:
	#if body.name == "Shady":
		#body.hitpoints.hitted.decrease(damage)
		#print("ATTACK")


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Shady":
		target_detected.emit()


func invincibility():
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout 
	is_invincible = false
	
