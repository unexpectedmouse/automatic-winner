extends CharacterBody3D
class_name Player

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var kvas_pos: Marker3D = $KvasPos
@onready var camera: Camera3D = $Camera3D
@onready var kvas: Node3D = $Camera3D/Node3D/Kvas
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight
@onready var omnilight: OmniLight3D = $OmniLight3D
@onready var target: Node3D = get_tree().root.get_node("World")
@onready var id_label: Label3D = $Label3D
@onready var eye: MeshInstance3D = $eye
@onready var eye_2: MeshInstance3D = $eye2


const weapon = preload("res://scenes/kvas.tscn")
const speed = 4
const jump_strength = 5.0
const throw_force = 10.0
const discharge_speed = 1

var got_kvas := false
var flashlight_charge := 100.0
@export var health := 100


func hit(damage: int):
	if not is_multiplayer_authority(): return
	health -= damage
	if health <= 0:
		dead.rpc()
@rpc('any_peer')
func dead():
	queue_free()

@rpc("any_peer")
func set_pos(pos: Vector3):
	global_position = pos


@rpc("any_peer")
func set_group(group: String):
	add_to_group(group)
	id_label.text = group
	if group == 'hunter':
		get_kvas()
	else:
		kvas.queue_free()
		animator.queue_free()
		got_kvas = false


func _enter_tree() -> void:
	set_multiplayer_authority(int(name))


func _ready() -> void:
	if not is_multiplayer_authority(): return
	eye.hide()
	eye_2.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
	#min_dist = G.players_position[name]

var poses = []
var min_dist = null

func get_nearest_player():
	var nearest:CharacterBody3D = null
	var min_dist = null
	
	for player:CharacterBody3D in get_tree().get_nodes_in_group('kvasoman'):
		if player != self:
			var dist_to_player = global_position.distance_to(player.global_position)
			if min_dist == null or dist_to_player<min_dist:
				min_dist = dist_to_player
				nearest = player
	return nearest

func _physics_process(delta: float) -> void:
	id_label.text = str(health)
	omnilight.light_energy = 1 - flashlight.light_energy
	
	rotate_eyes_to(get_nearest_player())
	if not is_multiplayer_authority(): return
	
	if flashlight_charge > 0:
		flashlight_charge = move_toward(flashlight_charge, 0, discharge_speed * delta)
	else:
		flashlight.light_energy = move_toward(flashlight.light_energy, 0, 0.05)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_strength

	var input := Input.get_vector("left", "right", "go", "back")
	if input:
		var move := (transform.basis * Vector3(input.x, 0, input.y)).normalized() * speed
		if is_on_floor():
			velocity.x = move.x
			velocity.z = move.z
		else:
			velocity.x = move_toward(velocity.x, move.x, speed * 0.025)
			velocity.z = move_toward(velocity.z, move.z, speed * 0.025)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		else:
			velocity.x = move_toward(velocity.x, 0, speed * 0.01)
			velocity.z = move_toward(velocity.z, 0, speed * 0.01)
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * 0.005)
		camera.rotate_x(-event.relative.y * 0.005)
	elif event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseButton:
		if event.is_action_pressed("throw"):
			if not got_kvas: return
			animator.play("shake")
			shake_kvas_anim.rpc()
		elif event.is_action_released("throw"):
			if not got_kvas: return
			animator.play("throw")
			throw_kvas_rpc.rpc()


func get_kvas():
	if not is_multiplayer_authority(): return
	got_kvas = true
	animator.play("take")
	kvas.show()
	get_kvas_anim.rpc()


@rpc
func get_kvas_anim():
	animator.play("take")
	kvas.show()


@rpc
func shake_kvas_anim():
	animator.play("shake")


@rpc
func throw_kvas_rpc():
	animator.play("throw")


func throw_kvas():
	kvas.hide()
	var new_kvas: RigidBody3D = weapon.instantiate()
	target.add_child(new_kvas)
	new_kvas.global_position = kvas_pos.global_position
	new_kvas.global_rotation = camera.global_rotation
	new_kvas.linear_velocity = -camera.global_transform.basis.z.normalized() * throw_force

	if not is_multiplayer_authority(): return
	got_kvas = false


func recharge_flashlight():
	if not is_multiplayer_authority(): return
	
	flashlight_charge = 100
	flashlight.light_energy = 1


func rotate_eyes_to(player:CharacterBody3D):
	#if not is_multiplayer_authority(): return
	if player != null:
		var pos = player.global_position
		
		#eye.global_rotation.abs()
		#eye.transform = lerp(eye.transform, eye.transform.looking_at(Vector3(pos.x, pos.y + 1.477, pos.z),Vector3.UP, true), 0.1)
		#eye_2.transform = eye.transform
		##eye_2.transform = lerp(eye_2.transform, eye_2.transform.looking_at(Vector3(pos.x, pos.y + 1.477, pos.z)), 0.1)
		#
		##player.transform.looking_at()
		eye.look_at(Vector3(pos.x, pos.y + 1.477, pos.z))
		eye.rotation.x = clamp(eye.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		eye.rotation.y = clamp(eye.rotation.y, deg_to_rad(-90), deg_to_rad(90))
		eye.rotation.z = clamp(eye.rotation.z, deg_to_rad(-90), deg_to_rad(90))
		eye_2.global_rotation = eye.global_rotation
		
