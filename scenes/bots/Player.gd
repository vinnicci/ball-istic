extends "res://scenes/bots/_BaseBot.gd"


onready var bar_weapon_heat: = $Bars/WeaponHeat
onready var bar_charge_level: = $Bars/ChargeLevel
onready var hud_weapon_slots: = $UI/PlayerUI/WeaponSlots
onready var ui_inventory: = $UI/PlayerUI/Inventory

const PLAYER_BARS_OFFSET: int = 15
const HEAT_BAR_WARNING_THRESHOLD: float = 0.75
const WEAP_OVERHEAT_COLOR: = Color(0.9, 0, 0) #red
const WEAP_HEAT_COLOR: = Color(1, 0.7, 0.15) #orange

var is_inventory_open: bool = false


func _ready() -> void:
	#player specific initialization
	_init_player()


func _init_player() -> void:
	#player bars initialize
	bar_weapon_heat.rect_position.x -= bar_weapon_heat.rect_size.y + bot_radius + PLAYER_BARS_OFFSET
	bar_charge_level.rect_position.x += bot_radius + PLAYER_BARS_OFFSET
	var i: = 0 #connect inventory buttons
	for weap_slot in ui_inventory.get_node("Slots/SlotsContainer/WeaponSlots").get_children():
		weap_slot.connect("pressed", self, "_on_WeaponSlot" + i as String + "_pressed")
		i += 1
	update_player_vars()
	update_ui_weapons()


func update_player_vars() -> void:
	bar_weapon_heat.max_value = current_weapon.heat_capacity
	bar_weapon_heat.value = 0


func update_ui_weapons() -> void:
	var selected_slot_initialized: = false
	for i in dict_weapons.keys():
		var weap = dict_weapons[i]
		var i_str: = i as String
		var hud_weap_sprite: = hud_weapon_slots.get_node("Slot" + i_str + "/WeaponSprite")
		var hud_weap_heat: = hud_weapon_slots.get_node("Slot" + i_str + "/SlotHeat")
		var inv_weap_sprite: = ui_inventory.get_node("Slots/SlotsContainer/WeaponSlots/WeaponSlot" + i_str + "/WeaponSprite")
		var inv_swap_label: = ui_inventory.get_node("Slots/SlotsContainer/WeaponSlots/WeaponSlot" + i_str + "/SwapPromptLabel")
		inv_swap_label.hide()
		if weap == null: #wipe weapon inventory slot
			hud_weap_sprite.texture = null
			hud_weap_heat.value = 0
			inv_weap_sprite.texture = null
		else: #initialize hud & inv
			if selected_slot_initialized == false: #initialize first selected slot
				_change_slot_selected(i)
				selected_slot_initialized = true
			var weap_sprite_tex = weap.get_node("Sprite").texture
			hud_weap_sprite.texture = weap_sprite_tex
			hud_weap_heat.max_value = weap.heat_capacity
			inv_weap_sprite.texture = weap_sprite_tex


func _change_slot_selected(slot_num: int) -> void:
	var weap = dict_weapons[slot_num]
	if weap == null:
		return
	change_weapon(slot_num)
	var selected_slot_pos = hud_weapon_slots.get_node("Slot" + slot_num as String + "/SelectPos")
	var slot_selected = hud_weapon_slots.get_node("SlotSelected")
	slot_selected.position.x = selected_slot_pos.get_parent().position.x + selected_slot_pos.position.x


func _control(delta):
	current_weapon.look_at(get_global_mouse_position())
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
	velocity = velocity * delta
	if is_inventory_open == true:
		return
	if Input.is_action_just_released("charge_roll"):
		if $Timers/ChargeCooldown.is_stopped() == true && roll_mode == true:
			_update_bar_charge_level()
		charge_attack(current_weapon.global_rotation)
	if Input.is_action_pressed("shoot"):
		shoot_weapon()


func _process(delta: float) -> void:
	#is_in_control var has no influence here
	#weapon heat bar
	_update_bar_weapon_heat()
	
	#weap slot hud
	_update_weapon_hud_elements()
	
	#equip hotkeys
	_control_player_weapon_hotkeys()
	
	#camera
	_control_camera()
	
	#inventory
	if Input.is_action_just_pressed("ui_inventory") && temp_weapon_slot_held == -1:
		is_inventory_open = !is_inventory_open
		ui_inventory.visible = !ui_inventory.visible


