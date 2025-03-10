extends TextureRect


# Called when the node enters the scene tree for the first time.

var fixed_y_position: float = 0

func _ready() -> void:
	fixed_y_position = global_position.y
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y = fixed_y_position
	pass
