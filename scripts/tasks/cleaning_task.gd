extends Node3D
signal completed(delete:bool)

var cleaned = 0
var max_cleaned = null



var objects = []


func _ready() -> void:
	objects = get_children()
	max_cleaned = get_child_count()
	G.clicked.connect(handle_click)

@rpc('any_peer', "call_local")
func hide_obj(_name:String):
	get_node(_name).hide()

@rpc("any_peer", "call_local")
func task_completed():
	completed.emit(true)
	
func handle_click(object:Node3D):
	if object.is_in_group("mug"):
		#var i = obj
		hide_obj.rpc(object.name)
		cleaned += 1
		if cleaned == max_cleaned:
			task_completed.rpc()
		
