extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var alreadyAppeared = false


@onready var hitbox = $hurtbox
@onready var hitAnimator = $HitAnimationPlayer
@onready var hitTimer  = $hitTimer
@onready var animator = $AnimatedSprite2D
@onready var shader_material = $AnimatedSprite2D.material as ShaderMaterial
@onready var playDectection = $RayCast2D
@onready var Target = get_node("res://scenes/player.tscn")
#@onready var shader_material = material as ShaderMaterial
#@onready var playerPos = get_parent().get_parent().get_node("Player")
@onready var healthNode = $Health




var player: CharacterBody2D

var speed = 15

func _ready() -> void:

	animator.play("appear")


func _process(delta: float) -> void:
	
	if animator.frame == 10 and animator.animation == "appear":
		animator.pause()
	if !is_on_floor():
		velocity.y += 5
	
	if !animator.is_playing() and animator.animation == "appear":	
		animator.play("Idle")
		print("Idle is triggering")
	if playDectection.is_colliding():
		animator.play("walk")
	move(delta)

		#print(dir_to_player.x)


	
		#animator.play("Idle")
		#animator.set_animation("Idle")
		

		#animator.play("Idle")
	
	#hitTimer.timeout
	#if hitTimer.is_stopped():
		#hitAnimator.play("NotHit")

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
	#hitbox.knockback_vector = velocity.normalized() #Updating the knockback vector



	#move_and_slide()




#
#func knockback(vector):
	#velocity = velocity.move_toward(vector * movement_data.knockback_force, movement_data.acceleration)
#
#func _on_hurtbox_area_entered(area):
	#if not area.is_in_group("Bat"):
		#knockback(area.knockback_vector)
		#hit_animator.play("Hit")
		#update_health_bar()
		#if stats.health <= 0:
			#state_machine.call_deferred("transition_to", "Death")
			#health_bar.visible = false
func move(delta):
	player = Global.playerBody
	var dir = global_position.direction_to(player.global_position) * speed
	velocity.x = dir.x
	if dir.x > 0:
		animator.flip_h = true
	else:
		animator.flip_h = false
	move_and_slide()
	
	
	
	
	

func knockback(vector):
	#print(self.position)
	#print(self.position)d
	#print(self.position - vector*8)
	#velocity = velocity.move_toward(100.0, 20)
	velocity = velocity.move_toward(global_position, 0.2)
	
	#print(global_position - )

func _on_hurtbox_area_entered(area: Area2D) -> void:
	
	#knockback(area.knockback_vector)
	#hitAnimator.play("Hit")
	#if hitTimer.is_stopped():
		#hitTimer.start()
	print("got hit")
	#toggle_white_effect(true)
	#pass # Replace with function body.
	pass


func _on_hit_timer_timeout() -> void:
	hitAnimator.play("NotHit")
	pass # Replace with function body.

func create_white_texture(width, height):
	var image = Image.new()
	image.fill(Color.WHITE) # Fill with white
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func toggle_white_effect(enabled: bool):
	if enabled:
		print(animator.material)
	else:
		animator.material = null


func toggle_shader(enable: bool):
	shader_material.set_shader_parameter("effect_enabled", enable)
	
	



func _on_health_health_depleted():
	queue_free()
