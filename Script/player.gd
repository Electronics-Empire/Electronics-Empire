extends Node

var unit_list = Array()
var ressource_dict = Dictionary()
var lg401_module
var id
var unit_id_iterator = 0

onready var br100_module_scene = load("res://Scene/BR100_module.tscn")

signal add_ressource_signal
signal dead_signal

func _ready():
	pass

func generate_lg401(init_pos_vector):
	var module = load("res://Scene/LG401_module.tscn").instance()
	self.add_child(module)
	
	module.connect("dead_signal", self, "player_die")
	module.connect("add_ressource_signal", self, "add_ressource")
	module.connect("build_signal", self, "load_code")
	
	module.set_position(init_pos_vector)
	self.lg401_module = module
	pass

func player_die():
	emit_signal("dead_signal", self.id)
	pass

sync func send_line(text):
	lg401_module.send_line(text)
	pass

remote func ask_player_sync():
	rpc("player_sync", self.id)
	pass

remote func player_sync():
	if(!has_node("LG401_module")):
		self.lg401_module = load("res://Scene/LG401_module.tscn").instance()
		
		lg401_module.connect("add_ressource_signal", self, "add_ressource")
		lg401_module.connect("dead_signal", self, "player_die")
		lg401_module.connect("build_signal", self, "load_code")
		
		add_child(self.lg401_module)
		self.lg401_module.rpc_id(1,"__ask_entity_sync__")
	pass

func add_ressource(ressource, num):
	if(ressource_dict.has(ressource)):
		ressource_dict[ressource] += num
	else:
		ressource_dict[ressource] = num
	
	if(id == get_tree().get_network_unique_id()):
		emit_signal("add_ressource_signal", ressource, ressource_dict[ressource])
	pass

func load_code(file_path, unit_type, init_position):
	if(self.id == get_tree().get_network_unique_id()):
		var file = File.new()
		if(file.open("game_script/" + file_path, file.READ) == OK):
			var code_array = Array()
			while(!file.eof_reached()):
				code_array.append(file.get_line())
			rpc("create_unit", code_array, unit_type, init_position)
			pass

sync func create_unit(code_array, unit_type, init_position):
	var unit
	match(unit_type):
		"BR100":
			unit = br100_module_scene.instance()
	
	unit.code = code_array
	add_child(unit)
	unit.set_position(init_position)
	
	unit.id = unit_id_iterator
	unit_list.insert(unit_id_iterator, unit.get_path())
	unit_id_iterator += 1
	
	unit.send_line()
		
	pass



#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
