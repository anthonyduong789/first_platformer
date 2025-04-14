extends Node

signal dash_ended
const dash_delay = 0.4

@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var duration_timer: Timer = $DurationTimer
@onready var ghost_timer: Timer = $GhostTimer
@onready var ParentPos: CharacterBody2D = $".."
@onready var dust_burst = $DustBurst


var delay_start_timer: Timer = Timer.new()
var tweenOn: bool = false
var tweenTrigger: bool = false


var can_dash = true



func _process(delta: float) -> void:
	if delay_start_timer.time_left == 0.10:
		instance_ghost()


		


# func create_ghosting():
# 	var new_ghost: Sprite2D = sprite.duplicate()
# 	var parent: Node2D = Node2D.new()
# 	parent.global_position = self.global_position
# 	parent.position = self.position
# 	parent.scale = self.scale
# 	for child in new_ghost.get_children():
# 		child.queue_free()
# 	parent.add_child(new_ghost)
	
# 	#new_ghost.position = tx_pos
# 	#new_ghost.centered = true
	
# 	get_tree().current_scene.add_child(parent)
# 	var tween_fade = new_ghost.create_tween()
# 	tween_fade.tween_property(self, "self_modulate",Color(1, 1, 1, 0), 0.75 )
# 	await tween_fade.finished
# 	parent.queue_free()
func _ready() -> void:
	dust_burst.emitting = false


func start_dash(sprite, duration, direction):
	duration_timer.wait_time = duration
	duration_timer.start()
	
	self.sprite = sprite
	sprite.material.set_shader_parameter("mix_weight", 0.7)
	sprite.material.set_shader_parameter("whiten", true)
	ghost_timer.start()
	

	#dust_burst.rotation = (direction * -1).angle()
	#dust_burst.restart()
	dust_burst.emitting = false


func instance_ghost():
	var new_ghost: Sprite2D = sprite.duplicate()
	var parent: Node2D = Node2D.new()
	parent.global_position = ParentPos.global_position
	parent.position = ParentPos.position
	parent.scale = ParentPos.scale
	for child in new_ghost.get_children():
		child.queue_free()
	parent.add_child(new_ghost)
	get_tree().current_scene.add_child(parent)
	var tween_fade = new_ghost.create_tween()
	tween_fade.tween_property(self, "self_modulate", Color(1, 1, 1, 0), 0.25)
	await tween_fade.finished
	parent.queue_free()
func is_dashing():
	return !duration_timer.is_stopped()
	
func end_dash():
	emit_signal("dash_ended")
	#sprite.material.set_shader_parameter("whiten", false)
	ghost_timer.stop()
	sprite.material.set_shader_parameter("whiten", false)
	can_dash = false
	await get_tree().create_timer(dash_delay).timeout
	can_dash = true
	tweenOn = false
	
func _on_duration_timer_timeout() -> void:
	end_dash()
	pass # Replace with function body.


func _on_ghost_timer_timeout() -> void:
	instance_ghost()
	pass # Replace with function body.

func _on_player_start_dash_tween() -> void:
	delay_start_timer.start()
	delay_start_timer.wait_time = 1	
	tweenOn = true

	
	pass # Replace with function body.
