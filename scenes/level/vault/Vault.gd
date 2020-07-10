extends "res://scenes/level/_base/_BaseAccess.gd"


func _on_Access_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		_access(body, Global.arr_vault, "vault", Global.arr_vault.size())
		body.ui_vault.visible = true


func _on_Access_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		_exit_access(body)
		body.ui_vault.visible = false
