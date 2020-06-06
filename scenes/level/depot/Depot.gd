extends "res://scenes/level/_base/_BaseAccess.gd"


var _arr_items: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]
var _locked_down: bool = false


func _ready() -> void:
	_init_ui_node()


func _init_ui_node() -> void:
	for i in $Items.get_children().size():
		var item = $Items.get_child(i)
		_arr_items[i] = item
		item.modulate = Color(1,1,1,0)


func _on_Area2D_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		_access(body, _arr_items, "depot", _arr_items.size())
		body.ui_depot.visible = true


func _on_Area2D_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		_exit_access(body)
		body.ui_depot.visible = false
