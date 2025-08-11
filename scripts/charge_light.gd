extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group('player'):
		body.flashlight.charge = 100
		body.flashlight.timer.start()
		body.flashlight.light_energy = 1
		body.flashlight.start_fading = false
