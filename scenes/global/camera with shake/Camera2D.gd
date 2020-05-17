extends Camera2D


var _amp: float
var _priority: int = 0


func shake_camera(amplitude: float, frequency: float, duration: float, priority: int = 0) -> void:
	_amp = amplitude
	if priority < _priority || amplitude < 1.0:
		return
	_priority = priority
	$Frequency.wait_time = frequency
	$Duration.wait_time = duration
	$Frequency.start()
	$Duration.start()
	_shake()


func _shake() -> void:
	var random: = rand_range(0, 1.0)
	var amp_vector: Vector2
	if random < 0.5:
		amp_vector = Vector2(-_amp, rand_range(-_amp, _amp) + offset.y)
	else:
		amp_vector = Vector2(_amp, rand_range(-_amp, _amp) + offset.y)
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
