extends "res://scenes/bots/_base/_BaseBot.gd"


onready var bar_weapon_heat: = $Bars/WeaponHeat
onready var bar_charge_level: = $Bars/ChargeLevel
onready var hud_weapon_slots: = $PlayerUI/WeaponSlots
onready var ui_inventory = $PlayerUI/Inventory
onready var ui_loadout: = $PlayerUI/Inventory/Slots/SlotsContainer
onready var ui_all_items: = $PlayerUI/Inventory/AllItems/SlotsContainer
onready var built_in_weapon: = $Weapons.get_child(0)

const HEAT_BAR_WARNING_THRESHOLD: float = 0.75
const WEAP_OVERHEAT_COLOR: = Color(0.9, 0, 0) #red
const WEAP_HEAT_COLOR: = Color(1, 0.7, 0.15) #orange

var arr_passives: Array = [null, null, null, null, null]
var arr_items: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]


func _ready() -> void:
	#player initialization
	_init_player()


func _init_player() -> void:
	#player bars initialize
	bar_weapon_heat.rect_position.x -= bar_weapon_heat.rect_size.y + bot_radius + 15 #<- hardcoded for now
	bar_weapon_heat.max_value = current_weapon.heat_capacity
	bar_weapon_heat.value = 0
	bar_charge_level.rect_position.x += bot_radius + 15 #<- hardcoded for now
	
	#will remove node later???
	_init_player_nodes()
	#update capped vars
	_update_player_vars()
	var i: = 0
	i = 0 #connect weapons inventory buttons
	for weap_slot in ui_loadout.get_node("WeaponSlots").get_children():
		weap_slot.connect("pressed", self, "_on_WeaponSlot_pressed", [weap_slot.name])
		i += 1
	i = 0 #connect passives inventory buttons
	for passive_slot in ui_loadout.get_node("PassiveSlots").get_children():
		passive_slot.connect("pressed", self, "_on_PassiveSlot_pressed", [passive_slot.name])
		i += 1
	i = 0 #connect all item buttons
	for all_item_slot in ui_all_items.get_node("ItemSlots").get_children():
		all_item_slot.connect("pressed", self, "_on_ItemSlot_pressed", [all_item_slot.name])
		i += 1
		if i == 20:
			break
	#connect trash slot
	ui_all_items.get_node("TrashSlot").connect("pressed", self, "_on_TrashSlot_pressed")
	#initialize ui weapons
	_init_slot_selected()
	#initialize ui passives
	for slot_num in arr_passives.size():
		_update_ui_passives(slot_num)
	#initialize ui items
	for slot_num in arr_items.size():
		_update_ui_items(slot_num)


#if passives and allitems node are populated
func _init_player_nodes() -> void:
	 #initialize player passives
	var i: int = 0
	for passive in $Passives.get_children():
		arr_passives[i] = passive
		i += 1
		if i == 5:
			break
	i = 0 #initialize player items
	for item in $AllItems.get_children():
		arr_items[i] = item
		i += 1
		if i == 20:
			break


func _init_slot_selected() -> void:
	var non_empty_slot_found: = false
	var slot_initialized: = false
	for slot_num in arr_weapons.size():
		non_empty_slot_found = _update_ui_weapons(slot_num)
		if non_empty_slot_found == true && slot_initialized == false: #initialize first selected slot
			_change_slot_selected(slot_num)
			slot_initialized = true


#use only on initialization or in bot stations
func _update_player_vars() -> void:
	for i in arr_passives.size():
		if arr_passives[i] != null:
			arr_passives[i].apply_effects()
	_cap_current_vars()


