extends "res://scenes/bots/BaseBot.gd"

#eventually ??
#mode: Character --> rolling animations based on direction
const CHARGE_SPRITE_VELOCITY_FACTOR: float = 0.76
const NORMAL_SPRITE_VELOCITY_FACTOR: float = 0.6

func _control():
	velocity = Vector2()
	if Input.is_action_just_released("change_mode"):
		switch_mode()
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_just_released("charge_roll"):
		is_charging = true

func _physics_process(_delta: float) -> void:
	if linear_velocity.length() > roll_speed * CHARGE_SPRITE_VELOCITY_FACTOR:
		$BodySprite.texture = load("res://assets/player/charge_effect.png")
	if linear_velocity.length() < roll_speed * NORMAL_SPRITE_VELOCITY_FACTOR:
		$BodySprite.texture = load("res://assets/player/player.png")
	if roll_mode == true:
		$VelocityDirection.show()
		$VelocityDirection.global_rotation = linear_velocity.angle()
	else:
		$VelocityDirection.hide()
