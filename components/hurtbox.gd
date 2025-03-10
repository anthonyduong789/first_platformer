class_name HurtBox
extends Area2D

signal received_damage(damage: int)

@export var health: Health

func _on_area_entered(hitbox: HitBox) -> void:
	print('got it')
	#if hitbox != null:
		#health.health -= hitbox.damage
		#received_damage.emit(hitbox.damage)
