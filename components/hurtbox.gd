class_name HurtBox
extends Area2D


signal received_damage(damage: int)
signal knockback(strength: int, enemy_pos: Vector2)


@export var health: Health


func _ready():
	connect("area_entered", _on_area_entered)


func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox != null and health:
		health.health -= hitbox.damage	
		received_damage.emit(hitbox.damage)
		knockback.emit(hitbox.knockBack, hitbox.get_attack_position(), hitbox.knockBack_upforce)
		print("health: ", health.health)
	
	else:
		print(health.health)
		#print(hitbox.damage)
