extends "res://scenes/levels/_base/_BaseAccess.gd"


var arr_items: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]
var player = preload("res://scenes/bots/player/Player.gd")
var locked_down: bool = false


func _ready() -> void:
	_init_ui_node()


func _init_ui_node() -> void:
	var i: = 0
	for item in $Items.get_children():
		arr_items[i] = item
		item.hide()
		i += 1
		if i == 15:
			break


func _on_Area2D_body_entered(body: Node) -> void:
	if body is player:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$Sprite/Anim.stop()
		$Sprite.modulate.a = 1.0
		body.ui_access = "VAULT"
		body.ui_loadout_access_button.text = "<VAULT>"
		body.ui_loadout_access_button.disabled = false
		body.ui_loadout.visible = false
		body.ui_vault.visible = true
		body.arr_access_items = arr_items
		for i in range(15):
			body.update_ui_vault(i)


func _on_Area2D_body_exited(body: Node) -> void:
	if body is player:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$Sprite/Anim.play("fading")
		body.ui_access = ""
		body.ui_loadout_access_button.text = ""
		body.ui_loadout_access_button.disabled = true
		body.ui_loadout.visible = true
		body.ui_vault.visible = false
		body.arr_access_items = []
