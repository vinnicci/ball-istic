extends Control


signal moved
const SAVE_DIR: String = "user://saves/"


func _ready() -> void:
	for i in range(5):
		var save_file = load(SAVE_DIR + "save_" + str(i) + ".tres")
		var button = get_node("Buttons/VBoxContainer/Save" + str(i))
		if save_file.save_name == "":
			button.text = "EMPTY"
			button.disabled = true
		else:
			button.text = save_file.save_name


func _on_Save0_pressed() -> void:
	_load_save(0, $Buttons/VBoxContainer/Save0.text)


func _on_Save1_pressed() -> void:
	_load_save(1, $Buttons/VBoxContainer/Save1.text)


func _on_Save2_pressed() -> void:
	_load_save(2, $Buttons/VBoxContainer/Save2.text)


func _on_Save3_pressed() -> void:
	_load_save(3, $Buttons/VBoxContainer/Save3.text)


func _on_Save4_pressed() -> void:
	_load_save(4, $Buttons/VBoxContainer/Save4.text)


func _load_save(current_slot: int, slot_name: String) -> void:
	emit_signal("moved", "Play", current_slot, slot_name)


func _on_Back_pressed() -> void:
	emit_signal("moved", "MainMenu")
