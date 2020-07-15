extends "res://scenes/level/_base/_BaseAccess.gd"


var _arr_items: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]
var _locked_down: bool = false
#signal saved
#signal loaded


func _ready() -> void:
	_init_ui_node()


func _init_ui_node() -> void:
	for i in $Items.get_children().size():
		var item = $Items.get_child(i)
		_arr_items[i] = item
#		if item.has_method("animate_transform"):
#			item.animate_transform(0, false)
#		else:
		item.modulate.a = 0


func _on_Access_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		_access(body, _arr_items, "depot", _arr_items.size())
		body.ui_depot.visible = true
#		emit_signal("loaded")


func _on_Access_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		_exit_access(body)
		body.ui_depot.visible = false
#		emit_signal("saved")
