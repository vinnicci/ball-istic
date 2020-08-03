extends Control


signal moved
const SAVE_DIR = "user://saves/"


func _ready() -> void:
	for i in range(5):
		var save_file = load(SAVE_DIR + "save_" + str(i) + ".tres")
		var button = get_node("Buttons/Slot" + str(i))
		if save_file.save_name == "":
			button.text = "EMPTY"
		else:
			button.text = save_file.save_name


func _on_Slot0_pressed() -> void:
	_activate_renaming(0)


func _on_Slot1_pressed() -> void:
	_activate_renaming(1)


func _on_Slot2_pressed() -> void:
	_activate_renaming(2)


func _on_Slot3_pressed() -> void:
	_activate_renaming(3)


func _on_Slot4_pressed() -> void:
	_activate_renaming(4)


var _current_slot: int
onready var _header_select_slot = $HeaderSelectSlot
onready var _header_name_slot = $HeaderNameSlot
onready var _line_edit = $Buttons/LineEdit


func _activate_renaming(slot_num: int) -> void:
	_current_slot = slot_num
	_toggle_buttons(true)
	var button = get_node("Buttons/Slot" + str(slot_num))
	button.visible = false
	_header_select_slot.visible = false
	_header_name_slot.visible = true
	_line_edit.text = ""
	_line_edit.visible = true
	_line_edit.rect_position = get_node("Buttons/Slot" + str(slot_num)).rect_position


func _on_Back_pressed() -> void:
	emit_signal("moved", "MainMenu")


var _slot_name: String


func _on_LineEdit_text_entered(new_text: String) -> void:
	if new_text.length() == 0:
		return
	_slot_name = new_text
	$Buttons.visible = false
	$Back.visible = false
	$Confirm.visible = true
	var confirm_name = $Confirm/ConfirmLabel
	_header_name_slot.text = "NEW GAME - " + _slot_name
	confirm_name.text = "If this slot is an existing save file, it will be overwritten. Confirm?"


func _on_Ok_pressed() -> void:
	var line_edit = $Buttons/LineEdit
	line_edit.emit_signal("text_entered", line_edit.text)


func _enter_name() -> void:
	pass


func _on_ConfirmYes_pressed() -> void:
	var new_save = Global.CLASS_SAVE.new()
	new_save.save_name = _slot_name
	var save_path: String = SAVE_DIR + "save_" + str(_current_slot) + ".tres"
	ResourceSaver.save(save_path, new_save)
	emit_signal("moved", "Play", _current_slot, _slot_name)


func _on_Cancel_pressed() -> void:
	_cancel()


func _on_ConfirmNo_pressed() -> void:
	_cancel()


func _cancel() -> void:
	_line_edit.visible = false
	_header_name_slot.text = "NEW GAME - ENTER NAME"
	_header_name_slot.visible = false
	$Confirm.visible = false
	get_node("Buttons/Slot" + str(_current_slot)).visible = true
	_header_select_slot.visible = true
	$Buttons.visible = true
	$Back.visible = true
	_toggle_buttons(false)


func _toggle_buttons(disabled: bool) -> void:
	for button in $Buttons.get_children():
		if button is Button:
			button.disabled = disabled
	$Back.disabled = disabled
