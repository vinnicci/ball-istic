extends "res://scenes/bots/_base/_BaseBot.gd"


const WEAP_OVERHEAT_COLOR: = Color(0.9, 0, 0) #red
const WEAP_HEAT_COLOR: = Color(1, 0.7, 0.15) #orange

onready var _bar_weapon_heat: = $Bars/WeaponHeat
onready var _bar_charge_level: = $Bars/ChargeLevel
onready var _hud_weapon_slots: = $PlayerUI/WeaponSlots
onready var ui_inventory: = $PlayerUI/Inventory
onready var _ui_loadout_slots: = $PlayerUI/Inventory/Loadout/SlotsContainer
onready var _ui_all_items_slots: = $PlayerUI/Inventory/AllItems/SlotsContainer
onready var _ui_depot_slots: = $PlayerUI/Inventory/Depot/SlotsContainer
onready var _ui_vault_slots: = $PlayerUI/Inventory/Vault/SlotsContainer
onready var ui_loadout: = $PlayerUI/Inventory/Loadout
onready var ui_depot: = $PlayerUI/Inventory/Depot
onready var ui_vault: = $PlayerUI/Inventory/Vault
onready var _built_in_weapon: = $Weapons.get_child(0)
onready var ui_loadout_access_button: = _ui_loadout_slots.get_node("HBoxContainer2/ToAccess")


func _ready() -> void:
	#player initialization
	_init_player()


func _init_player() -> void:
	#explosion initialize
	$Explosion.set_player(self)
	
	#player bars initialize
	_bar_weapon_heat.rect_position.x -= _bar_weapon_heat.rect_size.y + bot_radius + 15 #<- hardcoded for now
	_bar_weapon_heat.max_value = current_weapon.heat_capacity
	_bar_weapon_heat.value = 0
	_bar_charge_level.rect_position.x += bot_radius + 15 #<- hardcoded for now
	
	update_player_vars()
	
	#inventory buttons
	_connect_buttons()
	
	#initialize hud weapons
	_init_weap_and_slot_selected()
	
	#initialize ui passives
	for slot_num in _arr_passives.size():
		update_ui_slot(slot_num, "passive")
	
	#initialize ui items
	for slot_num in _arr_all_items.size():
		update_ui_slot(slot_num, "all_item")


#code dupes
#refactor later to pass node and parse strings
func _connect_buttons() -> void:
	#connect weapon slots
	for weap_slot in _ui_loadout_slots.get_node("WeaponSlots").get_children():
		weap_slot.connect("pressed", self, "_on_WeaponSlot_pressed", [weap_slot.name])
	
	#connect passive slots
	for passive_slot in _ui_loadout_slots.get_node("PassiveSlots").get_children():
		passive_slot.connect("pressed", self, "_on_PassiveSlot_pressed", [passive_slot.name])
	
	#connect all item slots
	for all_item_slot in _ui_all_items_slots.get_node("ItemSlots").get_children():
		all_item_slot.connect("pressed", self, "_on_ItemSlot_pressed", [all_item_slot.name])
	
	#connect depot slots
	for depot_slot in _ui_depot_slots.get_node("DepotSlots").get_children():
		depot_slot.connect("pressed", self, "_on_DepotSlot_pressed", [depot_slot.name])
	
	#connect vault slots
	for vault_slot in _ui_vault_slots.get_node("VaultSlots").get_children():
		vault_slot.connect("pressed", self, "_on_VaultSlot_pressed", [vault_slot.name])
	
	#connect trash slot
	_ui_all_items_slots.get_node("HBoxContainer/TrashSlot").connect("pressed", self, "_on_TrashSlot_pressed")
	
	#connect access buttons
	ui_loadout_access_button.connect("pressed", self, "_on_SwitchAccess_pressed")
	_ui_depot_slots.get_node("HBoxContainer2/ToLoadout").connect("pressed", self, "_on_SwitchAccess_pressed")
	ui_vault.get_node("HBoxContainer/ToLoadout").connect("pressed", self, "_on_SwitchAccess_pressed")


func _init_weap_and_slot_selected() -> void:
	var non_empty_slot_found: = false
	var slot_initialized: = false
	for slot_num in arr_weapons.size():
		non_empty_slot_found = _update_ui_weapon_slot(slot_num)
		if non_empty_slot_found == true && slot_initialized == false: #initialize first selected slot
			_change_slot_selected(slot_num)
			slot_initialized = true


#used only on initialization or in bot stations
func update_player_vars() -> void:
	for i in _arr_passives.size():
		if _arr_passives[i] != null:
			_arr_passives[i]._apply_effects()
	_cap_current_vars()


