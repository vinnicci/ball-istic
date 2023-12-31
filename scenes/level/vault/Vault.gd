extends "res://scenes/level/_base/_BaseAccess.gd"


var _level_node: Node


func _ready() -> void:
	_init_ui_node()


func set_level(new_level) -> void:
	_level_node = new_level
	for item in $Items.get_children():
		item.set_level(_level_node)


func _init_ui_node() -> void:
	for item in $Items.get_children():
		item.modulate.a = 0


func _on_Access_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		_access(body, "vault", $Items)
		body.ui_inventory.get_node("Vault").visible = true


func _on_Access_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		_exit_access(body)
		body.ui_inventory.get_node("Vault").visible = false
