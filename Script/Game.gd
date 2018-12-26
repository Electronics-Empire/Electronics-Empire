extends Node

var execute_button
var world
var globals
var alert_dialog
var network_info
var focus_target_path

# generate all the objects, empty for now
func generate_object():
	pass

# generate the server player
func generate_host_player():
	var lg401_module = load("res://Scene/LG401_module.tscn").instance()
	lg401_module.own = get_tree().get_network_unique_id()
	self.add_child(lg401_module)
	
	var random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
	var random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
	lg401_module.set_position(Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2))
	
	while(self.world.get_cell((lg401_module.get_position().x/self.globals.tileSize.x), (lg401_module.get_position().y/self.globals.tileSize.y)) == self.world.water
		  || self.world.get_cell((lg401_module.get_position().x/self.globals.tileSize.x), (lg401_module.get_position().y/self.globals.tileSize.y)) == self.world.border):
		random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
		random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
		lg401_module.set_position(Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2))
	
	lg401_module.set_name(lg401_module.get_path().get_name(lg401_module.get_path().get_name_count()-1))
	self.network_info.entity_list.append(lg401_module.get_path())
	self.focus_target_path = lg401_module.get_path()
	pass

# generate the client player
func generate_client_player():
	var lg401_module = load("res://Scene/LG401_module.tscn").instance()
	lg401_module.own = get_tree().get_rpc_sender_id()
	self.add_child(lg401_module)
	
	var random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
	var random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
	lg401_module.set_position(Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2))
	
	while(self.world.get_cell((lg401_module.get_position().x/self.globals.tileSize.x), (lg401_module.get_position().y/self.globals.tileSize.y)) == self.world.water
		  || self.world.get_cell((lg401_module.get_position().x/self.globals.tileSize.x), (lg401_module.get_position().y/self.globals.tileSize.y)) == self.world.border):
		random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
		random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
		lg401_module.set_position(Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2))
	
	lg401_module.set_name(lg401_module.get_path().get_name(lg401_module.get_path().get_name_count()-1))
	self.network_info.entity_list.append(lg401_module.get_path())
	rpc_id(get_tree().get_rpc_sender_id(), "__set_focus_target__", lg401_module.get_path())
	pass

# change the focus target when a new client player is created
remote func __set_focus_target__(path):
	self.focus_target_path = path

# pause all the player
sync func __pause_all__():
	self.alert_dialog.__show_dialog__("the game is synchronizing with the new player")
	get_tree().set_pause(true)
	pass

# the synchronization is complete, resume all the player
sync func __continue_all__():
	get_tree().set_pause(false)
	self.alert_dialog.__close_dialog__()
	pass
	

# ask the server to sync all the entities
remote func __ask_sync_entity__():
	for path in self.network_info.entity_list:
		rpc("__create_sync_entity__", path, get_node(path).entity_name)
		get_node(path).__ask_entity_sync__()
	rpc("__continue_all__")
	pass

# called when we create a new entities
remote func __client_create_entity__(name):
	match(name):
		"player":
			generate_client_player()

# create a new server entity if the path dosen't exist
remote func __create_sync_entity__(path, name):
	if !has_node(path):
		match(name):
			"LG401":
				var lg401_module = load("res://Scene/LG401_module.tscn").instance()
				lg401_module.set_name(path.get_name(path.get_name_count()-1))
				self.add_child(lg401_module)
	pass

# call in Multiplayer.gd, generate the world
func __generate_world__():
	self.world.__generate_world__()
	pass

# signal in WorldGen.gd, when the world generation is finish we generate all
# the remaining components
func __generation_finished__():
	randomize()
	generate_host_player()
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
	rpc_id(1,"__client_create_entity__", "player")
	self.world.rpc_id(1,"__ask_sync_world__")
	rpc_id(1,"__ask_sync_entity__")
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