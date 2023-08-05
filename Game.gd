extends Node3D

@onready var main_gui = $UI/MainScreen
@onready var waiting_room_gui = $UI/WaitingRoom
@onready var waiting_room_list = $UI/WaitingRoom/CenterContainer/GridContainer/VBoxContainer/ItemList
@onready var ready_btn = $UI/WaitingRoom/CenterContainer/GridContainer/VBoxContainer2/ReadyButton


# Called when the node enters the scene tree for the first time.
func _ready():
	# Preconfigure game
	main_gui.show()
	waiting_room_gui.hide()
	if not multiplayer.is_server():
		ready_btn.hide()
	
	
	Lobby.player_loaded.rpc_id(1)
	Lobby.player_connected.connect(refresh_waiting_list.unbind(2))
	Lobby.player_disconnected.connect(refresh_waiting_list.unbind(1))


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


func _on_ready_button_pressed():
	if multiplayer.is_server():
		rpc("start_game")

@rpc("call_local", "authority")
func start_game():
	# Hide the UI and unpause to start the game.
	$UI.hide()
	get_tree().paused = false
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://scenes/levels/test_map_1.tscn"))

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate(), true)



func refresh_waiting_list():
	waiting_room_list.clear()
	for player_id in Lobby.players:
		waiting_room_list.add_item(Lobby.players[player_id]["name"], null, false)









