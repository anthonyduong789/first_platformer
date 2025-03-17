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
# @onready var attackTimer = Global.attackTimer
@onready var rollTimer = $roll
@onready var CharacterCollision = $CollisionShape2D
#@onready var Sword = $Sprite2D/Sword/CollisionShape2D
@onready var Sword = $Sprite2D/HitBox
@onready var SwordRotate = $Sprite2D/HitBox/CollisionShape2D
@export var SPEED = 25
@export var normalSpeed = 50
@export var dashSpeed = 525

@onready var health = 10
@onready var audioPlayer = $AudioPlayer


var inAir = false
var is_crouching = false
var stuck_under_object = false
var can_coyote_jump = false
var jump_buffered = false
var is_attacking = false
var dash = false
var is_roll = false
var rollDirection = 1


var standing_cshape = preload("res://resources/knight_standing_cshape.tres")
var crouching_cshape = preload("res://resources/knight_crouching_cshape.tres")

func _ready() -> void:
	Global.playerBody = self
	Global.attackTimer = attackTimer

func create_ghosting(tx_pos, tx_scale):
	var new_ghost: Sprite2D = sprite.duplicate()
	
	get_tree().current_scene.add_child(new_ghost)
	new_ghost.position = self.position 
	#new_ghost.centered = true
	new_ghost.scale = tx_scale
	var tween_fade = new_ghost.create_tween()
	tween_fade.tween_property(self, "self_modulate",Color(1, 1, 1, 0), 0.75 )
	await tween_fade.finished
	new_ghost.queue_free()
	


func _physics_process(delta):
	
	#+ sprite.global_position
	#print("position", position)d
	#print("sprite position", sprite.a)
	create_ghosting(position, scale)
	
	if !is_on_floor() && (can_coyote_jump == false):
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000 
	
	if is_on_floor():
		inAir = false
	
	if Input.is_action_just_pressed("jump"):
		jump_height_timer.start()
		jump()
	
	if Input.is_action_just_pressed("attack") and attackTimer.is_stopped():
		attackTimer.start()
		attack()
	
	var horizontal_direction = Input.get_axis("move_left", "move_right")

	if horizontal_direction != 0 and rollTimer.is_stopped():
		switch_direction(horizontal_direction)



	if !inAir:
		if Input.is_action_pressed("dash"):
			dash = true
			SPEED = dashSpeed
		else:
			dash = false
			SPEED = normalSpeed
			
	if Input.is_action_just_pressed("roll") and rollTimer.is_stopped():
		rollTimer.start()

		
		# sprite.flip_h = (horizontal_direction == -1)
		if sprite.flip_h == true:
			rollDirection =-1
		else:
			rollDirection = 1
		roll()


	if(rollTimer.is_stopped() || inAir):
		velocity.x = SPEED * horizontal_direction
	else:
		velocity.x =  200 * rollDirection


	



	if Input.is_action_just_pressed("crouch"):
		crouch()
	
		
	elif Input.is_action_just_released("crouch"):
		if above_head_is_empty():
			stand()
		else:
			if stuck_under_object != true:
				stuck_under_object = true
				print("Player stuck, setting stuck_under_object to true")
	
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

#func temp_disable_enemyCollision():
	#for other in get_tree().get_nodes_in_group("Enemy"):
		#other.character_collision.set_deferred("disabled", true)
func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_cshape
	cshape.position.y = 26
	
func stand():
	if is_crouching == false:
		return
	is_crouching = false
	cshape.shape = standing_cshape
	cshape.position.y = 20
