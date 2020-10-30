extends "res://scenes/bots/_base/_BaseBot.gd"


const WEAP_OVERHEAT_COLOR: = Color(0.9, 0, 0) #red
const WEAP_HEAT_COLOR: = Color(1, 0.7, 0.15) #orange

onready var bar_weapon_heat: = $Bars/WeaponHeat
onready var bar_charge_level: = $Bars/ChargeLevel
onready var bar_transform: = $Bars/Transforming
onready var hud_weapon_slots: = $PlayerUI/WeaponSlots
onready var ui_inventory: = $PlayerUI/Inventory


func _ready() -> void:
	#player initialization
	_init_player()


func set_level(new_level) -> void:
	.set_level(new_level)
	for item in $Items.get_children():
		item.set_level(_level_node)
	for passive in $Passives.get_children():
		passive.set_level(_level_node)


func _init_player() -> void:
	#give player access to ui nodes
	ui_inventory.set_player(self)
	hud_weapon_slots.set_player(self)
	
	#explosion initialize
	$Explosion.set_player_cam($Camera2D)
	
	#player items ui initialize
	var i = 0
	for item in $Items.get_children():
		item.set_parent(self)
		item.modulate.a = 0
		ui_inventory.get_node("AllItems/SlotsContainer/ItemSlots/" + str(i)).set_item(item)
		i += 1
	
	i = 0
	for passive in $Passives.get_children():
		passive.set_parent(self)
		passive.modulate.a = 0
		ui_inventory.get_node("Loadout/SlotsContainer/PassiveSlots/" + str(i)).set_item(passive)
		i += 1
	
	update_player_vars()
	
	i = 0
	for weap in arr_weapons:
		ui_inventory.get_node("Loadout/SlotsContainer/WeaponSlots/" + str(i)).set_item(weap)
		$PlayerUI/WeaponSlots.get_node(str(i)).set_item(weap)
		i += 1
	
	#player bars initialize
	bar_weapon_heat.rect_position.x -= bar_weapon_heat.rect_size.y + bot_radius + 15 #<- hardcoded for now
	bar_weapon_heat.rect_position.y = bot_radius
	bar_charge_level.rect_position.x += bot_radius + 15 #<- hardcoded for now
	bar_charge_level.rect_position.y = bot_radius
	var bar_scale: float = float(bot_radius*2)/150.0
	bar_weapon_heat.rect_scale.x = bar_scale
	bar_charge_level.rect_scale.x = bar_scale


func update_player_vars() -> void:
	reset_bot_vars()
	for passive in $Passives.get_children():
		passive.apply_effect()
	cap_current_vars()
	#initialize player stats ui
	ui_inventory.get_node("Stats").update_stats()


func cap_current_vars() -> void:
	current_shield_cap = clamp(current_shield_cap, 0, 9999)
	current_shield = clamp(current_shield, 0, 9999)
	current_health_cap = clamp(current_health_cap, 1, 9999)
	current_health = clamp(current_health, 1, 9999)
	current_speed = clamp(current_speed, 0, 2500)
	current_transform_speed = clamp(current_transform_speed, 0, 1.0)
	set_current_charge_cooldown(current_charge_cooldown)
	current_charge_force_mult = clamp(current_charge_force_mult, 0.1, 1.5)
	current_knockback_resist = clamp(current_knockback_resist, 0, 1.0)


func _process(_delta: float) -> void:
	_update_bar_weapon_heat()


func _physics_process(_delta: float) -> void:
	_control_player()
	_control_player_weapon_hotkeys()


#used by level manager, to prevent mouse transform error when exiting scene
var stopped: bool = false


func _control_player() -> void:
	if stopped == true:
		return
	
	#inventory
	#can't close the ui if holding an item
	if (Input.is_action_just_pressed("ui_inventory") &&
		is_instance_valid(ui_inventory.held.item) == false):
		ui_inventory.visible = !ui_inventory.visible
		$PlayerUI/HeldItem.visible = ui_inventory.visible
	
	var mouse_pos = get_global_mouse_position()
	
	if state == State.TURRET || state == State.ROLL:
		current_weapon.look_at(mouse_pos)
	
	#lose control when inventory ui is open and in an access area
	if ui_inventory.accessing != "" && ui_inventory.visible == true:
		return
	if Input.is_action_pressed("move_up"):
		velocity.y += -1
	elif Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x += -1
	elif Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	#can't shoot/charge roll or transform when inventory is open
	if ui_inventory.visible == true:
		return
	if Input.is_action_just_pressed("change_mode"):
		switch_mode()
		animate_transform_cooldown()
	if Input.is_action_pressed("shoot"):
		shoot_weapon()
	if is_charge_roll_ready() == true:
		if Input.is_action_just_pressed("charge_roll"):
			charge_roll((mouse_pos - global_position).angle())
			animate_bar_charge_level(current_charge_cooldown)
		if Input.is_action_just_pressed("discharge_parry") :
			discharge_parry()
			animate_bar_charge_level(current_charge_cooldown)


