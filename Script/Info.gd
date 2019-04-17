extends TabContainer

var player_target
var registers
var ressources

var registers_tab
var ressource_tab
var is_open

func _ready():
	self.player_target = null
	self.registers = {}
	self.ressources = {}
	
	self.registers_tab = get_node("Registers")
	self.ressource_tab = get_node("Ressources")
	self.is_open = false
	pass

func set_target(target):
	self.player_target = target
	
	reset_registers()
	pass

func update_ressource(ressource, num):
	var text = ressource + ": " + str(num)
	pass

func update_registers():
	if(self.player_target != null):
		if(self.player_target.registers.hash() != self.registers.hash()):
			reset_registers()
	pass

func reset_registers():
	self.registers_tab.clear()
	self.registers = self.player_target.registers.duplicate()
	
	for key in self.registers:
		var text = key + ": " + str(self.registers[key])
		self.registers_tab.add_item(text)
	pass

#warning-ignore:unused_argument
func _process(delta):
	update_registers()
	if Input.is_action_pressed("OPEN_INFO"):
		self.show()
	if Input.is_action_just_released("OPEN_INFO"):
		self.hide()
	pass