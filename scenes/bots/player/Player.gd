extends "res://scenes/bots/_base/_BaseBot.gd"


onready var bar_weapon_heat: = $Bars/WeaponHeat
onready var bar_charge_level: = $Bars/ChargeLevel
onready var hud_weapon_slots: = $PlayerUI/WeaponSlots
onready var ui_inventory = $PlayerUI/Inventory
onready var ui_loadout: = $PlayerUI/Inventory/Slots/SlotsContainer
onready var ui_all_items: = $PlayerUI/Inventory/AllItems/SlotsContainer

const HEAT_BAR_WARNING_THRESHOLD: float = 0.75
const WEAP_OVERHEAT_COLOR: = Color(0.9, 0, 0) #red
const WEAP_HEAT_COLOR: = Color(1, 0.7, 0.15) #orange

var dict_passives: Dictionary = {
	0: null,
	1: null,
	2: null,
	3: null,
	4: null
}
var dict_items: Dictionary = {
	0: null, 1: null, 2: null, 3: null, 4: null,
	5: null, 6: null, 7: null, 8: null, 9: null,
	10: null, 11: null, 12: null, 13: null, 14: null,
	15: null, 16: null, 17: null, 18: null, 19: null
}


func _ready() -> void:
	#player specific initialization
	_init_player()


func _init_player() -> void:
	#player bars initialize
	bar_weapon_heat.rect_position.x -= bar_weapon_heat.rect_size.y + bot_radius + 15 #<- hardcoded for now
	bar_weapon_heat.max_value = current_weapon.heat_capacity
	bar_weapon_heat.value = 0
	bar_charge_level.rect_position.x += bot_radius + 15 #<- hardcoded for now
	var i: = 0 #initialize player passives
	for passive in $Passives.get_children():
		dict_passives[i] = passive
		i += 1
		if i == 5:
			break
	i = 0 #initialize player items
	for item in $AllItems.get_children():
		dict_items[i] = item
		i += 1
		if i == 20:
			break
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
	_update_player_vars()
	_update_ui_weapons()
	_update_ui_passives()
	_update_ui_items()


#use only on initialization or in bot repair or loadout bays
func _update_player_vars() -> void:
	for passive in $Passives.get_children():
		passive.apply_effects()
	_cap_current_vars()


func _update_ui_weapons() -> void:
	var selected_slot_initialized: = false
	for i in dict_weapons.keys():
		var weap = dict_weapons[i]
		var i_str: = i as String
		var hud_weap_sprite: = hud_weapon_slots.get_node("Slot" + i_str + "/WeaponSprite")
		var hud_weap_heat: = hud_weapon_slots.get_node("Slot" + i_str + "/SlotHeat")
		var inv_weap_sprite: = ui_loadout.get_node("WeaponSlots/Slot" + i_str + "/Sprite")
		var inv_swap_label: = ui_loadout.get_node("WeaponSlots/Slot" + i_str + "/SwapPromptLabel")
		inv_swap_label.hide()
		if weap == null: #wipe empty weapon slot
			hud_weap_sprite.texture = null
			inv_weap_sprite.texture = null
			hud_weap_heat.value = 0
		else:
			if selected_slot_initialized == false: #initialize first selected slot
				_change_slot_selected(i)
				selected_slot_initialized = true
			var weap_sprite = weap.get_node("SlotIcon")
			hud_weap_sprite.texture = weap_sprite.texture
			hud_weap_sprite.transform = weap_sprite.transform
			hud_weap_sprite.offset = weap_sprite.offset
			inv_weap_sprite.texture = weap_sprite.texture
			inv_weap_sprite.scale = weap_sprite.scale
			inv_weap_sprite.rotation = weap_sprite.rotation
			inv_weap_sprite.offset = weap_sprite.offset
			hud_weap_heat.max_value = weap.heat_capacity


func _update_ui_passives() -> void:
	for i in dict_passives.keys():
		var passive = dict_passives[i]
		var i_str: = i as String
		var inv_passive_sprite: = ui_loadout.get_node("PassiveSlots/Slot" + i_str + "/Sprite")
		var inv_swap_label: = ui_loadout.get_node("PassiveSlots/Slot" + i_str + "/SwapPromptLabel")
		inv_swap_label.hide()
		if passive == null: #wipe empty passive slot
			inv_passive_sprite.texture = null
		else:
			var passive_sprite_tex = passive.get_node("Sprite").texture
			inv_passive_sprite.texture = passive_sprite_tex
			inv_passive_sprite.show()