func _update_ui_weapons(slot_num: int) -> bool:
	var weap = arr_weapons[slot_num]
	var slot_num_str: = slot_num as String
	var hud_weap_sprite: = hud_weapon_slots.get_node(slot_num_str + "/WeaponSprite")
	var hud_weap_heat: = hud_weapon_slots.get_node(slot_num_str + "/SlotHeat")
	var inv_weap_sprite: = ui_loadout.get_node("WeaponSlots/" + slot_num_str + "/Sprite")
	if weap == null: #wipe empty weapon slot
		hud_weap_sprite.texture = null
		inv_weap_sprite.texture = null
		hud_weap_heat.value = 0
		return false
	else:
		var weap_sprite = weap.get_node("SlotIcon")
		hud_weap_sprite.texture = weap_sprite.texture
		hud_weap_sprite.transform = weap_sprite.transform
		hud_weap_sprite.offset = weap_sprite.offset
		hud_weap_heat.max_value = weap.heat_capacity
		inv_weap_sprite.texture = weap_sprite.texture
		inv_weap_sprite.scale = weap_sprite.scale
		inv_weap_sprite.rotation = weap_sprite.rotation
		inv_weap_sprite.offset = weap_sprite.offset
		return true


func _update_ui_passives(slot_num: int) -> void:
	var passive = arr_passives[slot_num]
	var slot_num_str: = slot_num as String
	var inv_passive_sprite: = ui_loadout.get_node("PassiveSlots/" + slot_num_str + "/Sprite")
	if passive == null: #wipe empty passive slot
		inv_passive_sprite.texture = null
	else:
		var passive_sprite = passive.get_node("SlotIcon")
		inv_passive_sprite.texture = passive_sprite.texture
		inv_passive_sprite.scale = passive_sprite.scale
		inv_passive_sprite.offset = passive_sprite.offset
		inv_passive_sprite.show()


func _update_ui_items(slot_num: int) -> void:
	var item = arr_items[slot_num]
	var slot_num_str: = slot_num as String
	var inv_item_sprite: = ui_all_items.get_node("ItemSlots/" + slot_num_str + "/Sprite")
	if item == null: #wipe empty slot
		inv_item_sprite.texture = null
	else:
		var item_sprite = item.get_node("SlotIcon")
		inv_item_sprite.texture = item_sprite.texture
		inv_item_sprite.scale = item_sprite.scale
		inv_item_sprite.rotation = item_sprite.rotation
		inv_item_sprite.offset = item_sprite.offset
		inv_item_sprite.show()


func _change_slot_selected(slot_num: int) -> void:
	var weap = arr_weapons[slot_num]
	if weap == null:
		return
	var selected_slot_pos = hud_weapon_slots.get_node(slot_num as String + "/SelectPos")
	var slot_selected = hud_weapon_slots.get_node("SlotSelected")
	slot_selected.position.x = selected_slot_pos.get_parent().position.x + selected_slot_pos.position.x
	change_weapon(slot_num)


func _control(delta):
	current_weapon.look_at(get_global_mouse_position())
	if is_customizable == true && dict_held["item"] != null:
		return
	if Input.is_action_pressed("move_up"):
		velocity.y = -1
	elif Input.is_action_pressed("move_down"):
		velocity.y = 1
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	elif Input.is_action_pressed("move_right"):
		velocity.x = 1
	velocity = velocity * delta
	if ui_inventory.visible == true:
		return
	if Input.is_action_just_released("change_mode"):
		switch_mode()
	if Input.is_action_just_released("charge_roll"):
		if $Timers/ChargeCooldown.is_stopped() == true && roll_mode == true:
			_update_bar_charge_level()
		charge(current_weapon.global_rotation)
	if Input.is_action_pressed("shoot"):
		shoot_weapon()


func _physics_process(delta: float) -> void:
	#var is_in_control has no influence here
	held_item.position = get_viewport().get_mouse_position()
	
	_update_bar_weapon_heat()
	
	_update_weapon_hud_elements()
	
	_control_player_weapon_hotkeys()
	
	_control_camera()
	
	#inventory
	if Input.is_action_just_pressed("ui_inventory") && dict_held["item"] == null:
		ui_inventory.visible = !ui_inventory.visible


func _update_weapon_hud_elements() -> void:
	for i in arr_weapons.size():
		if arr_weapons[i] == null:
			continue
		var hud_weap_heat = hud_weapon_slots.get_node(i as String + "/SlotHeat")
		if arr_weapons[i].is_overheating == true:
			hud_weap_heat.modulate = WEAP_OVERHEAT_COLOR
		else:
			hud_weap_heat.modulate = WEAP_HEAT_COLOR
		hud_weap_heat.value = arr_weapons[i].current_heat


