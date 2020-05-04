extends "res://scenes/bots/_base/_BaseBot.gd"


const HEAT_BAR_WARNING_THRESHOLD: float = 0.75
const WEAP_OVERHEAT_COLOR: = Color(0.9, 0, 0) #red
const WEAP_HEAT_COLOR: = Color(1, 0.7, 0.15) #orange

onready var _bar_weapon_heat: = $Bars/WeaponHeat
onready var _bar_charge_level: = $Bars/ChargeLevel
onready var _hud_weapon_slots: = $PlayerUI/WeaponSlots
onready var _ui_inventory: = $PlayerUI/Inventory
onready var _ui_loadout_slots: = $PlayerUI/Inventory/Loadout/SlotsContainer
onready var _ui_all_items_slots: = $PlayerUI/Inventory/AllItems/SlotsContainer
onready var _ui_depot_slots: = $PlayerUI/Inventory/Depot/SlotsContainer
onready var _built_in_weapon: = $Weapons.get_child(0)
onready var ui_loadout_access_button: = _ui_loadout_slots.get_node("HBoxContainer2/ToAccess")
onready var ui_loadout: = $PlayerUI/Inventory/Loadout
onready var ui_depot: = $PlayerUI/Inventory/Depot


func _ready() -> void:
	#player initialization
	_init_player()


func _init_player() -> void:
	#player bars initialize
	_bar_weapon_heat.rect_position.x -= _bar_weapon_heat.rect_size.y + bot_radius + 15 #<- hardcoded for now
	_bar_weapon_heat.max_value = current_weapon.heat_capacity
	_bar_weapon_heat.value = 0
	_bar_charge_level.rect_position.x += bot_radius + 15 #<- hardcoded for now
	
	update_player_vars()
	#connect buttons
	_connect_buttons()
	#initialize ui weapons
	_init_weap_and_slot_selected()
	#initialize ui passives
	for slot_num in _arr_passives.size():
		update_ui_slot(slot_num, "passive")
	#initialize ui items
	for slot_num in _arr_items.size():
		update_ui_slot(slot_num, "inventory")


func _connect_buttons() -> void:
	var i: = 0
	i = 0 #connect weapon slots
	for weap_slot in _ui_loadout_slots.get_node("WeaponSlots").get_children():
		weap_slot.connect("pressed", self, "_on_WeaponSlot_pressed", [weap_slot.name])
		i += 1
	i = 0 #connect passive slots
	for passive_slot in _ui_loadout_slots.get_node("PassiveSlots").get_children():
		passive_slot.connect("pressed", self, "_on_PassiveSlot_pressed", [passive_slot.name])
		i += 1
	i = 0 #connect all item slots
	for all_item_slot in _ui_all_items_slots.get_node("ItemSlots").get_children():
		all_item_slot.connect("pressed", self, "_on_ItemSlot_pressed", [all_item_slot.name])
		i += 1
		if i == 20:
			break
	i = 0 #connect depot slots
	for depot_slot in _ui_depot_slots.get_node("DepotSlots").get_children():
		depot_slot.connect("pressed", self, "_on_DepotSlot_pressed", [depot_slot.name])
		i += 1
		if i == 15:
			break
	#connect trash slot
	_ui_all_items_slots.get_node("HBoxContainer/TrashSlot").connect("pressed", self, "_on_TrashSlot_pressed")
	#connect access buttons
	ui_loadout_access_button.connect("pressed", self, "_on_SwitchAccess_pressed")
	_ui_depot_slots.get_node("HBoxContainer2/ToLoadout").connect("pressed", self, "_on_SwitchAccess_pressed")


func _init_weap_and_slot_selected() -> void:
	var non_empty_slot_found: = false
	var slot_initialized: = false
	for slot_num in _arr_weapons.size():
		non_empty_slot_found = _update_ui_weapon_slot(slot_num)
		if non_empty_slot_found == true && slot_initialized == false: #initialize first selected slot
			_change_slot_selected(slot_num)
			slot_initialized = true


#use only on initialization or in bot stations
func update_player_vars() -> void:
	for i in _arr_passives.size():
		if _arr_passives[i] != null:
			_arr_passives[i]._apply_effects()
	_cap_current_vars()


func _change_slot_selected(slot_num: int) -> void:
	var weap = _arr_weapons[slot_num]
	if weap == null:
		return
	var selected_slot_pos = _hud_weapon_slots.get_node(slot_num as String + "/SelectPos")
	var slot_selected = _hud_weapon_slots.get_node("SlotSelected")
	slot_selected.position.x = selected_slot_pos.get_parent().position.x + selected_slot_pos.position.x
	change_weapon(slot_num)