func _update_ui_items() -> void:
	for i in dict_items.keys():
		var item = dict_items[i]
		var i_str: = i as String
		var inv_item_sprite: = ui_all_items.get_node("ItemSlots/Slot" + i_str + "/Sprite")
		var inv_swap_label: = ui_all_items.get_node("ItemSlots/Slot" + i_str + "/SwapPromptLabel")
		inv_swap_label.hide()
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
	var weap = dict_weapons[slot_num]
	if weap == null:
		return
	var selected_slot_pos = hud_weapon_slots.get_node("Slot" + slot_num as String + "/SelectPos")
	var slot_selected = hud_weapon_slots.get_node("SlotSelected")
	slot_selected.position.x = selected_slot_pos.get_parent().position.x + selected_slot_pos.position.x
	change_weapon(slot_num)


func _control(delta):
	current_weapon.look_at(get_global_mouse_position())
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
	
	_update_bar_weapon_heat()
	
	_update_weapon_hud_elements()
	
	_control_player_weapon_hotkeys()
	
	_control_camera()
	
	#inventory
	if Input.is_action_just_pressed("ui_inventory") && item_held == null:
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
		change_weapon(slot_num)
		_change_slot_selected(slot_num)
		#update heat bar
		bar_weapon_heat.max_value = current_weapon.heat_capacity
		bar_weapon_heat.value = 0


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


var item_held: Node = null
var slot_held: int = -1
var class_weapon = preload("res://scenes/weapons/_base/_BaseWeapon.gd")
var class_passive = preload("res://scenes/passives/_base/_BasePassive.gd")


func _on_ItemSlot_pressed(slot_name: String) -> void:
	print("item slot pressed")


func _on_TrashSlot_pressed() -> void:
	print("trash slot pressed")


func _on_WeaponSlot_pressed(slot_name: String) -> void:
	_set_weapon_access(_get_slot_num(slot_name))


func _on_PassiveSlot_pressed(slot_name: String) -> void:
	_set_passive_access(_get_slot_num(slot_name))


func _get_slot_num(slot_name: String) -> int:
	var slot_num_pattern = RegEx.new()
	slot_num_pattern.compile("\\d$")
	return slot_num_pattern.search(slot_name).get_string() as int


func _set_weapon_access(slot_num: int) -> void:
	var node: = ui_loadout.get_node("WeaponSlots/Slot" + slot_num as String)
	var weap_sprite: = node.get_node("Sprite")
	var swap_label: = node.get_node("SwapPromptLabel")
	_manage_loadout(weap_sprite, swap_label, slot_num, "weap")


func _set_passive_access(slot_num: int) -> void:
	var node: = ui_loadout.get_node("PassiveSlots/Slot" + slot_num as String)
	var passive_sprite: = node.get_node("Sprite")
	var swap_label: = node.get_node("SwapPromptLabel")
	_manage_loadout(passive_sprite, swap_label, slot_num, "passive")


func _manage_loadout(sprite: Sprite, swap_label: Label, slot_num: int, item_slot: String) -> void:
	if sprite.texture == null && item_held == null: #if first slot selected is empty
		return
	elif sprite.texture != null && item_held == null: #if first slot selected is not empty
		if item_slot == "weap":
			slot_held = slot_num
			item_held = dict_weapons[slot_num]
		elif item_slot == "passive":
			slot_held = slot_num
			item_held = dict_passives[slot_num]
		swap_label.show()
	elif swap_label.visible == true && item_held != null: #second slot selected is same as first
		item_held = null
		slot_held = -1
		swap_label.hide()
	elif swap_label.visible == false && item_held != null: #second slot selected, begin swapping
		if item_held is class_weapon && item_slot == "weap":
			dict_weapons[slot_held] = dict_weapons[slot_num]
			dict_weapons[slot_num] = item_held
			_update_ui_weapons()
			item_held = null
			slot_held = -1
		elif item_held is class_passive && item_slot == "passive":
			dict_passives[slot_held] = dict_passives[slot_num]
			dict_passives[slot_num] = item_held
			_update_ui_passives()
			item_held = null
			slot_held = -1
