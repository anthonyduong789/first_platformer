extends CharacterBody2D

@export var speed = 6000
@export var gravity = 5
@export var jump_force = 200


@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var crouch_raycast1 = $CrouchRaycast_1
@onready var crouch_raycast2 = $CrouchRaycast_2
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var jump_height_timer = $JumpHeightTimer
@onready var attackTimer = $attack
@onready var rollTimer = $roll
@onready var CharacterCollision = $CollisionShape2D
@onready var Sword = $Sprite2D/HitBox
@onready var SwordRotate = $Sprite2D/HitBox/CollisionShape2D
@export var SPEED = 25
@export var normalSpeed = 50
@onready var dashTimer = $dash

#region Dash variables
@export var dash_time: float = 0.2
@export var dash_cooldown: float = 1.0
@export var dashSpeed = 525
var is_dashing: bool = false
var can_dash: bool = true
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0

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
	tween_fade.tween_property(self, "self_modulate",Color(1, 1, 1, 0), 0.75 )
	await tween_fade.finished
	parent.queue_free()
	
	


func _physics_process(delta):
	
	#+ sprite.global_position
	#print("position", position)d
	#print("sprite position", sprite.a)
	var parent_pos = self.global_position
	#create_ghosting()
	
	if !is_on_floor() && (can_coyote_jump == false):
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000 
	
	if is_on_floor():
		inAir = false
	
	handle_Input()
	
	var horizontal_direction = Input.get_axis("move_left", "move_right")

	if horizontal_direction != 0 and rollTimer.is_stopped():
		switch_direction(horizontal_direction)


	if(rollTimer.is_stopped() || inAir):
		velocity.x = normalSpeed * horizontal_direction
	else:
		velocity.x =  200 * (-1 if sprite.flip_h else 1)

	
	if stuck_under_object && above_head_is_empty():
		if !Input.is_action_pressed("crouch"):
			stand()
			stuck_under_object = false
			print("Player was stuck but he is getting up")
	
	var was_on_floor = is_on_floor()
	
	
	# Started to fall
	if was_on_floor && !is_on_floor() && velocity.y >= 0:
		can_coyote_jump = true
		coyote_timer.start()
	
	# Touched ground
	if !was_on_floor && is_on_floor():
		if jump_buffered:
			jump_buffered = false
			print("Buffered jump")
			jump()
	
	if(attackTimer.is_stopped() and rollTimer.is_stopped()):
		#print("Not attacking or rolling")	
		update_animations(horizontal_direction)
	move_and_slide()
	

func handle_Input():
	if animation_locked:
		pass
	elif Input.is_action_just_pressed("jump"):
		jump_height_timer.start()
		jump()
	elif Input.is_action_just_pressed("attack") and attackTimer.is_stopped():
		attackTimer.start()
		attack()
	elif Input.is_action_just_pressed("crouch"):
		crouch()
		
	elif Input.is_action_just_released("crouch"):
		if above_head_is_empty():
				stand()
		else:
			if stuck_under_object != true:
				stuck_under_object = true
				print("Player stuck, setting stuck_under_object to true")
	elif Input.is_action_just_pressed("dash"):
		dashTimer.start()
		dash()
	if Input.is_action_just_pressed("roll") and rollTimer.is_stopped():
		rollTimer.start()
		if sprite.flip_h == true:
			rollDirection =-1
		else:
			rollDirection = 1
		roll()
func jump():
	if is_on_floor() || can_coyote_jump:
		velocity.y = -jump_force
		inAir = true
		if can_coyote_jump:
			can_coyote_jump = false
			print("Coyote jump")
	else:
		if !jump_buffered:
			jump_buffered = true
			jump_buffer_timer.start()
func _on_coyote_timer_timeout():
	can_coyote_jump = false
func _on_jump_buffer_timer_timeout():
	jump_buffered = false
func _on_jump_height_timer_timeout():
	if !Input.is_action_pressed("jump"):
		if velocity.y < -100:
			velocity.y = -100
			print("Low jump")
	else:
		print("High jump")
func above_head_is_empty() -> bool:
	var result = !crouch_raycast1.is_colliding() && !crouch_raycast2.is_colliding()
	return result 	
func update_animations(horizontal_direction):

	if is_on_floor():
		if horizontal_direction == 0:
			if is_crouching:
				ap.play("crouch")
			else:
				ap.play("idle")
		else:
			if is_crouching:
				ap.play("crouch_walk")
			else:
				if is_roll:
					ap.play("is_roll")
					print("is_roll")
				# if dash:
				# 	ap.play("dash")
				# else:
				if is_dashing:
					ap.play("dash")
					print('is dashing')
				else:
					ap.play("run")
	else:
		if is_crouching == false:
			if velocity.y < 0:
				ap.play("jump")
			elif velocity.y > 0:
				ap.play("fall")
		else:
			ap.play("crouch")
func switch_direction(horizontal_direction):
	sprite.flip_h = (horizontal_direction == -1)
	sprite.position.x = horizontal_direction * 4
	
	if (horizontal_direction > 0):
		Sword.position.x = abs(Sword.position.x)
		#Sword.rotation = -abs(Sword.rotation)
		SwordRotate.rotation = -abs(SwordRotate.rotation)

	else:
		#Sword.rotation = 0
		Sword.position.x = -abs(Sword.position.x)
		SwordRotate.rotation = abs(SwordRotate.rotation)
func attack():
	ap.play("attack")
	is_attacking = true
	print("Attack")
	audioPlayer.play()
func roll():

	ap.play("roll")
	is_roll = true

func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_cshape
	cshape.position.y = 28
	
func stand():
	if is_crouching == false:
		return
	is_crouching = false
	cshape.shape = standing_cshape
	cshape.position.y = 19.643

func dash():
	ap.play("dash")
	is_dashing = true


func _on_roll_timeout() -> void:
	is_roll = false
	pass # Replace with function body.
