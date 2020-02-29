extends "res://scenes/bot/player/TestBot.gd"

func _control():
	velocity = Vector2()
	if Input.is_action_just_released("change_mode"):
		roll_mode = !roll_mode
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_just_released("charge_roll"):
		charging = true

func _physics_process(delta: float) -> void:
	print(linear_velocity.length())
	if linear_velocity.length() >= 1000:
		$Sprite.texture = load("res://assets/player/charge_effect.png")
	else:
		$Sprite.texture = load("res://assets/player/player.png")
