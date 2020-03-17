extends State


func _ready() -> void:
	$BackOffTimer.wait_time = get_parent().get_parent().get_node("ChargeCooldown").wait_time

func on_enter(target) -> void:
	pass

func on_exit(target) -> void:
	pass

func on_input(target, event : InputEvent) -> void:
	pass

func on_process(target, delta : float) -> void:
	pass

func on_physics_process(target, delta : float) -> void:
	if is_instance_valid(target.target_bot) == false || target.is_backing_off == false:
		go_to("Chase")
	target.back_off(delta)
