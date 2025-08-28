extends Node3D


@export_category("Tasks")
@export var tasks_scenes: Array[PackedScene] = []
@export var random_positions: Array[Node3D] = []

@onready var players_node: Node3D = $players
@onready var positions: Node3D = $positions
@onready var ready_label: Label = $ReadyPlayers

var players_ready := 0
var is_ready := false
var tasks: Array[Node3D] = []

var tasks_checking:Dictionary = {
	1: false,
	2: false,
	3: false,
	4: false,
}

var all_completed = false

var loop:int = 0
var loop_max = 5

var current_task = 0
var max_tasks

func update_ready() -> void:
	ready_label.text = 'нажмите ENTER, чтобы раскваситься ' + str(players_ready) + "/" + str(players_node.get_child_count())
	if players_ready == players_node.get_child_count():
		ready_label.hide()
	if multiplayer.is_server() and players_ready == players_node.get_child_count():
		set_player_role()
		set_player_to_pos()
	if players_ready == players_node.get_child_count():
		change_loop()

func update_players_alive() -> void:
	if multiplayer.is_server():
		for player:CharacterBody3D in players_node.get_children():
			if player.is_in_group('player'):
				G.players_alive += 1
	$Label.text = str(G.players_alive)

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


func change_loop():
	update_players_alive()
	if loop == (loop_max):
		print('players won')
	else:
		loop += 1
		current_task += 1
		completed = false
		if multiplayer.is_server():
			select_task()
	print('loop: ', loop, '\n', 'current_task: ', current_task)


func won(players:bool):
	var won_table = preload("res://scenes/win_table.tscn")
	var won_table_inst = won_table.instantiate()
	add_child(won_table_inst)
	won_table_inst.win(players)

func _ready() -> void:
	ready_label.text = 'нажмите ENTER, чтобы раскваситься'


func set_player_role():
	var hunter_id = randi_range(0, players_ready-1)
	for player: CharacterBody3D in players_node.get_children():
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
	var id = randi_range(0,positions.get_child_count()-1)
	return id


var completed = false
@rpc("any_peer")
func task_completed(task_name:String, destroy:bool):
	if not completed:
		tasks_checking[current_task] = true
		var t_c = preload("res://scenes/task_completed.tscn")
		var t_in = t_c.instantiate()
		add_child(t_in)
		completed = true
		if multiplayer.is_server():
			change_loop()


func select_task():
	place_task.rpc(randi_range(0, tasks_scenes.size()) - 1, random_positions.pick_random().global_transform)


@rpc("any_peer", "call_local")
func place_task(index: int, _position: Transform3D):
	var task: Node3D = tasks_scenes[index].instantiate()
	add_child(task)
	tasks.append(task)
	task.completed.connect(func(destroy):
		task_completed.rpc(task.name,destroy))
	task.global_transform = _position
