extends Node3D
signal completed(destroy:bool)

@onready var water_cooler: Node3D = $water_cooler
@onready var cup: Node3D = $cup
@onready var tea_pocket: Node3D = $tea_pocket
@onready var done: Node3D = $done

var cup_picked = false
var tea_pocket_picked = false


func _ready() -> void:
	name = 'teaTask'
	G.clicked.connect(handle_click)
	done.hide()


@rpc("any_peer", "call_local")
func pick_cup():
	cup.hide()
	cup_picked = true

@rpc("any_peer", "call_local")
func pick_tea_pocket():
	tea_pocket.hide()
	tea_pocket_picked = true

@rpc("any_peer", "call_local")
func put():
	done.show()
	queue_free()
	completed.emit(true)



func handle_click(object: Node3D):
	if object.is_in_group("cup"):
		pick_cup.rpc()
	elif object.is_in_group("tea_pocket"):
		pick_tea_pocket.rpc()
	elif object.is_in_group('water_cooler'):
		if cup_picked and tea_pocket_picked:
			put.rpc()
