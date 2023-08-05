extends Node3D

@onready var total_alive : int
@onready var good_alive : int
@onready var evil_alive : int
@onready var player_list : Player

func _ready():
	#only call on server
	if not multiplayer.is_server(): return

	#despawn connected players
	#Lobby.player_disconnected.connect(delete_player)

	#spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)
	
	#spawn local player (server's player) if this is not a dedicated server
	if not OS.has_feature("dedicated_server"):
		add_player(1)

#clean up connections after level closes
func _exit_tree():
	if not multiplayer.is_server(): return
	#multiplayer.peer_connected.disconnect(delete_player)



func add_player(peer_id: int):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	# Set player id
	character.name = str(peer_id)
	$Players.add_child(character, true)

#might need fix
#func delete_player(id:int):
#	if not $Players.has_node(str(id)):
#		return
#	$Players.get_node(str(id)).queue_free()
