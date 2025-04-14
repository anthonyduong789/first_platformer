extends CharacterBody2D




signal start_dash_tween

@export var gravity = 8
@export var jump_force = 250
# all the variables that are not exported are private
@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var crouch_raycast1 = $CrouchRaycast_1
@onready var crouch_raycast2 = $CrouchRaycast_2
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var jump_height_timer = $JumpHeightTimer
@onready var attackTimer = $attack
@onready var attackTimer2 = $attack2
@onready var dashParticle =$DashParticles

@onready var rollTimer = $roll
@onready var CharacterCollision = $CollisionShape2D
@onready var Sword = $Sprite2D/HitBox
@onready var SwordRotate = $Sprite2D/HitBox/CollisionShape2D

@export var current_speed = 25
@export var SPEED = 25
@export var normalSpeed = 75

#region Dash variables
@export var dash_time: float = 0.2
@export var dash_cooldown: float = 1.0
@export var dashSpeed = 125
var is_dashing: bool = false
var can_dash: bool = true
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
const dash_duration = 0.5
@onready var dash = $Dash


#endregion


@onready var health = 10
@onready var audioPlayer = $AudioPlayer


var inAir = false
var is_crouching = false
var stuck_under_object = false
var can_coyote_jump = false
var jump_buffered = false
var is_attacking = false
var is_roll = false

var rollDirection = 1
var animation_locked = false

var standing_cshape = preload("res://resources/knight_standing_cshape.tres")
var crouching_cshape = preload("res://resources/knight_crouching_cshape.tres")

func _ready() -> void:
	Global.playerBody = self
	Global.attackTimer = attackTimer

func create_ghosting():
	var new_ghost: Sprite2D = sprite.duplicate()
	var parent: Node2D = Node2D.new()
	parent.global_position = self.global_position
	parent.position = self.position
	parent.scale = self.scale
	for child in new_ghost.get_children():
		child.queue_free()
	parent.add_child(new_ghost)
	
	#new_ghost.position = tx_pos
	#new_ghost.centered = true
	
	get_tree().current_scene.add_child(parent)
	var tween_fade = new_ghost.create_tween()
	tween_fade.tween_property(self, "self_modulate", Color(1, 1, 1, 0), 0.75)
	await tween_fade.finished
	parent.queue_free()
	
	
func _physics_process(delta):
	#+ sprite.global_position
	#print("position", position)d
	#print("sprite position", sprite.a)
	var parent_pos = self.global_position
	#create_ghosting()


# in case of dashing the character should not be able to will 
# not be able to move up and down

	if is_dashing:
		velocity.y = 0
	
	if !is_on_floor() && (can_coyote_jump == false) && !is_dashing:
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
	
	if is_on_floor():
		inAir = false
	
	handle_Input()



	# Handle will handles lateral movement
	
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	var corrected_horizontal_direction = (horizontal_direction * -1 if sprite.flip_h else horizontal_direction)

	var current_horizontal_direction = 0

	if horizontal_direction != 0 and rollTimer.is_stopped():
		switch_direction(horizontal_direction)


	if is_dashing:
		# current_speed = dashSpeed
		# velocity.x = dashSpeed * (-1 if sprite.flip_h else 1)
		current_speed = dashSpeed
		current_horizontal_direction = (-1 if sprite.flip_h else 1)




	if !is_dashing && !is_roll:
		current_horizontal_direction = horizontal_direction
		if is_crouching:
			current_speed = normalSpeed / 2
		else:
			current_speed = normalSpeed
		velocity.x = current_speed * horizontal_direction
	else:
		if is_roll:
			current_speed = dashSpeed
			current_horizontal_direction = rollDirection
			# current_speed = dashSpeed * (-1 if sprite.flip_h else 1)
			#
	velocity.x = current_speed * current_horizontal_direction
	
	if stuck_under_object && above_head_is_empty():
		if !Input.is_action_pressed("crouch"):
			stand()
			stuck_under_object = false
			print("Player was stuck but he is getting up")
	var was_on_floor = is_on_floor()


	coyote_timer.start()
	
	# Touched ground && and buff
	if !was_on_floor && is_on_floor():
		if jump_buffered:
			jump_buffered = false
			jump()
	
	if (attackTimer.is_stopped() and rollTimer.is_stopped() and !is_dashing and !is_roll and !is_attacking):
		animation_locked = false
	
	
	if (attackTimer.is_stopped() and rollTimer.is_stopped() and attackTimer2.is_stopped()):
		update_animations(horizontal_direction)
	move_and_slide()
	

