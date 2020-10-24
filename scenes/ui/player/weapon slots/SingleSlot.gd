extends Node2D


var item: Node


func set_item(new_item) -> void:
	if has_node("SlotIcon") == true:
		remove_child($SlotIcon)
	if is_instance_valid(new_item) == false:
		item = null
		$SlotHeat.value = 0
	else:
		item = new_item
		#icon setup
		var icon = item.get_node("SlotIcon").duplicate()
		icon.visible = true
		icon.position = Vector2(35, 35)
		add_child(icon)


func _process(_delta: float) -> void:
	if is_instance_valid(item) == false:
		$SlotHeat.value = 0
		return
	if item.is_overheating() == true:
		$SlotHeat.modulate = Global.CLASS_PLAYER.WEAP_OVERHEAT_COLOR
	else:
		$SlotHeat.modulate = Global.CLASS_PLAYER.WEAP_HEAT_COLOR
	$SlotHeat.max_value = item.current_heat_cap
	$SlotHeat.value = item.current_heat
