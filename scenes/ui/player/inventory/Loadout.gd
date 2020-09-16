extends Control


var _player = null


func set_player(player_node) -> void:
	_player = player_node
	
	#connect buttons
#	for weap_slot in get_node("WeaponSlots").get_children():
#		weap_slot.connect("pressed", self, "_on_WeaponSlot_pressed", [weap_slot.name])
	
#	for passive_slot in get_node("PassiveSlots").get_children():
#		passive_slot.connect("pressed", self, "_on_PassiveSlot_pressed", [passive_slot.name])



func _on_WeaponSlot_pressed(slot_name: String) -> void:
#	_match_slot(slot_name as int, "weapon", arr_weapons)
	pass


func _on_PassiveSlot_pressed(slot_name: String) -> void:
#	_match_slot(slot_name as int, "passive", arr_passives)
	pass
