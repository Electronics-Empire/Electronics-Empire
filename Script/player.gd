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

func __ask_player_sync__():
	rpc("__entity_sync__", self.lg401_module, self.id)
	pass

remote func __player_sync__(lg401_module, id):
	self.lg401_module = lg401_module
	self.id = id
	pass


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
