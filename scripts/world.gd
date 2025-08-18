extends Node3D


var player = preload("res://scenes/player.tscn")

@onready var players_node: Node3D = $players
@onready var positions: Node3D = $positions
@onready var ready_label: Label = $ReadyPlayers

var players_ready := 0
var is_ready := false


func update_ready() -> void:
	ready_label.text = 'нажмите ENTER, чтобы расквасится ' + str(players_ready) + "/" + str(players_node.get_child_count())
	if players_ready == players_node.get_child_count():
		ready_label.hide()
	if multiplayer.get_unique_id() == 1 and players_ready == players_node.get_child_count():
		set_player_role()
		set_player_to_pos()
		


@rpc("any_peer")
func player_ready():
	players_ready += 1
	update_ready()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("ui_accept") and not is_ready:
		is_ready = true
		players_ready += 1
		update_ready()
		player_ready.rpc()

func _ready() -> void:
	ready_label.text = 'нажмите ENTER, чтобы раскваситься'


func set_player_role():
	var hunter_id = randi_range(0, players_ready-1)
	for player:CharacterBody3D in players_node.get_children():
		if players_node.get_child(hunter_id) == player:
			player.set_group.rpc("hunter")
			player.set_group('hunter')
		else:
			player.set_group.rpc("player")
			player.set_group('player')



func set_player_to_pos():
	var id_was = []
	for player: CharacterBody3D in players_node.get_children():
		if player.is_in_group('player'):
			var id = randomize_ids()
			if !id_was.has(id):
				if player.get_multiplayer_authority() == 1:
					player.global_position = positions.get_child(id).global_position
					continue
				player.set_pos.rpc(positions.get_child(id).global_position)
				positions.get_child(id).queue_free()
				id_was.append(id)


func randomize_ids():
	var id = randi_range(0,positions.get_child_count())
	return id