func _control_player_weapon_hotkeys() -> void:
	var slot_num: int = -1
	if Input.is_action_just_pressed("weap_slot_0"):
		slot_num = 0
	elif Input.is_action_just_pressed("weap_slot_1"):
		slot_num = 1
	elif Input.is_action_just_pressed("weap_slot_2"):
		slot_num = 2
	elif Input.is_action_just_pressed("weap_slot_3"):
		slot_num = 3
	elif Input.is_action_just_pressed("weap_slot_4"):
		slot_num = 4
	if slot_num != -1:
		if change_weapon(slot_num) == true:
			hud_weapon_slots.change_slot_selected(slot_num)
			current_weapon.look_at(get_global_mouse_position())
		slot_num = -1


func stun_effect(stun_timer: float) -> void:
	if state == State.CHARGE_ROLL:
		return
	var tween = bar_transform.get_node("TransformTween")
	bar_transform.modulate = Color(1, 0.15, 0.15, 0.6)
	tween.interpolate_property(bar_transform, "value", 100, 0, stun_timer,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	.stun_effect(stun_timer)


func animate_transform_cooldown() -> void:
	var tween = bar_transform.get_node("TransformTween")
	if ((state == State.ROLL || state == State.TURRET) &&
		tween.is_active() == false):
		tween.interpolate_property(bar_transform, "value", 0, 100,
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()


func animate_bar_charge_level(time: float) -> void:
	if _timer_charge_cooldown.is_stopped() == true:
		return
	bar_charge_level.value = time
	bar_charge_level.modulate = Color(0.6, 0.6, 0.6)
	var tween: = bar_charge_level.get_node("ChargeTween")
	tween.interpolate_property(bar_charge_level, 'value', bar_charge_level.value,
		bar_charge_level.max_value, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	$Bars/ChargeLevel/ChargeTweenTimer.start(time)


func _on_ChargeTweenTimer_timeout() -> void:
	$Sounds/ChargeReady.play()
	bar_charge_level.modulate = Color(1, 0.24, 0.88)


onready var bar_weapon_heat_anim: = bar_weapon_heat.get_node("Anim")


func _update_bar_weapon_heat() -> void:
	match current_weapon.heat_state:
		Global.CLASS_WEAPON.HeatStates.OVERHEATING:
			if bar_weapon_heat.modulate != WEAP_OVERHEAT_COLOR:
				bar_weapon_heat.modulate = WEAP_OVERHEAT_COLOR
		Global.CLASS_WEAPON.HeatStates.ALMOST_OVERHEATING:
			if bar_weapon_heat_anim.is_playing() == false:
				bar_weapon_heat_anim.play("too_much_heat")
			if $Sounds/CloseToOverheating.playing == false:
				$Sounds/CloseToOverheating.play()
		Global.CLASS_WEAPON.HeatStates.NOT_OVERHEATING:
			if bar_weapon_heat_anim.is_playing() == true:
				bar_weapon_heat_anim.stop()
			if $Sounds/CloseToOverheating.playing == true:
				$Sounds/CloseToOverheating.stop()
			if bar_weapon_heat.modulate != WEAP_HEAT_COLOR:
				bar_weapon_heat.modulate = WEAP_HEAT_COLOR
	bar_weapon_heat.max_value = current_weapon.current_heat_cap
	bar_weapon_heat.value = current_weapon.current_heat


func take_damage(damage: float, knockback: Vector2, disp: bool = true) -> void:
	if current_shield <= 0:
		$Camera2D.shake_camera(10, 0.05, 0.05, 1)
	.take_damage(damage, knockback)


func _on_Bot_body_entered(body: Node) -> void:
	if (state != State.CHARGE_ROLL && body is Global.CLASS_BOT &&
		body.state == State.CHARGE_ROLL && timer_discharge_parry.is_stopped() == false):
			$Camera2D.shake_camera(20, 0.05, 0.05, 1)
	elif state == State.CHARGE_ROLL:
		$Camera2D.shake_camera(20, 0.05, 0.05, 1)
	._on_Bot_body_entered(body)


func _on_TransformTween_all_completed() -> void:
	bar_transform.value = 0
	bar_transform.modulate = Color(0.15, 1, 0.24, 0.6)
