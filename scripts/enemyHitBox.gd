extends Area2D

@onready var ap = $".."

var health: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage()-> void:
	health -= 1
	if health == 0:
		ap.queue_free()
		


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("test...")
	pass # Replace with function body.
