extends ParallaxLayer
@export var speed: float = 3.0  
@export var direction: Vector2 = Vector2(1, 0)  # Moves horizontally

func _process(delta):
	
	motion_offset += direction * speed * delta
