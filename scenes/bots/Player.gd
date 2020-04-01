extends "res://scenes/bots/_BaseBot.gd"


onready var bar_weapon_heat: = $Bars/WeaponHeat
onready var bar_charge_level: = $Bars/ChargeLevel
#onready var bar_shoot_cooldown = $Bars/ShootCooldown
onready var hud_weapon: = $PlayerHUD/WeaponSlots

const PLAYER_BARS_OFFSET: int = 15
const HEAT_BAR_WARNING_THRESHOLD: float = 0.75
const SLOT_LABEL_COLOR: = Color(0.13, 0.27, 0.15) #low value green
const WEAP_OVERHEAT_COLOR: = Color(0.9, 0, 0) #red
const WEAP_HEAT_COLOR = Color(1, 0.7, 0.15) #orange

var dict_weapon_hud: Dictionary = {}
var current_slot_selected: int = -1


func _ready() -> void:
	#player specific stats
	_set_up_player_hud()
	_set_up_player_default_vars()
	update_player_vars()


func _set_up_player_hud() -> void:
	var selected_slot_initialized: = false
	var i: = -1
	for slot in $Weapons.get_children():
		i += 1
		if slot.has_node("Weapon") == false:
			continue
		#initialize first selected slot
		if selected_slot_initialized == false:
			_change_slot_selected(i)
			selected_slot_initialized = true
		#initialize hud
		var weap = slot.get_node("Weapon")
		hud_weapon.get_node("Slot" + i as String + "/Sprite").texture = weap.get_node("Sprite").texture
		hud_weapon.get_node("Slot" + i as String + "/SlotHeat").max_value = weap.heat_capacity
		dict_weapon_hud[weap] = hud_weapon.get_node("Slot" + i as String)


func _set_up_player_default_vars() -> void:
	bar_weapon_heat.rect_position.x -= bar_weapon_heat.rect_size.y + bot_radius + PLAYER_BARS_OFFSET
#	bar_weapon_heat.rect_position.x = bar_shoot_cooldown.rect_position.x - PLAYER_BARS_OFFSET
	bar_charge_level.rect_position.x += bot_radius + PLAYER_BARS_OFFSET


func update_player_vars() -> void:
	bar_weapon_heat.max_value = current_weapon.heat_capacity
	bar_weapon_heat.value = 0


func _change_slot_selected(slot_num: int) -> void:
	if has_node("Weapons/Slot" + slot_num as String + "/Weapon") == false || current_slot_selected == slot_num:
		return
	if current_slot_selected != -1:
		hud_weapon.get_node("Slot" + current_slot_selected as String + "/SlotLabel").add_color_override("font_color", SLOT_LABEL_COLOR)
	var selected_slot_sprite = hud_weapon.get_node("SelectSprite")
	var selected_slot_pos = hud_weapon.get_node("Slot" + slot_num as String + "/SelectPos")
	selected_slot_sprite.position = selected_slot_pos.position
	hud_weapon.get_node("SelectSprite").position = selected_slot_pos.position
	hud_weapon.get_node("Slot" + slot_num as String + "/SlotLabel").add_color_override("font_color", selected_slot_sprite.modulate)
	current_slot_selected = slot_num


func _control(delta):
	current_weapon.look_at(get_global_mouse_position())
	if Input.is_action_pressed("shoot"):
#		if current_weapon.get_node("ShootCooldown").is_stopped() == true && roll_mode == false:
#			_update_bar_weapon_shoot_cooldown()
		shoot_weapon()
	if Input.is_action_just_released("change_mode"):
		switch_mode()
	if Input.is_action_pressed("move_up"):
		velocity.y = -1
	elif Input.is_action_pressed("move_down"):
		velocity.y = 1
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	elif Input.is_action_pressed("move_right"):
		velocity.x = 1
	if Input.is_action_just_released("charge_roll"):
		if $Timers/ChargeCooldown.is_stopped() == true && roll_mode == true:
			_update_bar_charge_level()
		charge_attack(current_weapon.global_rotation)
	velocity = velocity * delta


func _process(delta: float) -> void:
	#hud
	_update_hud_elements()
	
	#equip hotkeys
	_control_player_weapon_hotkeys()
	
	#weapon heat bar
	_update_bar_weapon_heat()
	
	#camera
	_control_camera()


func _update_hud_elements() -> void:
	for slot in $Weapons.get_children():
		if slot.has_node("Weapon") == false:
			continue
		var weap = slot.get_node("Weapon")
		var hud_weap_heat = dict_weapon_hud[weap].get_node("SlotHeat")
		if weap.is_overheating == true:
			hud_weap_heat.modulate = WEAP_OVERHEAT_COLOR
		else:
			hud_weap_heat.modulate = WEAP_HEAT_COLOR
		hud_weap_heat.value = weap.current_heat


#func _update_bar_weapon_shoot_cooldown() -> void:
#	var shoot_cooldown: float = current_weapon.get_node("ShootCooldown").wait_time
#	var tween: = $Bars/ShootCooldown/ShootCooldownTween
#	bar_shoot_cooldown.value = 0
#	tween.interpolate_property(bar_shoot_cooldown, 'value', bar_shoot_cooldown.value, bar_shoot_cooldown.max_value,
#		shoot_cooldown, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()


func _control_camera() -> void:
	var mouse_pos = get_global_mouse_position().y - global_position.y
	var lerp_speed: = 0.04
	$Camera2D.offset.y = lerp($Camera2D.offset.y, mouse_pos * 0.35, lerp_speed)


func _control_player_weapon_hotkeys() -> void:
	var changed: bool = false
	if Input.is_action_just_pressed("weap_slot_0"):
		change_weapon(0)
		_change_slot_selected(0)
		changed = true
	elif Input.is_action_just_pressed("weap_slot_1"):
		change_weapon(1)
		_change_slot_selected(1)
		changed = true
	elif Input.is_action_just_pressed("weap_slot_2"):
		change_weapon(2)
		_change_slot_selected(2)
		changed = true
	elif Input.is_action_just_pressed("weap_slot_3"):
		change_weapon(3)
		_change_slot_selected(3)
		changed = true
	elif Input.is_action_just_pressed("weap_slot_4"):
		change_weapon(4)
		_change_slot_selected(4)
		changed = true
	if changed == true:
		update_player_vars()


func _update_bar_charge_level() -> void:
	bar_charge_level.value = 0
	bar_charge_level.modulate = Color(0.6, 0.6, 0.6)
	var tween = bar_charge_level.get_node("ChargeTween")
	tween.interpolate_property(bar_charge_level, 'value', bar_charge_level.value, bar_charge_level.max_value,
		charge_cooldown, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_ChargeTween_tween_all_completed() -> void:
	$Sounds/ChargeReady.play()
	bar_charge_level.modulate = Color(1, 0.24, 0.88)


func _update_bar_weapon_heat() -> void:
	var bar_weapon_heat_anim = bar_weapon_heat.get_node("WeaponHeatAnimation")
	if current_weapon.is_overheating == true:
		bar_weapon_heat.modulate = WEAP_OVERHEAT_COLOR
	elif current_weapon.is_overheating == false && bar_weapon_heat_anim.is_playing() == false:
		bar_weapon_heat.modulate = WEAP_HEAT_COLOR
	if current_weapon.current_heat > current_weapon.heat_capacity * HEAT_BAR_WARNING_THRESHOLD:
		if bar_weapon_heat_anim.is_playing() == false && current_weapon.is_overheating == false:
			bar_weapon_heat_anim.play("too_much_heat")
			$Sounds/CloseToOverheating.play()
	bar_weapon_heat.value = current_weapon.current_heat
