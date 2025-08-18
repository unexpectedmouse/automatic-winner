extends RigidBody3D
@onready var liquid: GPUParticles3D = $liquid


func _on_body_entered(body: Node) -> void:
	if body.is_in_group('player'):
		$gun.hide()
		liquid.emitting = true
		await liquid.finished
		queue_free()
