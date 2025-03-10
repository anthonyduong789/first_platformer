class_name HitBox
extends Area2D

var knockback_vector : Vector2 = Vector2.ONE
@export var damage: int = 1 : set = set_damage, get = get_damage

@onready var global_pos = $"."
@onready var player = $".."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var areas2d = $"CollisionShape2D"
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var vec
	
	if player.flip_h:
		vec = Vector2(-1,0)
	else:
		vec = Vector2(1,0)
	knockback_vector = vec
	
	#knockback_vector = global_pos.global_pos
	pass

func set_damage(value: int):
	damage = value


func get_damage() -> int:
	return damage
