extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var clock
var interpreter
var clock_time
var clock_bar
var movement
var globals
var sprite
var ray_cast
var entity_name
var own

var active

func __ask_entity_sync__():
	rpc_id(get_tree().get_rpc_sender_id(), "__entity_sync__", self.sprite.animation, self.sprite.frame, self.position)
	pass

remote func __entity_sync__(animation, frame, pos):
	self.sprite.animation = animation
	self.sprite.frame = frame
	self.position = pos
	pass


func __send_line__(text):
	
	if(!is_active()):
	
		set_active()
		self.clock_bar.show()
		
		self.clock.start()
		yield(self.clock, "timeout")
		
		self.clock_bar.hide()
		
		self.interpreter.load_line(text)
		self.interpreter.evaluate()
		if(self.interpreter.error_occur):
			self.interpreter.error_occur = false
			reset_active()
		else:
			print(self.interpreter.registers["x"])
	
	pass

func __walk__(direction, count):
	if(count):
		match(direction):
			"north":
				walk(Vector2(0,-globals.tileSize.y), direction, count)
				sprite.play("NORTH")
			"south":
				walk(Vector2(0,globals.tileSize.y), direction, count)
				sprite.play("SOUTH")
			"east":
				walk(Vector2(globals.tileSize.x,0), direction, count)
				sprite.play("EAST")
			"west":
				walk(Vector2(-globals.tileSize.x, 0), direction, count)
				sprite.play("WEST")
	else:
		reset_active()
	pass

func __tween_stopped__():
	reset_active()
	pass

func __add_executed__():
	reset_active()
	pass

func __sub_executed__():
	reset_active()
	pass

func _ready():
	self.clock_time = 1
	
	self.clock = Timer.new()
	self.clock.set_wait_time(self.clock_time)
	self.clock.set_one_shot(true)
	self.add_child(self.clock)
	
	self.entity_name = "LG401"
	
	self.clock_bar = get_node("Clock_bar")
	self.interpreter = get_node("LG401_Interpreter")
	self.movement = get_node("Movement")
	self.globals = get_node("/root/globals")
	self.sprite = get_node("AnimatedSprite")
	self.ray_cast = get_node("Collision_checker")
	
	self.interpreter.connect("walk_signal", self, "__walk__")
	self.interpreter.connect("add_signal", self, "__add_executed__")
	self.interpreter.connect("sub_signal", self, "__sub_executed__")
	
	reset_active()
	pass

func _process(delta):
	self.clock_bar.value = ((self.clock_time-self.clock.time_left)/self.clock_time)*100
	pass

func walk(dest, direction, count):
	self.ray_cast.cast_to = dest
	self.ray_cast.force_raycast_update()
	
	if(!self.ray_cast.is_colliding()):
		self.movement.interpolate_property(self, "position", self.position, self.position+dest, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		self.movement.interpolate_callback(self, self.movement.get_runtime(), "__walk__", direction, count-1)
		self.movement.start()
	else:
		reset_active()

func reset_active():
	self.active = 0
	pass

func set_active():
	self.active = 1
	pass

func is_active():
	return self.active
	pass