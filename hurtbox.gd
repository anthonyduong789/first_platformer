extends Area2D
@onready var topNode = $".."
@onready var hitAnimation = $"../HitAnimationPlayer"
@export var health = 3



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
#func damage()-> void:
	#health -= 1
	#print(health)
	#topNode.play("attack")
	#
	#hitAnimation.play("Hit")
	#print("play Animation")
	#if health == 0:	 
		##self.queue_free()
		#topNode.queue_free()
		##ap.queue_free()
