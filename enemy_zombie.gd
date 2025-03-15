extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var alreadyAppeared = false


@onready var hitbox = $hurtbox
@onready var hitAnimator = $HitAnimationPlayer
@onready var hitTimer  = $hitTimer
@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var shader_material = $AnimatedSprite2D.material as ShaderMaterial
@onready var playDectection = $RayCast2D
@onready var Target = get_node("res://scenes/player.tscn")
#@onready var shader_material = material as ShaderMaterial
#@onready var playerPos = get_parent().get_parent().get_node("Player")
@onready var healthNode = $Health
@onready var dead = false
var gravity = 2.8
var friction = 20
@onready var health: Health = get_node("Health")
@onready var stun_timer = $StunTimer
var is_stunned = false
signal imortal(imortal: bool)
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var knockback_strength = 5
var knockback_velocity = 5
var is_knockback_back = false
var player: CharacterBody2D


var speed = 50
var knockback_resistance = 100.0
var is_knocked_back = false
var player_detected = false
func _ready() -> void:
	animator.play("appear")
	health.set_immortality(true)   

func _physics_process(delta: float) -> void:
	gravity_on(delta)
	if dead and animator.frame == 0:
		animator.play("die")
	if animator.animation == "die" and animator.frame == 3 and !is_on_floor():
		animator.pause()
		return
	if animator.animation == "die" and animator.frame ==3 and is_on_floor() and !animator.is_playing():
		animator.play()
	if animator.animation == "die":
		await animator.animation_finished
		queue_free()
	
	#if animator.animation == "appear":
		
		
	if animator.is_playing() and animator.animation == "die":
		return
	if animator.frame == 10 and animator.animation == "appear":
		animator.pause()
		health.set_immortality(false)   

	if !animator.is_playing() and animator.animation == "appear":	
		animator.play("Idle")
		
	if playDectection.is_colliding():
		player_detected = true
		
	if animator.animation != "appear" and !is_stunned and player_detected and is_on_floor():
		animator.play("walk")
		move(delta)
	move_and_slide()
func move(delta):
	player = Global.playerBody
	var dir = global_position.direction_to(player.global_position) * speed
	velocity.x = dir.x
	if dir.x > 0:
		animator.flip_h = true
	else:
		animator.flip_h = false

func gravity_on(delta: float):
	if !is_on_floor():
		velocity += Vector2.DOWN * gravity
		move_and_slide()
	else:
		velocity.x = lerpf(velocity.x, 0, friction * delta)
		move_and_slide()



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
func _on_health_health_depleted() -> void:
	dead = true
	
func _on_health_health_changed(diff: int) -> void:
	toggle_shader(true)
	speed = 0
	HitStopManager.hit_stop_short()
	await get_tree().create_timer(0.2).timeout  # Flash duration
	speed = 30
	toggle_shader(false)
	pass # Replace with function body.



func knockback(force: float, x_pos : float, up_force: float):
	#coming from the left, bounce to the right
	if x_pos < global_position.x:
		velocity = Vector2(force * 4, -force * up_force)
	#coming from the right, bounce to the left
	else:
		velocity = Vector2(-force * 4, -force * up_force)
	stun(.5)


func _on_hurt_box_knockback(strength: int, enemy_pos: Vector2, up_force:float) -> void:
	if !health.get_immortality():
		knockback(strength, enemy_pos.x, up_force)



func stun(duration):
	is_stunned = true
	stun_timer.wait_time = duration
	stun_timer.start()

func _on_stun_timer_timeout() -> void:
	is_stunned = false
