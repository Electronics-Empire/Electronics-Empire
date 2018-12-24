extends Node

var object_pos = Array()

var lg401_module

var execute_button
var world
var globals

func generate_object():
	pass

func generate_player():
	call_deferred("add_child", self.lg401_module)
	
	var random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
	var random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
	self.lg401_module.set_position(Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2))
	
	while(self.world.get_cell((self.lg401_module.get_position().x/self.globals.tileSize.x), (self.lg401_module.get_position().y/self.globals.tileSize.y)) == self.world.water
		  || self.world.get_cell((self.lg401_module.get_position().x/self.globals.tileSize.x), (self.lg401_module.get_position().y/self.globals.tileSize.y)) == self.world.border):
		random_x_location = (randi()%int(self.world.get_used_rect().size.x-1))*self.globals.tileSize.x
		random_y_location = (randi()%int(self.world.get_used_rect().size.y-1))*self.globals.tileSize.y
		self.lg401_module.set_position(Vector2(random_x_location + self.globals.tileSize.x/2, random_y_location + self.globals.tileSize.y/2))
		self.object_pos.append(Vector2(random_x_location/self.globals.tileSize.x, random_y_location/self.globals.tileSize.y))
	pass

sync func __sync_game__():
	world.rpc_id(1,"__ask_sync_world__")
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
	self.lg401_module.__send_line__(text)
	pass

func __new_peer__(id):
	print("network working!")
	pass

func __peer_left__(id):
	pass

func __player_connection__():
	get_tree().set_pause(true)
	__sync_game__()
	get_tree().set_pause(false)
	pass

func __player_connection_failed__():
	pass

func __server_disconnected__():
	pass

func _ready():
	
	self.execute_button = get_node("Camera2D/GUI/GUI_execute_button")
	lg401_module = load("res://Scene/LG401_module.tscn").instance()
	self.world = get_node("World")
	self.globals = get_node("/root/globals")
	
	self.execute_button.connect("button_pressed_signal", self, "__execute_button__")
	self.world.connect("Generation_finished_signal", self, "__generation_finished__")
	get_tree().connect("network_peer_connected", self, "__new_peer__")
	get_tree().connect("network_peer_disconnected", self, "__peer_left__")
	get_tree().connect("connected_to_server", self, "__player_connection__")
	get_tree().connect("connection_failed", self, "__player_connection_failed__")
	get_tree().connect("server_disconnected", self, "__server_disconnected__")
	
	pass