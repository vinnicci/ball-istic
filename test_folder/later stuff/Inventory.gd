extends Control


var _player: Node
var hud_weapon_slots: Node
var player_built_in_weap: Node
var held_item: Node
var dict_held: Dictionary = {
	"item": null,
	"from_slot": "",
}
var arr_weapons: Array
var arr_passives: Array = [null, null, null, null, null]
var arr_items: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]
var arr_trash: Array = [null]
var arr_external: Array
var access: String

onready var ui_loadout_slots: = $Loadout/SlotsContainer
onready var ui_items_slots: = $AllItems/SlotsContainer
onready var ui_depot_slots: = $Depot/SlotsContainer
onready var ui_vault_slots: = $Vault/SlotsContainer
onready var loadout_access_button: = ui_loadout_slots.get_node("HBoxContainer2/ToAccess")


func set_player(player_node) -> void:
	_player = player_node
	hud_weapon_slots = _player.hud_weapon_slots
	arr_weapons = _player.arr_weapons
	held_item = _player.get_node("PlayerUI/HeldItem")
	$Stats.set_player(_player)
	
	_connect_buttons()
	
	#initialize ui slots
	for slot_num in arr_passives.size():
		update_ui_slot(slot_num, "passive")
	
	for slot_num in arr_items.size():
		update_ui_slot(slot_num, "item")


func _connect_buttons() -> void:
	#connect weapon slots
	for weap_slot in ui_loadout_slots.get_node("WeaponSlots").get_children():
		weap_slot.connect("pressed", self, "_on_WeaponSlot_pressed", [weap_slot.name])
	
	#connect passive slots
	for passive_slot in ui_loadout_slots.get_node("PassiveSlots").get_children():
		passive_slot.connect("pressed", self, "_on_PassiveSlot_pressed", [passive_slot.name])
	
	#connect all item slots
	for item_slot in ui_items_slots.get_node("ItemSlots").get_children():
		item_slot.connect("pressed", self, "_on_ItemSlot_pressed", [item_slot.name])
	
	#connect depot slots
	for depot_slot in ui_depot_slots.get_node("DepotSlots").get_children():
		depot_slot.connect("pressed", self, "_on_DepotSlot_pressed", [depot_slot.name])
	
	#connect vault slots
	for vault_slot in ui_vault_slots.get_node("VaultSlots").get_children():
		vault_slot.connect("pressed", self, "_on_VaultSlot_pressed", [vault_slot.name])
	
	#connect trash slot
	ui_items_slots.get_node("HBoxContainer/TrashSlot").connect("pressed", self, "_on_TrashSlot_pressed")
	
	#connect access buttons
	loadout_access_button.connect("pressed", self, "_on_SwitchAccess_pressed")
	ui_depot_slots.get_node("HBoxContainer2/ToLoadout").connect("pressed", self, "_on_SwitchAccess_pressed")
	$Vault.get_node("HBoxContainer/ToLoadout").connect("pressed", self, "_on_SwitchAccess_pressed")


func _on_SwitchAccess_pressed() -> void:
	if access == "":
		return
	match access:
		"depot":
			$Depot.visible = !$Depot.visible
		"vault":
			$Vault.visible = !$Vault.visible
	$Loadout.visible = !$Loadout.visible


func _on_ItemSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "item", arr_items)


func _on_WeaponSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "weapon", arr_weapons)


func _on_PassiveSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "passive", arr_passives)


func _on_TrashSlot_pressed() -> void:
	_match_slot(0, "trash", arr_trash)


func _on_DepotSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "depot", arr_external)


func _on_VaultSlot_pressed(slot_name: String) -> void:
	_match_slot(slot_name as int, "vault", arr_external)


func _match_slot(slot_num: int, arr_name: String, arr: Array) -> void:
	if arr[slot_num] == null && dict_held["item"] == null:
		return
	match arr_name:
		"trash": _manage_trash()
		"item": _manage_items(slot_num)
		"weapon": _manage_weapons(slot_num)
		"passive": _manage_passives(slot_num)
		"depot": _manage_depot(slot_num)
		"vault": _manage_vault(slot_num)


func _manage_trash() -> void:
	if dict_held["item"] == null && arr_trash[0] != null:
		dict_held["item"] = arr_trash[0]
		dict_held["from_slot"] = "item"
		arr_trash[0] = null
	elif dict_held["item"] == player_built_in_weap:
		_show_inventory_warning("CAN'T TRASH BUILT-IN WEAPON")
		return
	elif dict_held["item"] is Global.CLASS_WEAPON && _check_if_equipping_weapon() == false:
		_show_inventory_warning("EQUIP AT LEAST ONE WEAPON")
		return
	elif dict_held["item"] != null && dict_held["from_slot"] != "item" && access != "bot_station":
		_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
		return
	else:
		if arr_trash[0] != null:
			arr_trash[0].queue_free()
		arr_trash[0] = dict_held["item"]
		dict_held["item"] = null
		dict_held["from_slot"] = ""
		if arr_trash[0] is Global.CLASS_WEAPON:
			hud_weapon_slots.update_weap_and_slot_selected()
	update_ui_slot(0, "trash")
	_show_held_item()


func _manage_items(slot_num: int) -> void:
	if dict_held["item"] != null:
		if access != "bot_station" && dict_held["from_slot"] != "item":
			_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
			return
		elif (access == "bot_station" && dict_held["from_slot"] == "weapon" &&
			_check_if_equipping_weapon() == false):
			_show_inventory_warning("EQUIP AT LEAST ONE WEAPON")
			return
	_swap("item", slot_num)


func _manage_weapons(slot_num: int) -> void:
	if dict_held["item"] != null:
		if access != "bot_station" && dict_held["from_slot"] == "item":
			_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
			return
		if dict_held["item"] is Global.CLASS_WEAPON == false:
			_show_inventory_warning("NOT A WEAPON")
			return
	_swap("weapon", slot_num)


