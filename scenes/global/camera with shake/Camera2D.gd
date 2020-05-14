extends Camera2D


var _amp: float
var _priority: int = 0


func shake_camera(amplitude: float, frequency: float, duration: float, priority: int = 0) -> void:
	_amp = amplitude
	_priority = priority
	if priority < _priority || amplitude < 1.0:
		return
	$Frequency.wait_time = frequency
	$Duration.wait_time = duration
	$Frequency.start()
	$Duration.start()
	_shake()


func _shake() -> void:
	var random_amp = Vector2(
		rand_range(-_amp, _amp),
		rand_range(-_amp, _amp) + offset.y)
	var shake_tween: = $ShakeTween
	shake_tween.interpolate_property(self, "offset", offset,
		random_amp, $Frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	shake_tween.start()


func _stop_shake() -> void:
	var shake_tween: = $ShakeTween
	shake_tween.interpolate_property(self, "offset", offset, Vector2(0, offset.y),
		$Frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	shake_tween.start()
	$Frequency.stop()
	_priority = 0


func _on_Frequency_timeout() -> void:
	_shake()


func _on_Duration_timeout() -> void:
	_stop_shake()