func _change_slot_selected(slot_num: int) -> void:
	if change_weapon(slot_num) == false:
		return
	var selected_slot_pos = _hud_weapon_slots.get_node(slot_num as String + "/SelectPos")
	var slot_selected = _hud_weapon_slots.get_node("SlotSelected")
	slot_selected.position.x = selected_slot_pos.get_parent().position.x + selected_slot_pos.position.x
	current_weapon.look_at(get_global_mouse_position())
	_bar_weapon_heat.max_value = current_weapon.heat_capacity
	_bar_weapon_heat.value = 0


func _process(delta: float) -> void:
	if _held_item != null:
		_held_item.position = get_viewport().get_mouse_position()
		_held_item.global_rotation = 0
	
	_update_bar_weapon_heat()
	
	_update_weapon_hud()
	
	_control_player_weapon_hotkeys()
	
	#inventory
	#can't close the ui if holding an item
	if Input.is_action_just_pressed("ui_inventory") && _dict_held["item"] == null:
		ui_inventory.visible = !ui_inventory.visible


func _physics_process(delta: float) -> void:
	_control_player()


func _control_player() -> void:
	if state == State.TURRET || state == State.ROLL:
		current_weapon.look_at(get_global_mouse_position())
	
	#lose control when inventory ui is open and in an access area
	if ui_access != "" && ui_inventory.visible == true:
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
	if Input.is_action_just_pressed("charge_roll"):
		if _timer_charge_cooldown.is_stopped() == true && state == State.ROLL:
			_update_bar_charge_level()
		charge_roll(current_weapon.global_rotation)
	if Input.is_action_pressed("shoot"):
		shoot_weapon()
	if Input.is_action_just_pressed("discharge_parry"):
		if _timer_charge_cooldown.is_stopped() == true && (state == State.TURRET ||
			state == State.TO_TURRET || state == State.WEAP_COMMIT):
			_update_bar_charge_level()
		discharge_parry()


func _update_weapon_hud() -> void:
	for i in arr_weapons.size():
		if arr_weapons[i] == null:
			continue
		var hud_weap_heat = _hud_weapon_slots.get_node(i as String + "/SlotHeat")
		if arr_weapons[i].is_overheating() == true:
			hud_weap_heat.modulate = WEAP_OVERHEAT_COLOR
		else:
			hud_weap_heat.modulate = WEAP_HEAT_COLOR
		hud_weap_heat.value = arr_weapons[i].current_heat


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


func _update_bar_charge_level() -> void:
	_bar_charge_level.value = 0
	_bar_charge_level.modulate = Color(0.6, 0.6, 0.6)
	var tween: = _bar_charge_level.get_node("ChargeTween")
	tween.interpolate_property(_bar_charge_level, 'value', _bar_charge_level.value,
		_bar_charge_level.max_value, current_charge_cooldown, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_ChargeTween_tween_all_completed() -> void:
	$Sounds/ChargeReady.play()
	_bar_charge_level.modulate = Color(1, 0.24, 0.88)


func _update_bar_weapon_heat() -> void:
	var bar_weapon_heat_anim: = _bar_weapon_heat.get_node("Anim")
	if current_weapon.is_overheating() == true:
		_bar_weapon_heat.modulate = WEAP_OVERHEAT_COLOR
	elif current_weapon.is_overheating() == false && bar_weapon_heat_anim.is_playing() == false:
		_bar_weapon_heat.modulate = WEAP_HEAT_COLOR
	if current_weapon.is_almost_overheating() == true:
		if bar_weapon_heat_anim.is_playing() == false && current_weapon.is_overheating() == false:
			bar_weapon_heat_anim.play("too_much_heat")
			$Sounds/CloseToOverheating.play()
	_bar_weapon_heat.value = current_weapon.current_heat


func take_damage(damage: float, knockback: Vector2) -> void:
	if current_shield <= 0:
		$Camera2D.shake_camera(20, 0.05, 0.05, 1)
	.take_damage(damage, knockback)


func _on_Bot_body_entered(body: Node) -> void:
	if (state != State.CHARGE_ROLL && body is Global.CLASS_BOT &&
		body.state == State.CHARGE_ROLL && _timer_discharge_parry.is_stopped() == false):
			$Camera2D.shake_camera(20, 0.05, 0.05, 1)
	elif state == State.CHARGE_ROLL:
		$Camera2D.shake_camera(20, 0.05, 0.05, 1)
	._on_Bot_body_entered(body)


################################################################################
# inventory management
################################################################################
var _dict_held: Dictionary = {
	"item": null,
	"from_slot": "",
}
var _arr_trash: Array = [null]
var _arr_all_items: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]
var _arr_passives: Array = [null, null, null, null, null]
var ui_access: String
var arr_external: Array

