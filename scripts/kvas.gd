extends RigidBody3D
@onready var liquid: GPUParticles3D = $liquid

var damage := 50
var hit := false


func _on_body_entered(body: Node) -> void:
	if hit: return
	hit = true
	if body.has_method("hit"):
		body.hit(damage)
	if body.is_in_group('player'):
		$gun.hide()
		liquid.emitting = true
		await liquid.finished
		queue_free()
