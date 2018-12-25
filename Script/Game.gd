extends Node

var execute_button
var world
var globals
var alert_dialog
var network_info
var focus_target

func generate_object():
	pass

func generate_player():
	var lg401_module = load("res://Scene/LG401_module.tscn").instance()
	lg401_module.own = get_tree().get_network_unique_id()
	self.focus_target = lg401_module
	self.add_child(lg401_module)
	
	var random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
	var random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
	lg401_module.set_position(Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2))
	
	while(self.world.get_cell((lg401_module.get_position().x/self.globals.tileSize.x), (lg401_module.get_position().y/self.globals.tileSize.y)) == self.world.water
		  || self.world.get_cell((lg401_module.get_position().x/self.globals.tileSize.x), (lg401_module.get_position().y/self.globals.tileSize.y)) == self.world.border):
		random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
		random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
		lg401_module.set_position(Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2))
	self.network_info.entity_list.append(lg401_module.get_path())
	pass

func sync_game():
	world.rpc_id(1,"__ask_sync_world__")
	rpc_id(1,"__ask_sync_entity__")
	pass

sync func __pause_all__():
	self.alert_dialog.__show_dialog__("the game is synchronizing with the new player")
	get_tree().set_pause(true)
	pass

sync func __continue_all__():
	get_tree().set_pause(false)
	self.alert_dialog.__close_dialog__()
	pass
	

remote func __ask_sync_entity__():
	for path in self.network_info.entity_list:
		rpc_id(get_tree().get_rpc_sender_id(), "__create_entity__", get_node(path).entity_name)
		get_node(path).__ask_entity_sync__()
	pass

remote func __create_entity__(name):
	match(name):
		"LG401":
			var lg401_module = load("res://Scene/LG401_module.tscn").instance()
			self.add_child(lg401_module)
	pass


# call in Multiplayer.gd
func __generate_world__():
	self.world.__generate_world__()
	pass

# signal in WorldGen.gd
func __generation_finished__():
	randomize()
	generate_player()
	generate_object()
	pass

func __execute_button__(text):
	self.focus_target.__send_line__(text)
	pass

func __new_peer__(id):
	print("network working!")
	pass

func __peer_left__(id):
	pass

func __player_connection__():
	rpc("__pause_all__")
	sync_game()
	rpc("__continue_all__")
	pass

func __player_connection_failed__():
	pass

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