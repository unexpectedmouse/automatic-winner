extends CharacterBody3D

@onready var camera: Camera3D = $Camera3D

const speed = 4
const jump_strength = 5.0

@onready var flashlight = $Camera3D/SpotLight3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
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
	elif event is InputEventKey and event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
