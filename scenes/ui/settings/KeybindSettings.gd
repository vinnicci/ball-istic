extends Control


onready var _keybinds: Dictionary = {
	"move_up": {
		"default": KEY_W,
		"button": $MoveUp/MenuButton
	},
	"move_down": {
		"default": KEY_S,
		"button": $MoveDown/MenuButton
	},
	"move_left": {
		"default": KEY_A,
		"button": $MoveLeft/MenuButton
	},
	"move_right": {
		"default": KEY_D,
		"button": $MoveRight/MenuButton
	},
	"change_mode": {
		"default": BUTTON_RIGHT,
		"button": $ChangeMode/MenuButton
	},
	"charge_roll": {
		"default": BUTTON_LEFT,
		"button": $ChargeRoll/MenuButton
	},
	"shoot": {
		"default": BUTTON_LEFT,
		"button": $FireWeapon/MenuButton
	},
	"discharge_parry": {
		"default": KEY_E,
		"button": $DischargeParry/MenuButton
	},
	"ui_inventory": {
		"default": KEY_TAB,
		"button": $InventoryUI/MenuButton
	},
	"weap_slot_0": {
		"default": KEY_1,
		"button": $WeapSlot0/MenuButton
	},
	"weap_slot_1": {
		"default": KEY_2,
		"button": $WeapSlot1/MenuButton
	},
	"weap_slot_2": {
		"default": KEY_3,
		"button": $WeapSlot2/MenuButton
	},
	"weap_slot_3": {
		"default": KEY_4,
		"button": $WeapSlot3/MenuButton
	},
	"weap_slot_4": {
		"default": KEY_5,
		"button": $WeapSlot4/MenuButton
	}
}
const CONFIG: String = "res://scenes/global/config/config.ini"
var config_file: ConfigFile = ConfigFile.new()


func _ready() -> void:
	_connect_buttons()
	_load_config()


func _connect_buttons() -> void:
	for key in _keybinds.keys():
		var button = _keybinds[key]["button"]
		button.connect("pressed", self, "_on_Button_pressed",
			[button])
		button.set_menu(self)
		button.set_key(key)
	$ResetDefault/MenuButton.connect("pressed", self, "_on_Button_pressed",
		[$ResetDefault/MenuButton])


func _load_config() -> void:
	if config_file.load(CONFIG) != OK:
		push_error("Config not found.")
		get_tree().quit()
	for key in config_file.get_section_keys("keybinds"):
		replace_action(key, config_file.get_value("keybinds", key))
		update_ui_key(key)


func update_ui_key(key: String) -> void:
	var button = _keybinds[key]["button"]
	var val = config_file.get_value("keybinds", key)
	if val == -1:
		button.text = "Unassigned"
	elif val <= 7:
		button.text = "Mouse" + str(val)
	else:
		button.text = OS.get_scancode_string(val)


func save_config() -> void:
	config_file.save(CONFIG)


func _reset_to_default() -> void:
	for key in _keybinds.keys():
		config_file.set_value("keybinds", key, _keybinds[key]["default"])
		replace_action(key, config_file.get_value("keybinds", key))
		update_ui_key(key)
	save_config()


func replace_action(key, button_code) -> void:
	var action_list = InputMap.get_action_list(key)
	if action_list.size() != 0:
		InputMap.action_erase_event(key, action_list[0])
	if button_code == -1:
		return
	elif button_code <= 7:
		var new_key: InputEventMouseButton = InputEventMouseButton.new()
		new_key.button_index = button_code
		InputMap.action_add_event(key, new_key)
	else:
		var new_key: InputEventKey = InputEventKey.new()
		new_key.scancode = button_code
		InputMap.action_add_event(key, new_key)


func _on_Button_pressed(button: Button) -> void:
	match button.get_parent().name:
		"ResetDefault": _reset_to_default()
		_:
			button.text = "Press a key..."
			button.pressed = true
