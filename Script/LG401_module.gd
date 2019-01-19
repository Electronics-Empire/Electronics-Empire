extends "entity.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var active

signal dead_signal

sync func send_line(text):
	
	if(!__is_active__()):
	
		__set_active__()
		self.clock_bar.show()
		
		self.clock.start()
		yield(self.clock, "timeout")
		
		self.clock_bar.hide()
		
		self.interpreter.load_line(text)
		self.interpreter.evaluate()
		if(self.interpreter.error_occur):
			self.interpreter.error_occur = false
			__reset_active__()
	pass

func _ready():
	self.clock_time = 3
	self.max_health = 100
	self.damage = 50
	self.entity_name = "LG401"
	
	._ready()
	
	self.clock.set_wait_time(self.clock_time)
	self.health_bar.max_value = self.max_health
	self.health_bar.value = self.max_health
	self.interpreter = get_node("LG401_Interpreter")
	
	self.interpreter.connect("walk_signal", self, "walk")
	self.interpreter.connect("add_signal", self, "add_executed")
	self.interpreter.connect("sub_signal", self, "sub_executed")
	self.interpreter.connect("rotate_signal", self, "rotate")
	self.interpreter.connect("attack_signal", self, "attack")
	self.interpreter.connect("mine_signal", self, "mine")
	self.interpreter.connect("build_signal", self, "build")
	
	__reset_active__()
	pass

func __die__():
	emit_signal("dead_signal")

func __reset_active__():
	self.active = 0
	pass

func __set_active__():
	self.active = 1
	pass

func __is_active__():
	return self.active
	pass