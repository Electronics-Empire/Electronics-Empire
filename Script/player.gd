extends Node

var unit_list = Array()
var lg401_module
var id

func _ready():
	id = get_tree().get_network_unique_id()
	pass

func generate_lg401(init_pos_vector):
	var module = load("res://Scene/LG401_module.tscn").instance()
	self.add_child(module)
	
	module.set_position(init_pos_vector)
	self.lg401_module = module
	pass

sync func send_line(text):
	lg401_module.__send_line__(text)

remote func ask_player_sync():
	rpc("player_sync")
	pass

remote func player_sync():
	self.lg401_module = load("res://Scene/LG401_module.tscn").instance()
	add_child(self.lg401_module)
	self.lg401_module.rpc_id(1,"__ask_entity_sync__")
	pass


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
