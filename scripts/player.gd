extends CharacterBody3D

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var kvas_pos: Marker3D = $KvasPos
@onready var camera: Camera3D = $Camera3D
@onready var kvas: Node3D = $Kvas
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight
@onready var omnilight: OmniLight3D = $OmniLight3D
@onready var target: Node3D = get_tree().root.get_child(0)

const weapon = preload("res://scenes/kvas.tscn")
const speed = 4
const jump_strength = 5.0
const throw_force = 10.0
const discharge_speed = 10

var got_kvas := false
var flashlight_charge := 100.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_kvas()


func _physics_process(delta: float) -> void:
	omnilight.light_energy = 1 - flashlight.light_energy
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
		elif event.is_action_released("throw"):
			if not got_kvas: return
			animator.play("throw")


func get_kvas():
	got_kvas = true
	animator.play("take")
	kvas.show()


func throw_kvas():
	kvas.hide()
	var new_kvas: RigidBody3D = weapon.instantiate()
	target.add_child(new_kvas)
	new_kvas.global_position = kvas_pos.global_position
	new_kvas.global_rotation = camera.global_rotation
	new_kvas.linear_velocity = -camera.global_transform.basis.z.normalized() * throw_force
	got_kvas = false


func recharge_flashlight():
	flashlight_charge = 100
	flashlight.light_energy = 1
