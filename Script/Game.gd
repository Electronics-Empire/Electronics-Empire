extends Node

var object_pos = Array()

var lg401_module

var execute_button
var world
var globals

func generate_object():
	pass

# signal in WorldGen.gd
func __generation_finished__():
	randomize()
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
	
	generate_object()
	pass

func __execute_button__(text):
	self.lg401_module.__send_line__(text)
	pass

func _ready():
	
	self.execute_button = get_node("Camera2D/GUI/GUI_execute_button")
	lg401_module = load("res://Scene/LG401_module.tscn").instance()
	self.world = get_node("World")
	self.globals = get_node("/root/globals")
	
	self.execute_button.connect("button_pressed_signal", self, "__execute_button__")
	self.world.connect("Generation_finished_signal", self, "__generation_finished__")
	
	self.world.__generate_world__()
	pass