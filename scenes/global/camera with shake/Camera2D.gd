extends Camera2D


var _amp: float
var _priority: int = 0
var _shaking: bool = false
onready var _shake_tween = $ShakeTween


#due to having the dynamic y-offset
#process loop is used instead of returning it to V(0,0) offset
func _process(delta: float) -> void:
	if get_parent() is Global.CLASS_PLAYER == false || _shaking == true:
		return
	var v_distance: float = 0.5
	var mouse_pos: float = (get_global_mouse_position().y - global_position.y) * v_distance
	offset.x = lerp(offset.x, 0, delta * 5.0)
	offset.y = lerp(offset.y, mouse_pos, delta * 1.0)
	offset.y = clamp(offset.y, -400, 400)


func shake_camera(amplitude: float, frequency: float, duration: float, priority: int = 0) -> void:
	if current == false || priority < _priority:
		return
	_amp = amplitude
	_priority = priority
	_shaking = true
	$Frequency.wait_time = frequency
	$Duration.wait_time = duration
	$Frequency.start()
	$Duration.start()
	_shake()


func _shake() -> void:
	var rand_x = rand_range(0, 1.0)
	if rand_x <= 0.5:
		rand_x = -_amp
	else:
		rand_x = _amp
	var rand_y = rand_range(0, 1.0)
	if rand_y <= 0.5:
		rand_y = -_amp
	else:
		rand_y = _amp
	var amp_vector: Vector2
	amp_vector = Vector2(rand_x, rand_y + offset.y)
	_shake_tween.interpolate_property(self, "offset", offset, amp_vector,
		$Frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	_shake_tween.start()


func _stop_shake() -> void:
	_priority = 0
	_shaking = false
	$Frequency.stop()


func _on_Frequency_timeout() -> void:
	_shake()


func _on_Duration_timeout() -> void:
	_stop_shake()