onready var _held_item = $PlayerUI/HeldItem


#similar to upddate_ui_slot func but with extra steps and returns bool value
func _update_ui_weapon_slot(slot_num: int) -> bool:
	var weap = arr_weapons[slot_num]
	var slot_num_str: = slot_num as String
	var hud_weap_sprite: = _hud_weapon_slots.get_node(slot_num_str + "/WeaponSprite")
	var hud_weap_heat: = _hud_weapon_slots.get_node(slot_num_str + "/SlotHeat")
	var inv_weap_sprite: = _ui_loadout_slots.get_node("WeaponSlots/" + slot_num_str + "/Sprite")
	if weap == null: #wipe empty weapon slot
		_clear_sprite(hud_weap_sprite)
		_clear_sprite(inv_weap_sprite)
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
		"all_item":
			item = _arr_all_items[slot_num]
			slot_sprite = _ui_all_items_slots.get_node("ItemSlots/" + slot_num_str + "/Sprite")
		"trash":
			item = _arr_trash[0]
			slot_sprite = ui_inventory.get_node("AllItems/SlotsContainer/HBoxContainer/TrashSlot/Sprite")
		"depot":
			item = arr_external[slot_num]
			slot_sprite = _ui_depot_slots.get_node("DepotSlots/" + slot_num_str + "/Sprite")
		"vault":
			item = arr_external[slot_num]
			slot_sprite = _ui_vault_slots.get_node("VaultSlots/" + slot_num_str + "/Sprite")
	if item == null:
		_clear_sprite(slot_sprite)
#		slot_sprite.texture = null
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
		"vault":
			ui_vault.visible = !ui_vault.visible
	ui_loadout.visible = !ui_loadout.visible


func _on_ItemSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "all_item", _arr_all_items)


func _on_WeaponSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "weapon", arr_weapons)


func _on_PassiveSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "passive", _arr_passives)


func _on_TrashSlot_pressed() -> void:
	_match_slot(0, "trash", _arr_trash)


func _on_DepotSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "depot", arr_external)


func _on_VaultSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "vault", arr_external)


func _match_slot(slot_num: int, arr_name: String, arr: Array) -> void:
	if arr[slot_num] == null && _dict_held["item"] == null:
		return
	match arr_name:
		"trash": _manage_trash()
		"all_item": _manage_all_items(slot_num)
		"weapon": _manage_weapons(slot_num)
		"passive": _manage_passives(slot_num)
		"depot": _manage_depot(slot_num)
		"vault": _manage_vault(slot_num)


func _manage_trash() -> void:
	if _dict_held["item"] == null && _arr_trash[0] != null:
		_dict_held["item"] = _arr_trash[0]
		_dict_held["from_slot"] = "all_item"
		_arr_trash[0] = null
	elif _dict_held["item"] == _built_in_weapon:
		_show_inventory_warning("CAN'T TRASH BUILT-IN WEAPON")
		return
	elif _dict_held["item"] is Global.CLASS_WEAPON && _check_if_equipping_weapon() == false:
		_show_inventory_warning("EQUIP AT LEAST ONE WEAPON")
		return
	elif _dict_held["item"] != null && _dict_held["from_slot"] != "item" && ui_access != "bot_station":
		_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
		return
	else:
		if _arr_trash[0] != null:
			_arr_trash[0].queue_free()
		_arr_trash[0] = _dict_held["item"]
		_dict_held["item"] = null
		_dict_held["from_slot"] = ""
		if _arr_trash[0] is Global.CLASS_WEAPON:
			_init_weap_and_slot_selected()
	update_ui_slot(0, "trash")
	_show_held_item()


func _manage_depot(slot_num: int) -> void:
	var depot_item = arr_external[slot_num]
	var text1 = _ui_depot_slots.get_node("Instruction1")
	var text2 = _ui_depot_slots.get_node("Instruction2")
	var text_anim = _ui_depot_slots.get_node("InstructionAnim")
	if _dict_held["item"] == null:
		if _get_inv_count() == 20:
			text1.text = "EXCEPTION OCCURRED: INVENTORY IS FULL"
			text2.text = "EXCEPTION HANDLED: PREVENTED TAKE OUT"
			text_anim.stop(true)
			text_anim.play("fade_out")
			return
		else:
			_own_item(depot_item, get_node("Items"))
			_dict_held["item"] = depot_item
			_dict_held["from_slot"] = "all_item"
			arr_external[slot_num] = null
			text1.text = "ALL CLEAR"
			text2.text = ""
			text_anim.stop(true)
			text_anim.play("fade_out")
	else:
		text1.text = "EXCEPTION OCCURRED: RETURN EQUIPMENT"
		text2.text = "EXCEPTION HANDLED: PREVENTED RETURN"
		text_anim.stop(true)
		text_anim.play("fade_out")
		return
	update_ui_slot(slot_num, "depot")
	_show_held_item()


