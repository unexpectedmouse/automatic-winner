extends Node3D
signal completed(destroy:bool)

@onready var card: Node3D = $light_card
@onready var switch: Node3D = $switch_for_lightning_card
@onready var switch_card: MeshInstance3D = $switch_for_lightning_card/card

var card_picked := false

func _ready() -> void:
	name = 'LightTask'
	G.clicked.connect(handle_click)
	switch_card.hide()


@rpc("any_peer", "call_local")
func pick_card():
	card.hide()


@rpc("any_peer", "call_local")
func put_card():
	switch_card.show()
	queue_free()
	completed.emit(true)



func handle_click(object: Node3D):
	if object.is_in_group("lightcard"):
		card_picked = true
		pick_card.rpc()
	elif object.is_in_group("lightcardswitch"):
		if card_picked:
			put_card.rpc()
			card_picked = false