func _control(delta):
	current_weapon.look_at(get_global_mouse_position())
	if (is_using_bot_station == true || ui_access != "") && _dict_held["item"] != null:
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
	if _ui_inventory.visible == true:
		return
	if Input.is_action_just_released("change_mode"):
		switch_mode()
	if Input.is_action_just_released("charge_roll"):
		if $Timers/ChargeCooldown.is_stopped() == true && _is_rolling == true:
			_update_bar_charge_level()
		charge_roll(current_weapon.global_rotation)
	if Input.is_action_pressed("shoot"):
		shoot_weapon()


func _process(delta: float) -> void:
	_control_camera(delta)
	
	#var _is_in_control has no influence here
	_held_item.position = get_viewport().get_mouse_position()
	
	_update_bar_weapon_heat()
	
	_update_weapon_hud_elements()
	
	if _is_transforming == false:
		_control_player_weapon_hotkeys()
	
	#inventory
	if Input.is_action_just_pressed("ui_inventory") && _dict_held["item"] == null:
		_ui_inventory.visible = !_ui_inventory.visible


func _physics_process(delta: float) -> void:
	pass


func _update_weapon_hud_elements() -> void:
	for i in _arr_weapons.size():
		if _arr_weapons[i] == null:
			continue
		var hud_weap_heat = _hud_weapon_slots.get_node(i as String + "/SlotHeat")
		if _arr_weapons[i].is_overheating() == true:
			hud_weap_heat.modulate = WEAP_OVERHEAT_COLOR
		else:
			hud_weap_heat.modulate = WEAP_HEAT_COLOR
		hud_weap_heat.value = _arr_weapons[i].current_heat()


func _control_camera(delta: float) -> void:
	var mouse_pos: = get_global_mouse_position().y - global_position.y
	var lerp_time: = 3.0 * (1 - pow(0.5, delta))
	var v_distance: = 0.4
	$Camera2D.offset.y = lerp($Camera2D.offset.y, mouse_pos * v_distance, lerp_time)


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
		_bar_weapon_heat.max_value = current_weapon.heat_capacity
		_bar_weapon_heat.value = 0


func _update_bar_charge_level() -> void:
	_bar_charge_level.value = 0
	_bar_charge_level.modulate = Color(0.6, 0.6, 0.6)
	var tween: = _bar_charge_level.get_node("ChargeTween")
	tween.interpolate_property(_bar_charge_level, 'value', _bar_charge_level.value, _bar_charge_level.max_value,
		_current_charge_cooldown, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_ChargeTween_tween_all_completed() -> void:
	$Sounds/ChargeReady.play()
	_bar_charge_level.modulate = Color(1, 0.24, 0.88)


func _update_bar_weapon_heat() -> void:
	var bar_weapon_heat_anim: = _bar_weapon_heat.get_node("WeaponHeatAnimation")
	if current_weapon.is_overheating() == true:
		_bar_weapon_heat.modulate = WEAP_OVERHEAT_COLOR
	elif current_weapon.is_overheating() == false && bar_weapon_heat_anim.is_playing() == false:
		_bar_weapon_heat.modulate = WEAP_HEAT_COLOR
	if current_weapon.current_heat() > current_weapon.heat_capacity * HEAT_BAR_WARNING_THRESHOLD:
		if bar_weapon_heat_anim.is_playing() == false && current_weapon.is_overheating() == false:
			bar_weapon_heat_anim.play("too_much_heat")
			$Sounds/CloseToOverheating.play()
	_bar_weapon_heat.value = current_weapon.current_heat()


######################
# inventory management
######################


#needs refactor holy crap


var is_using_bot_station: bool = false
var _trash_slot_held: Node = null
var _dict_held: Dictionary = {
	"item": null,
	"from_slot": "",
}
var _arr_items: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]
var _arr_passives: Array = [null, null, null, null, null]
var ui_access: String
var arr_access_items: Array = []

onready var _held_item = $PlayerUI/HeldItem


