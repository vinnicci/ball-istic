extends "res://scenes/passives/random/_base/RandomPassive.gd"


func set_level(new_lvl: Node) -> void:
	_passives_3.shuffle()
	var actual_passive = _passives_3.front().instance()
	var pos: int = get_index()
	get_parent().add_child_below_node(self, actual_passive)
	queue_free()
	.set_level(new_lvl)
