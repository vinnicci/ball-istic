extends "res://scenes/global/items/_base/_BaseItem.gd"


var loot_table: Dictionary


func set_level(new_lvl: Node) -> void:
	_replace_item(new_lvl)


func _replace_item(new_lvl) -> void:
	var total_wgt: int
	for weight in loot_table.keys():
		total_wgt += weight
	var loot_w: int = rand_range(0, total_wgt)
	while(loot_table.keys().min() <= loot_w && loot_table.size() > 1):
		loot_table.erase(loot_table.keys().min())
	loot_table[loot_table.keys().min()].shuffle()
	var item: Node = loot_table[loot_table.keys().min()].front().instance()
	if item is Global.CLASS_ITEM == false:
		push_error("Object in the loot table is not an item class.")
		return
	get_parent().add_child_below_node(self, item)
	item.set_level(new_lvl)
	queue_free()
