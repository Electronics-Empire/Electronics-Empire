extends "unit_entity.gd"

func _ready():
	._ready()
	
	self.clock_time = 3
	self.max_health = 100
	self.damage = 50
	self.entity_name = "BR100"
	
	self.clock.set_wait_time(self.clock_time)
	self.health_bar.max_value = self.max_health
	self.health_bar.value = self.max_health
	self.interpreter = get_node("BR100_Interpreter")
	
	self.interpreter.connect("walk_signal", self, "walk")
	self.interpreter.connect("add_signal", self, "add_executed")
	self.interpreter.connect("sub_signal", self, "sub_executed")
	self.interpreter.connect("multiply_signal", self, "multiply_executed")
	self.interpreter.connect("divide_signal", self, "divide_executed")
	self.interpreter.connect("rotate_signal", self, "rotate")
	self.interpreter.connect("attack_signal", self, "attack")
	self.interpreter.connect("mine_signal", self, "mine")
	
	pass

func __reset_active__():
	self.code_pos += 1
	if(self.code_pos >= code.size()):
		self.code_pos = 0
	send_line()
	pass