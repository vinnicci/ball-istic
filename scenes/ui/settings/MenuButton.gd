extends Button


var _key: String
var _menu: Node
var _config_file: ConfigFile


func set_key(key: String) -> void:
	_key = key


func set_menu(menu: Node) -> void:
	_menu = menu
	_config_file = _menu.config_file


func _input(event: InputEvent) -> void:
	if text != "Press a key...":
		return
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			#pressing escape means cancelling
			_rebind(_config_file.get_value("keybinds", _key))
		else:
			_rebind(event.scancode)
	if event is InputEventMouseButton:
		_rebind(event.button_index)


func _rebind(button_code: int) -> void:
	_config_file.set_value("keybinds", _key, button_code)
	_menu.replace_action(_key, _config_file.get_value("keybinds", _key))
	_menu.update_ui_key(_key)
	_menu.save_config()
	pressed = false
	
	
