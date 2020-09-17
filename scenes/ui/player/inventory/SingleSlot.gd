extends TextureButton


export var from_slot: String

var item: Node
var held: Node


func set_item(new_item) -> void:
	if has_node("SlotIcon") == true:
		remove_child($SlotIcon)
	if new_item == null:
		item = null
	else:
		item = new_item
		var icon = item.get_node("SlotIcon").duplicate()
		icon.visible = true
		icon.position = Vector2(35, 35)
		add_child(icon)


func _display_item_info(disp: bool) -> void:
	var item_info = held.get_node("ItemInfo")
	item_info.visible = disp
	if disp == false:
		return
	var regex = RegEx.new()
	regex.compile("[A-Za-z]+")
	item_info.get_node("VBoxContainer/Name").text = regex.search(item.name).get_string()
	regex.compile("res://scenes/[\\w]+")
	var type = regex.search(item.filename).get_string()
	regex.compile("[\\w]+$")
	type = regex.search(type).get_string()
	type = "[" + type.to_upper().trim_suffix("S") + "]"
	item_info.get_node("VBoxContainer/Type").text = type
	item_info.get_node("Description").text = "This is a sample description text"


func _on_Slot_mouse_entered() -> void:
	$Highlight.visible = true
	if item != null:
		_display_item_info(true)
	else:
		_display_item_info(false)


func _on_Slot_mouse_exited() -> void:
	$Highlight.visible = false
	_display_item_info(false)


func _on_Slot_hide() -> void:
	emit_signal("mouse_exited")
