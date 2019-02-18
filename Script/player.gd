extends Node

var unit_list = Dictionary()
var ressource_dict = Dictionary()
var lg401_module
var id
var unit_id_iterator = 0

onready var globals = get_node("/root/globals")
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
	module.owner_id = self.id
	
	ressource_dict = {"carbon" : 5}
	pass

func player_die():
	emit_signal("dead_signal", self.id)
	pass

sync func send_line(text):
	lg401_module.send_line(text)
	pass

remote func ask_player_sync():
	rpc("player_sync", self.id, self.unit_id_iterator, self.ressource_dict)
	
	for id in self.unit_list:
		var unit = get_node(unit_list[id])
		rpc("unit_sync", unit.id, unit.entity_name)
	pass

remote func unit_sync(id, entity_name):
	var unit
	if(!unit_list.has(id)):
		unit = __instance_by_name__(entity_name)
		unit.set_name(str(id))
		add_child(unit)
		self.unit_list[id] = unit.get_path()
		unit.rpc_id(1, "ask_entity_sync")
	pass

remote func player_sync(id, unit_id_iterator, ressource_dict):
	self.id = id
	self.unit_id_iterator = unit_id_iterator
	self.ressource_dict = ressource_dict
	if(!has_node("LG401_module")):
		self.lg401_module = load("res://Scene/LG401_module.tscn").instance()
		
		lg401_module.connect("add_ressource_signal", self, "add_ressource")
		lg401_module.connect("dead_signal", self, "player_die")
		lg401_module.connect("build_signal", self, "load_code")
		
		add_child(self.lg401_module)
		self.lg401_module.rpc_id(1,"ask_entity_sync")
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
			var code_array = PoolStringArray()
			while(!file.eof_reached()):
				code_array.append(file.get_line())
			rpc("create_unit", code_array, unit_type, init_position)
			pass

sync func create_unit(code_array, unit_type, init_position):
	var unit
	if(__eat_ressource__(unit_type)):
		unit = __instance_by_name__(unit_type)
		unit.code = code_array
		
		unit.set_name(str(unit_id_iterator))
		add_child(unit)
		unit.set_position(init_position)
		
		unit.owner_id = self.id
		
		unit.id = unit_id_iterator
		unit_list[unit_id_iterator] = unit.get_path()
		unit_id_iterator += 1
		
		unit.send_line()
		
	pass

func __eat_ressource__(unit_type):
	var ressources_cost = self.globals.ressource_cost[unit_type]
	for ressource in ressources_cost:
		if(!ressource_dict.has(ressource)):
			return false
		elif(ressource_dict[ressource] < ressources_cost[ressource]):
			return false
	
	for ressource in ressources_cost:
		ressource_dict[ressource] -= ressources_cost[ressource]
		if(id == get_tree().get_network_unique_id()):
			emit_signal("add_ressource_signal", ressource, ressource_dict[ressource])
	
	return true
	pass

func __instance_by_name__(unit_type):
	match(unit_type):
		"BR100":
				return br100_module_scene.instance()