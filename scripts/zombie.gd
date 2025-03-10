extends AnimatedSprite2D


@export var gravity = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.play("Idle")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# velocity.y += gravity
	# if velocity.y > 1000:
	# 	velocity.y = 1000

	
	pass
