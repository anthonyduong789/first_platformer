extends Node2D

@export var mob_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_2_area_entered(area: Area2D) -> void:
	if area:
		print('print')
	pass # Replace with function body.
