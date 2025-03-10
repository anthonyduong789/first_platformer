extends Node2D

@onready var rayCasters = $"../RayCast2D"
@onready var enemyScene = load("res://enemyZombie.tscn")

var made: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rayCasters.is_colliding() and !made:
		var instance = enemyScene.instantiate()
		add_child(instance)
		made = true



#func spawn_enemy():
	#self_modulate().change_scene_to_file("res://enemyZombie.tscn")
	#enemy.position = Vector2(random_range(0, viewport_size.x), -100