func _update_ui_weapon_slot(slot_num: int) -> bool:
	var weap = _arr_weapons[slot_num]
	var slot_num_str: = slot_num as String
	var hud_weap_sprite: = _hud_weapon_slots.get_node(slot_num_str + "/WeaponSprite")
	var hud_weap_heat: = _hud_weapon_slots.get_node(slot_num_str + "/SlotHeat")
	var inv_weap_sprite: = _ui_loadout_slots.get_node("WeaponSlots/" + slot_num_str + "/Sprite")
	if weap == null: #wipe empty weapon slot
		hud_weap_sprite.texture = null
		inv_weap_sprite.texture = null
		hud_weap_heat.value = 0
		return false
	else:
		var weap_sprite = weap.get_node("SlotIcon")
		hud_weap_heat.max_value = weap.heat_capacity
		_match_sprite(hud_weap_sprite, weap_sprite)
		_match_sprite(inv_weap_sprite, weap_sprite)
		return true


func update_ui_slot(slot_num: int, arr: String) -> void:
	var slot_num_str: = slot_num as String
	var slot_sprite: Sprite
	var item: Node
	match arr:
		"passive":
			item = _arr_passives[slot_num]
			slot_sprite = _ui_loadout_slots.get_node("PassiveSlots/" + slot_num_str + "/Sprite")
		"inventory":
			item = _arr_items[slot_num]
			slot_sprite = _ui_all_items_slots.get_node("ItemSlots/" + slot_num_str + "/Sprite")
		"trash":
			item = _trash_slot_held
			slot_sprite = _ui_inventory.get_node("AllItems/SlotsContainer/HBoxContainer/TrashSlot/Sprite")
		"depot":
			item = arr_access_items[slot_num]
			slot_sprite = _ui_depot_slots.get_node("DepotSlots/" + slot_num_str + "/Sprite")
	if item == null:
		slot_sprite.texture = null
	else:
		var item_sprite = item.get_node("SlotIcon")
		_match_sprite(slot_sprite, item_sprite)
		slot_sprite.show()


func _on_SwitchAccess_pressed() -> void:
	if ui_access == "":
		return
	match ui_access:
		"depot":
			ui_depot.visible = !ui_depot.visible
			ui_loadout.visible = !ui_loadout.visible


func _on_TrashSlot_pressed() -> void:
	if _dict_held["item"] == null && _trash_slot_held == null:
		return
	elif _dict_held["item"] == null && _trash_slot_held != null:
		_dict_held["item"] = _trash_slot_held
		_dict_held["from_slot"] = "item"
		_trash_slot_held = null
	elif _dict_held["item"] == _built_in_weapon:
		_show_inventory_warning("CAN'T TRASH BUILT-IN WEAPON")
		return
	elif _dict_held["item"] is Global.CLASS_WEAPON && _check_if_equipping_weapon() == false:
		_show_inventory_warning("EQUIP AT LEAST ONE WEAPON")
		return
	elif _dict_held["item"] != null && _dict_held["from_slot"] != "item" && is_using_bot_station == false:
		_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
		return
	else:
		if _trash_slot_held != null:
			_trash_slot_held.queue_free()
		_trash_slot_held = _dict_held["item"]
		_dict_held["item"] = null
		_dict_held["from_slot"] = ""
		if _trash_slot_held is Global.CLASS_WEAPON:
			_init_weap_and_slot_selected()
	update_ui_slot(0, "trash")
	_show_held_item()


func _on_DepotSlot_pressed(slot_name: String) -> void:
	var slot_num = slot_name as int
	var depot_item = arr_access_items[slot_num]
	var text1 = _ui_depot_slots.get_node("Instruction1")
	var text2 = _ui_depot_slots.get_node("Instruction2")
	var text_anim = _ui_depot_slots.get_node("InstructionAnim")
	if _dict_held["item"] == null && depot_item == null:
		return
	elif _dict_held["item"] == null && depot_item != null && _get_inv_count() == 20:
		text1.text = "EXCEPTION OCCURRED: INVENTORY IS FULL"
		text2.text = "EXCEPTION HANDLED: PREVENTED TAKE OUT"
		text_anim.stop(true)
		text_anim.play("fade_out")
		return
	elif _dict_held["item"] == null && depot_item != null:
		_dict_held["item"] = depot_item
		_dict_held["from_slot"] = "item"
		_change_item_parent(depot_item, get_node("Items"))
		arr_access_items[slot_num] = null
		text1.text = "ALL CLEAR"
		text2.text = ""
		text_anim.stop(true)
		text_anim.play("fade_out")
	elif _dict_held["item"] != null:
		text1.text = "EXCEPTION OCCURRED: RETURN EQUIPMENT"
		text2.text = "EXCEPTION HANDLED: PREVENTED RETURN"
		text_anim.stop(true)
		text_anim.play("fade_out")
		return
	update_ui_slot(slot_num, "depot")
	_show_held_item()


