extends Node2D


var _player = null


func set_player(player_node) -> void:
	_player = player_node
	init_slot_selected()


func init_slot_selected() -> void:
	update_heat_cap()
	for slot_num in _player.arr_weapons.size():
		if _player.change_weapon(slot_num) == true:
			change_slot_selected(slot_num)
			break


func change_slot_selected(slot_num: int) -> void:
	var selected_slot_pos = get_node(str(slot_num) + "/SelectPos")
	$SlotSelected.position.x = (selected_slot_pos.get_parent().position.x +
		selected_slot_pos.position.x)


func update_heat_cap() -> void:
	for i in range(5):
		get_node(str(i)).update_heat_cap()