func _update_weapon_hud_elements() -> void:
	for i in dict_weapons.keys():
		if dict_weapons[i] == null:
			continue
		var hud_weap_heat = hud_weapon_slots.get_node("Slot" + i as String + "/SlotHeat")
		if dict_weapons[i].is_overheating == true:
			hud_weap_heat.modulate = WEAP_OVERHEAT_COLOR
		else:
			hud_weap_heat.modulate = WEAP_HEAT_COLOR
		hud_weap_heat.value = dict_weapons[i].current_heat


func _control_camera() -> void:
	var mouse_pos: = get_global_mouse_position().y - global_position.y
	var lerp_speed: = 0.04
	$Camera2D.offset.y = lerp($Camera2D.offset.y, mouse_pos * 0.35, lerp_speed)


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
		change_weapon(slot_num)
		_change_slot_selected(slot_num)
		update_player_vars()


func _update_bar_charge_level() -> void:
	bar_charge_level.value = 0
	bar_charge_level.modulate = Color(0.6, 0.6, 0.6)
	var tween: = bar_charge_level.get_node("ChargeTween")
	tween.interpolate_property(bar_charge_level, 'value', bar_charge_level.value, bar_charge_level.max_value,
		charge_cooldown, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_ChargeTween_tween_all_completed() -> void:
	$Sounds/ChargeReady.play()
	bar_charge_level.modulate = Color(1, 0.24, 0.88)


func _update_bar_weapon_heat() -> void:
	var bar_weapon_heat_anim: = bar_weapon_heat.get_node("WeaponHeatAnimation")
	if current_weapon.is_overheating == true:
		bar_weapon_heat.modulate = WEAP_OVERHEAT_COLOR
	elif current_weapon.is_overheating == false && bar_weapon_heat_anim.is_playing() == false:
		bar_weapon_heat.modulate = WEAP_HEAT_COLOR
	if current_weapon.current_heat > current_weapon.heat_capacity * HEAT_BAR_WARNING_THRESHOLD:
		if bar_weapon_heat_anim.is_playing() == false && current_weapon.is_overheating == false:
			bar_weapon_heat_anim.play("too_much_heat")
			$Sounds/CloseToOverheating.play()
	bar_weapon_heat.value = current_weapon.current_heat


func _on_WeaponSlot0_pressed() -> void:
	_manage_inventory_weapons(0)

func _on_WeaponSlot1_pressed() -> void:
	_manage_inventory_weapons(1)

func _on_WeaponSlot2_pressed() -> void:
	_manage_inventory_weapons(2)

func _on_WeaponSlot3_pressed() -> void:
	_manage_inventory_weapons(3)

func _on_WeaponSlot4_pressed() -> void:
	_manage_inventory_weapons(4)


var temp_weapon_slot_held: int = -1
func _manage_inventory_weapons(slot_num: int) -> void:
	var node: = ui_inventory.get_node("Slots/SlotsContainer/WeaponSlots/WeaponSlot" + slot_num as String)
	var weap_sprite: = node.get_node("WeaponSprite")
	var swap_label: = node.get_node("SwapPromptLabel")
	#i feel like it needs refactoring but works for now
	#when first slot is selected and slot is empty
	if temp_weapon_slot_held == -1 && weap_sprite.texture == null:
		return
	#when first slot is selected
	elif temp_weapon_slot_held == -1 && weap_sprite.texture != null:
		temp_weapon_slot_held = slot_num
		swap_label.show()
	#when second slot selected is same as first
	elif temp_weapon_slot_held != -1 && swap_label.visible == true:
		temp_weapon_slot_held = -1
		swap_label.visible = false
	#when second slot selected is different from first
	elif temp_weapon_slot_held != -1 && swap_label.visible == false: 
		var weap_held = dict_weapons[temp_weapon_slot_held]
		dict_weapons[temp_weapon_slot_held] = dict_weapons[slot_num]
		dict_weapons[slot_num] = weap_held
		temp_weapon_slot_held = -1
		update_ui_weapons()
