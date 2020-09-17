extends Control


var _player: Node
var player_built_in_weap: Node
var accessing: String
var held: Node

onready var _loadout_weapon_slots: = $Loadout/SlotsContainer/WeaponSlots
onready var _loadout_passive_slots: = $Loadout/SlotsContainer/PassiveSlots
onready var _all_item_slots: = $AllItems/SlotsContainer/ItemSlots
onready var _depot: = $Depot/SlotsContainer
onready var _vault: = $Vault/SlotsContainer
onready var access_button: = $Loadout/SlotsContainer/HBoxContainer2/AccessButton


func _ready() -> void:
	_connect_slot_buttons()


func _connect_slot_buttons() -> void:
	for weap_slot in _loadout_weapon_slots.get_children():
		weap_slot.connect("pressed", self, "on_slot_pressed", [weap_slot])
	
	for passive_slot in _loadout_passive_slots.get_children():
		passive_slot.connect("pressed", self, "on_slot_pressed", [passive_slot])
	
	for item_slot in _all_item_slots.get_children():
		item_slot.connect("pressed", self, "on_slot_pressed", [item_slot])
	
	for depot_slot in _depot.get_node("DepotSlots").get_children():
		depot_slot.connect("pressed", self, "on_slot_pressed", [depot_slot])
	
	for vault_slot in _vault.get_node("VaultSlots").get_children():
		vault_slot.connect("pressed", self, "on_slot_pressed", [vault_slot])
	
	var trash_slot = $AllItems/SlotsContainer/HBoxContainer/TrashSlot
	trash_slot.connect("pressed", self, "on_slot_pressed", [trash_slot])
	
	access_button.connect("pressed", self, "_on_SwitchAccess_pressed")
	_depot.get_node("HBoxContainer/ToLoadout").connect("pressed", self, "_on_SwitchAccess_pressed")
	$Vault/HBoxContainer/ToLoadout.connect("pressed", self, "_on_SwitchAccess_pressed")


func set_player(player_node) -> void:
	_player = player_node
	held = _player.get_node("PlayerUI/HeldItem")
#	$Loadout.set_player(_player)
#	$AllItems.set_player(_player)
	$Stats.set_player(_player)


func _process(delta: float) -> void:
	held.position = get_viewport().get_mouse_position()


func _on_SwitchAccess_pressed() -> void:
	if accessing == "":
		return
	match accessing:
		"depot":
			$Depot.visible = !$Depot.visible
		"vault":
			$Vault.visible = !$Vault.visible
	$Loadout.visible = !$Loadout.visible


func on_slot_pressed(slot_node) -> void:
	if held.item == null && slot_node.item == null:
		return
	match slot_node.from_slot:
		"weapon": _manage_weapon(slot_node)
		"passive": _manage_passive(slot_node)
		"item": _manage_item(slot_node)
		"trash": _manage_trash(slot_node)
		"depot": _manage_depot(slot_node)
#		"vault": _manage_vault(slot_node)


func _swap(slot_node: Node) -> void:
	var temp_held = held.item
	held.set_item(slot_node.item, slot_node.from_slot)
	slot_node.set_item(temp_held)


func _show_inventory_warning(warning_text: String) -> void:
	var warning = held.get_node("InvalidSelectWarning")
	var warning_anim = held.get_node("InvalidSelectWarning/Anim")
	warning.text = warning_text
	warning_anim.stop(true)
	warning_anim.play("fade_out")


func _check_if_equipping_weapon() -> bool:
	for weap in _loadout_weapon_slots.get_children():
		if weap.item != null:
			return true
	return false


const NOT_IN_BOT_STATION : String = "CAN'T CUSTOMIZE OUTSIDE BOT STATION"


func _manage_weapon(slot_node: Node) -> void:
	if held.item != null:
		if accessing != "bot_station" && held.from_slot == "item":
			_show_inventory_warning(NOT_IN_BOT_STATION)
			return
		if held.item is Global.CLASS_WEAPON == false:
			_show_inventory_warning("NOT A WEAPON")
			return
	_swap(slot_node)


func _manage_passive(slot_node: Node) -> void:
	if held.item != null:
		if accessing != "bot_station" && held.from_slot == "item":
			_show_inventory_warning(NOT_IN_BOT_STATION)
			return
		if held.item is Global.CLASS_PASSIVE == false:
			_show_inventory_warning("NOT A PASSIVE")
			return
	_swap(slot_node)


const NO_WEAPON: String = "EQUIP AT LEAST ONE WEAPON"


func _manage_item(slot_node: Node) -> void:
	if held.item != null:
		if (accessing != "bot_station" && 
			(held.from_slot == "weapon" ||
			held.from_slot == "passive")):
			_show_inventory_warning(NOT_IN_BOT_STATION)
			return
		elif (accessing == "bot_station" && held.from_slot == "weapon" &&
			_check_if_equipping_weapon() == false):
			_show_inventory_warning(NO_WEAPON)
			return
	_swap(slot_node)


func _manage_trash(slot_node: Node) -> void:
	if held.item == null && slot_node.item != null:
		_swap(slot_node)
	elif held.item == player_built_in_weap:
		_show_inventory_warning("CAN'T REMOVE BUILT-IN WEAPON")
		return
	elif held.item is Global.CLASS_WEAPON && _check_if_equipping_weapon() == false:
		_show_inventory_warning(NO_WEAPON)
		return
	elif (held.item != null && accessing != "bot_station" &&
		(held.from_slot == "weapon" ||
		held.from_slot == "passive")):
		_show_inventory_warning(NOT_IN_BOT_STATION)
		return
	else:
		if slot_node.item != null:
			slot_node.item.queue_free()
			slot_node.set_item(null)
		_swap(slot_node)


var items_external: Node


func update_access_ui() -> void:
	for i in items_external.get_children().size():
		match accessing:
			"depot":
				_depot.get_node("DepotSlots/" + str(i)).set_item(items_external.get_child(i))
			"vault":
				_vault.get_node("VaultSlots/" + str(i)).set_item(items_external.get_child(i))


func _manage_depot(slot_node: Node) -> void:
	var player_items = _player.get_node("Items") 
	var text1 = _depot.get_node("Instruction1")
	var text2 = _depot.get_node("Instruction2")
	var text_anim = _depot.get_node("InstructionAnim")
	if held.item == null:
		if _get_inv_count() >= 20:
			text1.text = "EXCEPTION OCCURRED: INVENTORY IS FULL"
			text2.text = "EXCEPTION HANDLED: PREVENT TAKE OUT"
			text_anim.stop(true)
			text_anim.play("fade_out")
			return
		else:
			_swap(slot_node)
			_change_parent(held.item, _player.get_node("Items"))
			text1.text = "ALL CLEAR"
			text2.text = ""
			text_anim.stop(true)
			text_anim.play("fade_out")
	else:
		text1.text = "EXCEPTION OCCURRED: RETURN EQUIPMENT"
		text2.text = "EXCEPTION HANDLED: PREVENT RETURN"
		text_anim.stop(true)
		text_anim.play("fade_out")
		return


func _get_inv_count() -> int:
	var count: int = 0
	for slot in _all_item_slots.get_children():
		if slot.item == null:
			continue
		count += 1
	return count


func _change_parent(item, new_parent) -> void:
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	new_parent.add_child(item)
	if new_parent.get_parent() is Global.CLASS_PLAYER:
		item.set_parent(new_parent)
