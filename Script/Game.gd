extends Node

var execute_button
var world
var globals
var alert_dialog
var network_info

# generate all the objects, empty for now
func __generate_object__():
	pass

# generate the client player
sync func generate_player(id):
	var player = load("res://Script/player.gd").instance()
	add_child(player)
	var random_x_location
	var random_y_location
	var init_pos
	
	random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
	random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
	init_pos = Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2)
	
	while(self.world.get_cell((init_pos.x/self.globals.tileSize.x), (init_pos.y/self.globals.tileSize.y)) == self.world.water
		  || self.world.get_cell((init_pos.x/self.globals.tileSize.x), (init_pos.y/self.globals.tileSize.y)) == self.world.border):
		random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
		random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
		init_pos = Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2)
	
	player.generate_lg401(init_pos)
	player.set_name(id)
	self.network_info.player_list.append(id)
	pass

remote func ask_sync_player():
	for player in self.network_info.player_list:
		rpc("sync_player", player)
	pass

sync func sync_player(player):
	if(!has_node(player)):
		generate_player(player)
		get_node(player).ask_player_sync()

# pause all the player
sync func pause_all():
	self.alert_dialog.show_dialog("the game is synchronizing with the new player")
	get_tree().set_pause(true)
	pass

# call in Multiplayer.gd, generate the world
func __generate_world__():
	self.world.__generate_world__()
	pass

# signal in WorldGen.gd, when the world generation is finish we generate all
# the remaining components
func __generation_finished__():
	randomize()
	generate_player(get_tree().get_network_unique_id())
	generate_object()
	pass

# send a line when we click on the execute button
func __execute_button__(text):
	if(self.get_node(self.focus_target_path) != null):
		self.get_node(self.focus_target_path).rpc("__send_line__",text)
	pass

# function is call on the server and client when a new peer is connected
func __new_peer__(id):
	print("network working!")
	pass

# function is call on the server and client when a peer disconnected
func __peer_left__(id):
	pass

# function is call on the client when a new peer is connected
func __player_connection__():
	rpc("__pause_all__")
	rpc_id(1, "generate_player", get_tree().get_network_unique_id())
	self.world.rpc_id(1,"__ask_sync_world__")
	rpc_id(1,"__ask_sync_player__")
	pass

# function is call on the client when a peer failed to connect
func __player_connection_failed__():
	pass

# function is call on the client when the server disconnect
func __server_disconnected__():
	pass

func _ready():
	
	self.execute_button = get_node("Camera2D/GUI/GUI_execute_button")
	self.world = get_node("World")
	self.globals = get_node("/root/globals")
	self.network_info = get_node("/root/network_info")
	self.alert_dialog = get_node("Camera2D/GUI/AlertDialog")
	
	self.execute_button.connect("button_pressed_signal", self, "__execute_button__")
	self.world.connect("Generation_finished_signal", self, "__generation_finished__")
	get_tree().connect("network_peer_connected", self, "__new_peer__")
	get_tree().connect("network_peer_disconnected", self, "__peer_left__")
	get_tree().connect("connected_to_server", self, "__player_connection__")
	get_tree().connect("connection_failed", self, "__player_connection_failed__")
	get_tree().connect("server_disconnected", self, "__server_disconnected__")
	
	pass