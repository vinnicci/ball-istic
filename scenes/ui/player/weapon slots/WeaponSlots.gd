extends Node2D


var _player = null


func set_player(player_node) -> void:
	_player = player_node
	update_weap_and_slot_selected()


func update_weap_and_slot_selected() -> void:
	var non_empty_slot_found: = false
	var slot_initialized: = false
	for slot_num in _player.arr_weapons.size():
		non_empty_slot_found = _player.update_ui_weapon_slot(slot_num)
		if non_empty_slot_found == true && slot_initialized == false: #initialize first selected slot
			change_slot_selected(slot_num)
			slot_initialized = true


func _process(delta: float) -> void:
	_update_weapon_hud()


func _update_weapon_hud() -> void:
	var arr_weap = _player.arr_weapons
	for i in arr_weap.size():
		if arr_weap[i] == null:
			continue
		var hud_weap_heat = get_node(i as String + "/SlotHeat")
		if arr_weap[i].is_overheating() == true:
			hud_weap_heat.modulate = _player.WEAP_OVERHEAT_COLOR
		else:
			hud_weap_heat.modulate = _player.WEAP_HEAT_COLOR
		hud_weap_heat.value = arr_weap[i].current_heat


func change_slot_selected(slot_num: int) -> void:
	if _player.change_weapon(slot_num) == false:
		return
	var selected_slot_pos = get_node(str(slot_num) + "/SelectPos")
	$SlotSelected.position.x = (selected_slot_pos.get_parent().position.x +
		selected_slot_pos.position.x)
	var player_weap = _player.current_weapon
	player_weap.look_at(get_global_mouse_position())
	_player.bar_weapon_heat.max_value = player_weap.heat_capacity
	_player.bar_weapon_heat.value = 0
