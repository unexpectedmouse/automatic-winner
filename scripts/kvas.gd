extends RigidBody3D
@onready var liquid: GPUParticles3D = $liquid

const max_damage = 50
const explosion_radius = 3.0

@onready var space = get_world_3d().direct_space_state
var ray_query = PhysicsRayQueryParameters3D.new()


func _ready() -> void:
	$AnimationPlayer.play("boom")


func boom() -> void:
	$gun.hide()
	liquid.emitting = true
	
	for player: CharacterBody3D in get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(global_position) <= explosion_radius:
			ray_query.from = global_position
			ray_query.to = player.global_position
			
			var result = space.intersect_ray(ray_query)
			
			if result.collider.is_in_group("player"):
				player.hit(calculate_damage(result.collider))


func calculate_damage(target: CharacterBody3D) -> int:
	return max_damage * (global_position.distance_to(target.global_position) / explosion_radius)
