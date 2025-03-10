extends ColorRect

@onready var Self = $"."
@onready var checkRay = $"../RayCast2D"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if checkRay.is_colliding():
		self.color = Color(1,1,0,1)
	else: 
		self.color = Color(1,0,0,1)
	pass
