extends "res://scenes/bots/BaseBot.gd"

#eventually ??
#mode: Character --> rolling animations based on direction

func _control():
	velocity = Vector2()
	$Weapon.look_at(get_global_mouse_position())
	if Input.is_action_pressed("shoot"):
		is_shooting = true
	if Input.is_action_just_released("change_mode"):
		$VelocityDirection.visible = !$VelocityDirection.visible
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
	if roll_mode == true:
		$VelocityDirection.global_rotation = linear_velocity.angle()
