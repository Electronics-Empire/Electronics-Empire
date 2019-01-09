extends Node

var unit_list = Array()
var lg401_module
var id

signal dead_signal

func _ready():
	pass

func generate_lg401(init_pos_vector):
	var module = load("res://Scene/LG401_module.tscn").instance()
	self.add_child(module)
	
	module.connect("dead_signal", self, "player_die")
	
	module.set_position(init_pos_vector)
	self.lg401_module = module
	pass

func player_die():
	emit_signal("dead_signal", self.id)
	pass

sync func send_line(text):
	lg401_module.__send_line__(text)
	pass

remote func ask_player_sync():
	rpc("player_sync", self.id)
	pass

remote func player_sync(id):
	self.id = id
	
	if(!has_node("LG401_module")):
		self.lg401_module = load("res://Scene/LG401_module.tscn").instance()
		add_child(self.lg401_module)
		
		self.lg401_module.connect("dead_signal", self, "player_die")
		
		self.lg401_module.rpc_id(1,"__ask_entity_sync__")
	pass


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
