extends "res://scenes/bots/_BaseBot.gd"

#eventually ??
onready var weapon_heat = $PlayerBars/WeaponHeat
onready var charge_level = $PlayerBars/ChargeLevel
const PLAYER_BARS_OFFSET: int = 15
const HEAT_BAR_WARNING_THRESHOLD: float = 0.75


func _ready() -> void:
	weapon_heat.rect_position.x -= weapon_heat.rect_size.y + bot_radius + PLAYER_BARS_OFFSET
	charge_level.rect_position.x += bot_radius + PLAYER_BARS_OFFSET
	weapon_heat.max_value = $Weapon.heat_capacity
	weapon_heat.value = 0


func _process(_delta: float) -> void:
	$PlayerBars.global_rotation = 0
	if $Weapon/OverheatCooldown.is_stopped() == false:
		weapon_heat.modulate = Color(0.960784, 0.090196, 0)
	if $Weapon/OverheatCooldown.is_stopped() == true && weapon_heat.get_node("AnimationPlayer").is_playing() == false:
		weapon_heat.modulate = Color(0.913725, 0.639216, 0.058824)
	animate_weapon_heat_bar()


func _control():
	velocity = Vector2()
	$Weapon.look_at(get_global_mouse_position())
	if Input.is_action_pressed("shoot"):
		shoot_weapon()
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
		if $ChargeCooldown.is_stopped() == true && roll_mode == true:
			animate_charge_level_bar()
		charge_attack($Weapon.global_rotation)


func animate_charge_level_bar() -> void:
	charge_level.value = 0
	charge_level.modulate = Color(0.627451, 0.627451, 0.627451)
	var tween = charge_level.get_node("Tween")
	tween.interpolate_property(charge_level, 'value', charge_level.value, charge_level.max_value,
		$ChargeCooldown.wait_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func animate_weapon_heat_bar() -> void:
	if $Weapon.current_heat > $Weapon.heat_capacity * HEAT_BAR_WARNING_THRESHOLD:
		weapon_heat.get_node("AnimationPlayer").play("too_much_heat")
	weapon_heat.value = $Weapon.current_heat


func _on_ChargeCooldown_timeout() -> void:
	charge_level.get_node("AnimationPlayer").play("charge_ready")
