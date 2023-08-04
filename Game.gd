extends Node3D

@onready var main_gui = $CanvasLayer/MainScreen
@onready var waiting_room_gui = $CanvasLayer/WaitingRoom

@onready var waiting_room_list = $CanvasLayer/WaitingRoom/CenterContainer/GridContainer/VBoxContainer/ItemList



# Called when the node enters the scene tree for the first time.
func _ready():
	# Preconfigure game
	main_gui.show()
	waiting_room_gui.hide()
	Lobby.player_loaded.rpc_id(1)
	Lobby.player_connected.connect(refresh_waiting_list.unbind(2))
	Lobby.player_disconnected.connect(refresh_waiting_list.unbind(1))

#Called by server when all peers are connected and ready to receive RPCs
func start_game():
	pass


func _on_join_button_pressed():
	Lobby.join_game("localhost")
	switch_gui()


func _on_host_button_pressed():
	Lobby.create_game()
	switch_gui()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_username_text_changed(new_text):
	#changes player info
	Lobby.player_info["name"] = new_text

func switch_gui():
	if main_gui.visible:
		main_gui.hide()
		waiting_room_gui.show()
	elif !main_gui.visible:
		main_gui.show()
		waiting_room_gui.hide()

##################
#WAITING ROOM GUI#
##################


func refresh_waiting_list():
	waiting_room_list.clear()
	for player_id in Lobby.players:
		waiting_room_list.add_item(Lobby.players[player_id]["name"], null, false)
	print("refreshed waiting list")

#func add_player_to_list(peer_id, player_info):
#	waiting_room_list.add_item(player_info["name"], null, true)
#
#
#func delete_player_from_list(peer_id):
#	var player_info = Lobby.players[peer_id]
#	waiting_room_list.(player_info["name"])




