extends "res://scenes/level/_base/_BaseAccess.gd"


var arr_items: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]
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
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$Sprite/Anim.stop()
		$Sprite.modulate.a = 1.0
		body.ui_access = "depot"
		body.ui_loadout_access_button.text = "<DEPOT>"
		body.ui_loadout_access_button.disabled = false
		body.ui_loadout.visible = false
		body.ui_depot.visible = true
		body.arr_access_items = arr_items
		for i in range(15):
			body.update_ui_slot(i, "depot")


func _on_Area2D_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$Sprite/Anim.play("fading")
		body.ui_access = ""
		body.ui_loadout_access_button.text = ""
		body.ui_loadout_access_button.disabled = true
		body.ui_loadout.visible = true
		body.ui_depot.visible = false
		body.arr_access_items = []