func _change_item_parent(item: Node, new_parent: Node) -> void:
	item.get_parent().remove_child(item)
	new_parent.add_child(item)
	item.set_parent_node(new_parent.get_parent())


func _on_ItemSlot_pressed(slot_name: String) -> void:
	_hold_item(_arr_items[slot_name as int], "item", slot_name as int)


func _on_WeaponSlot_pressed(slot_name: String) -> void:
	_hold_item(_arr_weapons[slot_name as int], "weapon", slot_name as int)


func _on_PassiveSlot_pressed(slot_name: String) -> void:
	_hold_item(_arr_passives[slot_name as int], "passive", slot_name as int)


func _hold_item(item: Node, slot: String, slot_num: int) -> void:
	if _dict_held["item"] == null && item == null:
		return
	if _dict_held["item"] == null:
		_dict_held["item"] = item
		_dict_held["from_slot"] = slot
		_show_held_item()
		match slot:
			"item": _arr_items[slot_num] = null
			"weapon": _arr_weapons[slot_num] = null
			"passive": _arr_passives[slot_num] = null
		match slot:
			"item": update_ui_slot(slot_num, "inventory")
			"weapon": _update_ui_weapon_slot(slot_num)
			"passive": update_ui_slot(slot_num, "passive")
	elif _dict_held["item"] != null:
		if slot == "passive" && _dict_held["item"] is Global.CLASS_PASSIVE == false:
			return
		elif slot == "weapon" && _dict_held["item"] is Global.CLASS_WEAPON == false:
			return
		elif _dict_held["item"] != null:
			_swap_item(item, slot, slot_num)


func _swap_item(item: Node, to_slot: String, slot_num: int) -> void:
	if is_using_bot_station == false && _dict_held["from_slot"] == "item" && to_slot != "item":
		_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
		return
	elif is_using_bot_station == false && _dict_held["from_slot"] != "item" && to_slot == "item":
		_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
		return
	elif is_using_bot_station == true && _dict_held["from_slot"] == "weapon" && to_slot == "item" && _check_if_equipping_weapon() == false:
		_show_inventory_warning("EQUIP AT LEAST ONE WEAPON")
		return
	match to_slot:
		"item":
			_arr_items[slot_num] = _dict_held["item"]
			_dict_held["item"] = item
			update_ui_slot(slot_num, "inventory")
		"weapon":
			_arr_weapons[slot_num] = _dict_held["item"]
			_dict_held["item"] = item
			_update_ui_weapon_slot(slot_num)
			_init_weap_and_slot_selected()
		"passive": 
			_arr_passives[slot_num] = _dict_held["item"]
			_dict_held["item"] = item
			update_ui_slot(slot_num, "passive")
	if _dict_held["item"] == null:
		_dict_held["from_slot"] = ""
	_show_held_item()


func _match_sprite(ui_sprite: Sprite, item_sprite: Sprite) -> void:
	ui_sprite.modulate = item_sprite.modulate
	ui_sprite.texture = item_sprite.texture
	ui_sprite.scale = item_sprite.scale
	ui_sprite.rotation = item_sprite.rotation
	ui_sprite.offset = item_sprite.offset


func _show_inventory_warning(warning_text: String) -> void:
	var warning = _ui_loadout_slots.get_node("HBoxContainer/InvalidSelectWarning")
	var warning_anim = _ui_loadout_slots.get_node("HBoxContainer/InvalidSelectWarning/Anim")
	warning.text = warning_text
	warning_anim.stop(true)
	warning_anim.play("fade_out")


func _show_held_item() -> void:
	if _dict_held["item"] != null:
		_match_sprite($PlayerUI/HeldItem, _dict_held["item"].get_node("SlotIcon"))
#		_held_item.texture = _dict_held["item"].get_node("SlotIcon").texture
#		_held_item.rotation = _dict_held["item"].get_node("SlotIcon").rotation
	elif _dict_held["item"] == null:
		_held_item.texture = null


func _check_if_equipping_weapon() -> bool:
	for weap in _arr_weapons:
		if weap != null:
			return true
	return false


func _get_inv_count() -> int:
	var count: int = 0
	for item in _arr_items:
		if item == null:
			continue
		count += 1
	return count