func _manage_passives(slot_num: int) -> void:
	if dict_held["item"] != null:
		if access != "bot_station" && dict_held["from_slot"] == "item":
			_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
			return
		if dict_held["item"] is Global.CLASS_PASSIVE == false:
			_show_inventory_warning("NOT A PASSIVE")
			return
	_swap("passive", slot_num)


func _swap(slot_name: String, slot_num: int) -> void:
	var items = _player.get_node("Items")
	var weapons = _player.get_node("Weapons")
	var passives = _player.get_node("Passives")
	var arr_slot: Array
	match slot_name:
		"item":
			arr_slot = arr_items
			if (dict_held["item"] != null &&
				items.get_children().has(dict_held["item"]) == false):
				_own_item(dict_held["item"], items)
		"weapon":
			arr_slot = arr_weapons
			if (dict_held["item"] != null &&
				weapons.get_children().has(dict_held["item"]) == false):
				_own_item(dict_held["item"], weapons)
		"passive":
			arr_slot = arr_passives
			if (dict_held["item"] != null &&
				passives.get_children().has(dict_held["item"]) == false):
				_own_item(dict_held["item"], passives)
	var temp_hold = arr_slot[slot_num]
	arr_slot[slot_num] = dict_held["item"]
	dict_held["item"] = temp_hold
	dict_held["from_slot"] = slot_name
	_show_held_item()
	if slot_name != "weapon":
		update_ui_slot(slot_num, slot_name)
	else:
		update_ui_weapon_slot(slot_num)
		hud_weapon_slots.update_weap_and_slot_selected()


func _own_item(item: Node, new_parent: Node) -> void:
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	new_parent.add_child(item)
	item.set_parent(_player)


func _manage_depot(slot_num: int) -> void:
	var items = _player.get_node("Items")
	var depot_item = arr_external[slot_num]
	var text1 = ui_depot_slots.get_node("Instruction1")
	var text2 = ui_depot_slots.get_node("Instruction2")
	var text_anim = ui_depot_slots.get_node("InstructionAnim")
	if dict_held["item"] == null:
		if _get_inv_count() == 20:
			text1.text = "EXCEPTION OCCURRED: INVENTORY IS FULL"
			text2.text = "EXCEPTION HANDLED: PREVENTED TAKE OUT"
			text_anim.stop(true)
			text_anim.play("fade_out")
			return
		else:
			_own_item(depot_item, items)
			dict_held["item"] = depot_item
			dict_held["from_slot"] = "item"
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
	var items = _player.get_node("Items")
	if dict_held["item"] != null:
		if access != "bot_station" && dict_held["from_slot"] != "item":
			_show_inventory_warning("CAN'T DO THIS OUTSIDE BOT STATION")
			return
		if dict_held["item"] == player_built_in_weap:
			_show_inventory_warning("CAN'T STORE BUILT-IN WEAPON")
			return
		if dict_held["from_slot"] == "item":
			dict_held["item"].get_parent().remove_child(dict_held["item"])
	elif dict_held["item"] == null:
		if items.get_children().has(arr_external[slot_num]) == false:
			_own_item(arr_external[slot_num], items)
	var temp_hold = arr_external[slot_num]
	arr_external[slot_num] = dict_held["item"]
	dict_held["item"] = temp_hold
	dict_held["from_slot"] = "item"
	_show_held_item()
	update_ui_slot(slot_num, "vault")


func update_ui_weapon_slot(slot_num: int) -> bool:
	var weap = arr_weapons[slot_num]
	var slot_num_str: = slot_num as String
	var hud_weap_sprite: = hud_weapon_slots.get_node(slot_num_str + "/WeaponSprite")
	var hud_weap_heat: = hud_weapon_slots.get_node(slot_num_str + "/SlotHeat")
	var inv_weap_sprite: = ui_loadout_slots.get_node("WeaponSlots/" + slot_num_str + "/Sprite")
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
			item = arr_passives[slot_num]
			slot_sprite = ui_loadout_slots.get_node("PassiveSlots/" + slot_num_str + "/Sprite")
		"item":
			item = arr_items[slot_num]
			slot_sprite = ui_items_slots.get_node("ItemSlots/" + slot_num_str + "/Sprite")
		"trash":
			item = arr_trash[0]
			slot_sprite = get_node("AllItems/SlotsContainer/HBoxContainer/TrashSlot/Sprite")
		"depot":
			item = arr_external[slot_num]
			slot_sprite = ui_depot_slots.get_node("DepotSlots/" + slot_num_str + "/Sprite")
		"vault":
			item = arr_external[slot_num]
			slot_sprite = ui_vault_slots.get_node("VaultSlots/" + slot_num_str + "/Sprite")
	if item == null:
		_clear_sprite(slot_sprite)
	else:
		var item_sprite = item.get_node("SlotIcon")
		_match_sprite(slot_sprite, item_sprite)
		slot_sprite.show()


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


func _show_inventory_warning(warning_text: String) -> void:
	var warning = held_item.get_node("InvalidSelectWarning")
	var warning_anim = held_item.get_node("InvalidSelectWarning/Anim")
	warning.text = warning_text
	warning_anim.stop(true)
	warning_anim.play("fade_out")


func _show_held_item() -> void:
	if dict_held["item"] != null:
		_match_sprite(held_item.get_node("Sprite"), dict_held["item"].get_node("SlotIcon"))
	elif dict_held["item"] == null:
		_clear_sprite(held_item.get_node("Sprite"))


func _get_inv_count() -> int:
	var count: int = 0
	for item in arr_items:
		if item == null:
			continue
		count += 1
	return count