func _manage_vault(slot_num: int) -> void:
	if _dict_held["item"] != null:
		if ui_access != "bot_station" && _dict_held["from_slot"] != "all_item":
			_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
			return
		if _dict_held["item"] == _built_in_weapon:
			_show_inventory_warning("CAN'T STORE BUILT-IN WEAPON")
			return
	elif _dict_held["item"] == null:
		if arr_external[slot_num].get_parent_node() != self:
			_own_item(arr_external[slot_num], self)
	var temp_hold = arr_external[slot_num]
	arr_external[slot_num] = _dict_held["item"]
	_dict_held["item"] = temp_hold
	_dict_held["from_slot"] = "all_item"
	_show_held_item()
	update_ui_slot(slot_num, "vault")


func _swap(slot_name: String, slot_num: int) -> void:
	var arr_slot: Array
	match slot_name:
		"all_item": arr_slot = _arr_all_items
		"weapon": arr_slot = arr_weapons
		"passive": arr_slot = _arr_passives
	var temp_hold = arr_slot[slot_num]
	arr_slot[slot_num] = _dict_held["item"]
	_dict_held["item"] = temp_hold
	_dict_held["from_slot"] = slot_name
	_show_held_item()
	if slot_name != "weapon":
		update_ui_slot(slot_num, slot_name)
	else:
		_update_ui_weapon_slot(slot_num)
		_init_weap_and_slot_selected()


func _manage_all_items(slot_num: int) -> void:
	if _dict_held["item"] != null:
		if ui_access != "bot_station" && _dict_held["from_slot"] != "all_item":
			_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
			return
		elif (ui_access == "bot_station" && _dict_held["from_slot"] == "weapon" &&
			_check_if_equipping_weapon() == false):
			_show_inventory_warning("EQUIP AT LEAST ONE WEAPON")
			return
	_swap("all_item", slot_num)


func _manage_weapons(slot_num: int) -> void:
	if _dict_held["item"] != null:
		if ui_access != "bot_station" && _dict_held["from_slot"] == "all_item":
			_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
			return
		if _dict_held["item"] is Global.CLASS_WEAPON == false:
			_show_inventory_warning("NOT A WEAPON")
			return
	_swap("weapon", slot_num)


func _manage_passives(slot_num: int) -> void:
	if _dict_held["item"] != null:
		if ui_access != "bot_station" && _dict_held["from_slot"] == "all_item":
			_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
			return
		if _dict_held["item"] is Global.CLASS_PASSIVE == false:
			_show_inventory_warning("NOT A PASSIVE")
			return
	_swap("passive", slot_num)


#works from depot or from vault
func _own_item(item: Node, new_parent: Node) -> void:
	item.get_parent().remove_child(item)
	new_parent.add_child(item)
	item.set_parent(new_parent.get_parent())


func _match_sprite(ui_sprite: Sprite, item_sprite: Sprite) -> void:
	_clear_sprite(ui_sprite)
	ui_sprite.texture = item_sprite.texture
	if item_sprite.get_child_count() != 0:
		for sprite in item_sprite.get_children():
			ui_sprite.add_child(sprite.duplicate())
	ui_sprite.modulate = item_sprite.modulate
	ui_sprite.self_modulate = item_sprite.self_modulate
	ui_sprite.scale = item_sprite.scale
	ui_sprite.rotation = item_sprite.rotation
	ui_sprite.offset = item_sprite.offset


func _show_inventory_warning(warning_text: String) -> void:
	var warning = _held_item.get_node("InvalidSelectWarning")
	var warning_anim = _held_item.get_node("InvalidSelectWarning/Anim")
	warning.text = warning_text
	warning_anim.stop(true)
	warning_anim.play("fade_out")


func _show_held_item() -> void:
	if _dict_held["item"] != null:
		_match_sprite($PlayerUI/HeldItem/Sprite, _dict_held["item"].get_node("SlotIcon"))
	elif _dict_held["item"] == null:
		_clear_sprite(_held_item.get_node("Sprite"))
		


func _clear_sprite(sprite: Sprite) -> void:
	sprite.texture = null
	if sprite.get_child_count() != 0:
		for child_sprite in sprite.get_children():
			child_sprite.queue_free()


func _check_if_equipping_weapon() -> bool:
	for weap in arr_weapons:
		if weap != null:
			return true
	return false


func _get_inv_count() -> int:
	var count: int = 0
	for item in _arr_all_items:
		if item == null:
			continue
		count += 1
	return count