func _control_camera() -> void:
	var mouse_pos: = get_global_mouse_position().y - global_position.y
	var lerp_speed: = 0.05
	var v_distance: = 0.4
	$Camera2D.offset.y = lerp($Camera2D.offset.y, mouse_pos * v_distance, lerp_speed)


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
		_change_slot_selected(slot_num)
		bar_weapon_heat.max_value = current_weapon.heat_capacity
		bar_weapon_heat.value = 0


func _update_bar_charge_level() -> void:
	bar_charge_level.value = 0
	bar_charge_level.modulate = Color(0.6, 0.6, 0.6)
	var tween: = bar_charge_level.get_node("ChargeTween")
	tween.interpolate_property(bar_charge_level, 'value', bar_charge_level.value, bar_charge_level.max_value,
		current_charge_cooldown, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
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


################################################################################
# inventory management
################################################################################

var is_customizable: bool = false
var class_weapon = preload("res://scenes/weapons/_base/_BaseWeapon.gd")
var class_passive = preload("res://scenes/passives/_base/_BasePassive.gd")
var dict_held: Dictionary = {
	"item": null,
	"from_slot": null,
	"slot_num": -1
}

onready var held_item = $PlayerUI/HeldItem


func _on_TrashSlot_pressed() -> void:
	print("trash slot pressed")


func _on_ItemSlot_pressed(slot_name: String) -> void:
	_hold_item(slot_name, arr_items)


func _on_WeaponSlot_pressed(slot_name: String) -> void:
	_hold_item(slot_name, arr_weapons)


func _on_PassiveSlot_pressed(slot_name: String) -> void:
	_hold_item(slot_name, arr_passives)


func _hold_item(slot_name: String, arr: Array) -> void:
	var slot_num: = slot_name as int
	if dict_held["item"] == null && arr[slot_num] == null:
		return
	if dict_held["item"] == null:
		dict_held["item"] = arr[slot_num]
		dict_held["from_slot"] = arr
		dict_held["slot_num"] = slot_num
		arr[slot_num] = null
		held_item.texture = dict_held["item"].get_node("SlotIcon").texture
		held_item.rotation = dict_held["item"].get_node("SlotIcon").rotation
		match arr:
			arr_items: _update_ui_items(slot_num)
			arr_weapons: _update_ui_weapons(slot_num)
			arr_passives: _update_ui_passives(slot_num)
	elif dict_held["item"] != null:
		if arr == arr_passives && dict_held["item"] is class_passive == false:
			return
		elif arr == arr_weapons && dict_held["item"] is class_weapon == false:
			return
		elif dict_held["item"] != null:
			_swap_items(slot_num, arr)


func _swap_items(slot_num: int, to_slot: Array) -> void:
	if is_customizable == false && dict_held["from_slot"] == arr_items && (to_slot == arr_weapons || to_slot == arr_passives):
		ui_loadout.get_node("HBoxContainer/InvalidSelectWarning/Anim").play("fade")
		return
	elif is_customizable == false && (dict_held["from_slot"] == arr_weapons || dict_held["from_slot"] == arr_passives) && to_slot == arr_items:
		ui_loadout.get_node("HBoxContainer/InvalidSelectWarning/Anim").play("fade")
		return
	else:
		var temp = to_slot[slot_num]
		to_slot[slot_num] = dict_held["item"]
		dict_held["item"] = temp
		match to_slot:
			arr_items: _update_ui_items(slot_num)
			arr_weapons:
				_update_ui_weapons(slot_num)
				_init_slot_selected()
			arr_passives:
				_update_ui_passives(slot_num)
		if dict_held["item"] == null:
			dict_held["from_slot"] = null
			dict_held["slot_num"] = -1
			held_item.texture = null
			return
		held_item.texture = dict_held["item"].get_node("SlotIcon").texture
