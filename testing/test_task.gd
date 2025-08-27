extends Node3D
signal completed


func _ready() -> void:
	G.clicked.connect(process_click)


func process_click(object: Node3D):
	if object.is_in_group("taskbox"):
		completed.emit()
		queue_free()