func handle_Input():

	if animation_locked:
		return
	elif Input.is_action_just_pressed("jump"):
		jump_height_timer.start()
		jump()
	elif Input.is_action_just_pressed("attack") and attackTimer.is_stopped():
		attackTimer.start()
		attack()

	elif Input.is_action_just_pressed("attack2") and attackTimer2.is_stopped():
		attackTimer2.start()
		attack2()
		print("Attack 2")



	elif Input.is_action_just_pressed("crouch"):
		crouch()
		
	elif Input.is_action_just_released("crouch"):
		if above_head_is_empty():
				stand()
		else:
			if stuck_under_object != true:
				stuck_under_object = true
				print("Player stuck, setting stuck_under_object to true")
	# elif Input.is_action_just_pressed("dash") and dashTimer.is_stopped():
	# 	dashTimer.start()
	# 	dash()
	# if Input.is_action_just_pressed("roll") and rollTimer.is_stopped():
	# 	if sprite.flip_h == true:
	# 		rollDirection = -1
	# 	else:
	# 		rollDirection = 1
	# 	roll()

  
	if Input.is_action_just_pressed("dash") && !dash.is_dashing() && dash.can_dash:
		dash_animation()
		var dash_direction = 1 # Default to right
		if sprite.flip_h:
			dash_direction = -1 # Move left if flipped
		
			

		
		dash.start_dash(sprite, dash_duration, dash_direction)

func jump():
	if is_on_floor() || can_coyote_jump:
		velocity.y = - jump_force
		inAir = true
		if can_coyote_jump:
			can_coyote_jump = false
	else:
		if !jump_buffered:
			jump_buffered = true
			jump_buffer_timer.start()

func above_head_is_empty() -> bool:
	var result = !crouch_raycast1.is_colliding() && !crouch_raycast2.is_colliding()
	return result
func update_animations(horizontal_direction):

	# if !sprite.flip_h:
	# 	cshape.position.x = 2
	# 	print("Flipped")

	# else:
	# 	cshape.position.x = -3
	# 	print("Not Flipped")
	if animation_locked:
		return

	if is_on_floor():
		if horizontal_direction == 0:
			if is_crouching:
				ap.play("crouch")
			if !is_roll and !is_dashing and !is_crouching:
				ap.play("idle")

		else:
			if is_crouching:
				ap.play("crouch_walk")
			else:
				# if is_roll:
				# 	ap.play("roll")
				# if is_dashing:
				# 	print("is_dashing")
				# 	ap.play("dash")
				# 	print('is dashing')
				ap.play("run")
	else:
		if is_crouching == false and is_roll == false and is_dashing == false:
			if velocity.y < 0:
				ap.play("jump")
			elif velocity.y > 0:
				ap.play("fall")
		if is_crouching == true and is_roll == false and is_dashing == false:
			ap.play("crouch")
		if is_dashing == true and is_roll == false:
			ap.play("run")
			dashParticle.emitting = true
		else :
			dashParticle.emitting = true


		if is_roll == true and is_dashing == false:
			ap.play("is_roll")


func switch_direction(horizontal_direction):
	sprite.flip_h = (horizontal_direction == -1)
	sprite.position.x = horizontal_direction * 4
	
	if (horizontal_direction > 0):
		Sword.position.x = abs(Sword.position.x)
		#Sword.rotation = -abs(Sword.rotation)
		SwordRotate.rotation = - abs(SwordRotate.rotation)

	else:
		#Sword.rotation = 0
		Sword.position.x = - abs(Sword.position.x)
		SwordRotate.rotation = abs(SwordRotate.rotation)
func attack():
	animation_locked = true
	ap.play("attack")
	attackTimer.start()
	is_attacking = true
	print("Attack")

func attack2():
	animation_locked = true
	attackTimer2.start()
	ap.play("attack2")
	ap.play("attack2")

	is_attacking = true
	# audioPlayer.play()


func roll():
	animation_locked = true
	ap.play("roll")
	is_roll = true
	rollTimer.start()

func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_cshape
	cshape.position.y = 16
	
func stand():
	if is_crouching == false:
		return
	is_crouching = false
	cshape.shape = standing_cshape
	cshape.position.y = 12


func dash_animation():
	animation_locked = true
	# ap.play("dash")
	ap.play("run")
	is_dashing = true
	# start_dash_tween.emit()



#region Timer End Effects
func _on_coyote_timer_timeout():
	can_coyote_jump = false
func _on_jump_buffer_timer_timeout():
	jump_buffered = false
func _on_jump_height_timer_timeout():
	if !Input.is_action_pressed("jump"):
		if velocity.y < -200:
			velocity.y = -200
			print("Low jump")
	else:
		print("High jump")
func _on_roll_timeout() -> void:
	animation_locked = false
	is_roll = false
	print("Roll ended")
	pass # Replace with function body.

func _on_dash_dash_ended() -> void:
	animation_locked = false
	is_dashing = false
	print("Dash ended")
	pass # Replace with function body.

#endregion


func _on_attack_2_timeout() -> void:
	animation_locked = false
	ap.stop()
	pass # Replace with function body.


func _on_attack_timeout() -> void:
	animation_locked = false
	# ap.stop()
	pass # Replace with function body.
