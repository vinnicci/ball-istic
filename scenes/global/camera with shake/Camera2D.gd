extends Camera2D


var _amp: float
var _priority: int = 0


func shake_camera(amplitude: float, frequency: float, duration: float, priority: int = 0) -> void:
	if current == false || priority < _priority:
		return
	_amp = amplitude
	_priority = priority
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
#	print("x: " + rand_x as String + " y: " + rand_y as String)
	var amp_vector: Vector2
	amp_vector = Vector2(rand_x, rand_y + offset.y)
	var shake_tween: = $ShakeTween
	shake_tween.interpolate_property(self, "offset", offset,
		amp_vector, $Frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	shake_tween.start()


func _stop_shake() -> void:
	_priority = 0
	var shake_tween: = $ShakeTween
	shake_tween.interpolate_property(self, "offset", offset, Vector2(0, offset.y),
		$Frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	shake_tween.start()
	$Frequency.stop()


func _on_Frequency_timeout() -> void:
	_shake()


func _on_Duration_timeout() -> void:
	_stop_shake()
