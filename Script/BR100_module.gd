extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum DIRECTION{
	north,
	south,
	east,
	west
}

var clock
var interpreter
var clock_time
var clock_bar
var health_bar
var max_health
var movement
var globals
var sprite
var ray_cast
var entity_name
var orientation
var damage

var code
var code_pos
var id

var active

signal add_ressource_signal
signal unit_dead_signal

remote func ask_entity_sync():
	rpc("entity_sync", self.sprite.animation, self.sprite.frame, self.position, self.health_bar.value, self.orientation)
	pass

remote func entity_sync(animation, frame, pos, health, orientation):
	self.sprite.animation = animation
	self.sprite.frame = frame
	self.position = pos
	self.health_bar.value = health
	self.orientation = orientation
	pass


sync func send_line():
	
	if(code[code_pos] == ""):
		__instruction_finished__()
	self.interpreter.load_line(code[code_pos])
	
	self.clock_bar.show()
		
	self.clock.start()
	yield(self.clock, "timeout")
		
	self.clock_bar.hide()
	
	self.interpreter.evaluate()
	if(self.interpreter.error_occur):
		__explode__()
	else:
		print(self.interpreter.registers["x"])
		print(self.interpreter.registers["y"])
		print(self.interpreter.registers["a"])
	
	pass

func load_code(code):
	self.code = code
	pass

func walk(count):
	if(count):
		match(self.orientation):
			DIRECTION.north:
				__walk__(Vector2(0,-globals.tileSize.y), count)
			DIRECTION.south:
				__walk__(Vector2(0,globals.tileSize.y), count)
			DIRECTION.east:
				__walk__(Vector2(globals.tileSize.x,0), count)
			DIRECTION.west:
				__walk__(Vector2(-globals.tileSize.x, 0), count)
	else:
		__instruction_finished__()
	pass

func __walk__(dest, count):
	self.ray_cast.cast_to = dest
	self.ray_cast.force_raycast_update()
	
	if(!self.ray_cast.is_colliding()):
		self.movement.interpolate_property(self, "position", self.position, self.position+dest, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		self.movement.interpolate_callback(self, self.movement.get_runtime(), "walk", count-1)
		self.movement.start()
	else:
		__instruction_finished__()

func tween_stopped():
	__instruction_finished__()
	pass

func add_executed():
	__instruction_finished__()
	pass

func sub_executed():
	__instruction_finished__()
	pass

func multiply_executed():
	__instruction_finished__()
	pass

func divide_executed():
	__instruction_finished__()
	pass

func rotate(direction):
	match(direction):
		"north":
			self.orientation = DIRECTION.north
			sprite.play("NORTH")
		"south":
			self.orientation = DIRECTION.south
			sprite.play("SOUTH")
		"east":
			self.orientation = DIRECTION.east
			sprite.play("EAST")
		"west":
			self.orientation = DIRECTION.west
			sprite.play("WEST")
	__instruction_finished__()
	pass

func attack():
	match(self.orientation):
		DIRECTION.north:
			__attack__(Vector2(0,-globals.tileSize.y))
		DIRECTION.south:
			__attack__(Vector2(0,globals.tileSize.y))
		DIRECTION.east:
			__attack__(Vector2(globals.tileSize.x,0))
		DIRECTION.west:
			__attack__(Vector2(-globals.tileSize.x,0))
	__instruction_finished__()
	pass

func __attack__(dest):
	self.ray_cast.cast_to = dest
	self.ray_cast.force_raycast_update()
	
	if(self.ray_cast.is_colliding()):
		var obj = self.ray_cast.get_collider()
		if(obj is KinematicBody2D):
			obj.__receive_damage__(self.damage)

func __receive_damage__(damage):
	self.health_bar.value -= damage
	print(self.health_bar.value)
	if(self.health_bar.value <= 0):
		self.__die__()

func __die__():
	emit_signal("unit_dead_signal")

func mine():
	match(self.orientation):
		DIRECTION.north:
			__mine__(Vector2(0,-globals.tileSize.y))
		DIRECTION.south:
			__mine__(Vector2(0,globals.tileSize.y))
		DIRECTION.east:
			__mine__(Vector2(globals.tileSize.x,0))
		DIRECTION.west:
			__mine__(Vector2(-globals.tileSize.x,0))
	__instruction_finished__()

func __mine__(dest):
	self.ray_cast.cast_to = dest
	self.ray_cast.force_raycast_update()
	
	if(self.ray_cast.is_colliding()):
		var obj = self.ray_cast.get_collider()
		if(obj.is_in_group("Ressource")):
			emit_signal("add_ressource_signal", obj.ressource_name, obj.mine())

func _ready():
	self.clock_time = 1
	self.max_health = 100
	self.damage = 50
	self.orientation = DIRECTION.south
	
	self.clock = Timer.new()
	self.clock.set_wait_time(self.clock_time)
	self.clock.set_one_shot(true)
	self.add_child(self.clock)
	
	self.code_pos = 0
	
	self.entity_name = "BR100"
	
	self.clock_bar = get_node("Clock_bar")
	self.interpreter = get_node("BR100_Interpreter")
	self.movement = get_node("Movement")
	self.globals = get_node("/root/globals")
	self.sprite = get_node("AnimatedSprite")
	self.ray_cast = get_node("Collision_checker")
	self.health_bar = get_node("Health_bar")
	
	self.health_bar.max_value = self.max_health
	self.health_bar.value = self.max_health
	self.sprite.play("SOUTH")
	
	self.interpreter.connect("walk_signal", self, "walk")
	self.interpreter.connect("add_signal", self, "add_executed")
	self.interpreter.connect("sub_signal", self, "sub_executed")
	self.interpreter.connect("multiply_signal", self, "multiply_executed")
	self.interpreter.connect("divide_signal", self, "divide_executed")
	self.interpreter.connect("rotate_signal", self, "rotate")
	self.interpreter.connect("attack_signal", self, "attack")
	self.interpreter.connect("mine_signal", self, "mine")
	
	pass

func _process(delta):
	self.clock_bar.value = ((self.clock_time-self.clock.time_left)/self.clock_time)*100
	pass

func __instruction_finished__():
	self.code_pos += 1
	if(self.code_pos >= code.size()):
		self.code_pos = 0
	send_line()
	pass

func __explode__():
	self.__die__()