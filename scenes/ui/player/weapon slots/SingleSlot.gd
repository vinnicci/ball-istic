extends Node2D


var item: Node


func set_item(new_item) -> void:
	if has_node("SlotIcon") == true:
		remove_child($SlotIcon)
	if new_item == null:
		item = null
		$SlotHeat.value = 0
	else:
		item = new_item
		#icon setup
		var icon = item.get_node("SlotIcon").duplicate()
		icon.visible = true
		icon.position = Vector2(35, 35)
		add_child(icon)
		#heat setup
		$SlotHeat.max_value = item.get_heat_cap()
		$SlotHeat.value = item.current_heat


func _process(delta: float) -> void:
	if item == null:
		return
	if item.is_overheating() == true:
		$SlotHeat.modulate = Global.CLASS_PLAYER.WEAP_OVERHEAT_COLOR
	else:
		$SlotHeat.modulate = Global.CLASS_PLAYER.WEAP_HEAT_COLOR
	$SlotHeat.value = item.current_heat
