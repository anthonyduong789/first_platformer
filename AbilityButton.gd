extends TextureButton
class_name AbilityButton

@onready var time_label = $Counter/Value

@export var cooldown =  0.5


func _ready():
	time_label.hide()
	$Sweep.value = 0
	$Sweep.texture_progress = texture_normal
	$Timer.wait_time = cooldown

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		_on_AbilityButton_pressed()
	time_label.text = "%3.1f" % $Timer.time_left
	$Sweep.value = int(($Timer.time_left / cooldown) * 100)

func _on_Timer_timeout():
	$Sweep.value = 0
	time_label.hide()



func _on_AbilityButton_pressed():
	$Timer.start()
	time_label.show()
