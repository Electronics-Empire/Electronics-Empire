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
var own
var orientation
var damage

var active

signal dead_signal

remote func __ask_entity_sync__():
	rpc("__entity_sync__", self.sprite.animation, self.sprite.frame, self.position, self.health_bar.value, self.orientation)
	pass

remote func __entity_sync__(animation, frame, pos, health, orientation):
	self.sprite.animation = animation
	self.sprite.frame = frame
	self.position = pos
	self.health_bar.value = health
	self.orientation = orientation
	pass


sync func __send_line__(text):
	
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

func __walk__(count):
	if(count):
		match(self.orientation):
			DIRECTION.north:
				walk(Vector2(0,-globals.tileSize.y), count)
			DIRECTION.south:
				walk(Vector2(0,globals.tileSize.y), count)
			DIRECTION.east:
				walk(Vector2(globals.tileSize.x,0), count)
			DIRECTION.west:
				walk(Vector2(-globals.tileSize.x, 0), count)
	else:
		reset_active()
	pass

func walk(dest, count):
	self.ray_cast.cast_to = dest
	self.ray_cast.force_raycast_update()
	
	if(!self.ray_cast.is_colliding()):
		self.movement.interpolate_property(self, "position", self.position, self.position+dest, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		self.movement.interpolate_callback(self, self.movement.get_runtime(), "__walk__", count-1)
		self.movement.start()
	else:
		reset_active()

func __tween_stopped__():
	reset_active()
	pass

sync func __add_executed__():
	reset_active()
	pass

sync func __sub_executed__():
	reset_active()
	pass

func __rotate__(direction):
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
	reset_active()
	pass

func __attack__():
	match(self.orientation):
		DIRECTION.north:
			attack(Vector2(0,-globals.tileSize.y))
		DIRECTION.south:
			attack(Vector2(0,globals.tileSize.y))
		DIRECTION.east:
			attack(Vector2(globals.tileSize.x,0))
		DIRECTION.west:
			attack(Vector2(-globals.tileSize.x,0))
	reset_active()
	pass

func attack(dest):
	self.ray_cast.cast_to = dest
	self.ray_cast.force_raycast_update()
	
	if(self.ray_cast.is_colliding()):
		var obj = self.ray_cast.get_collider()
		if(obj is KinematicBody2D):
			obj.receive_damage(self.damage)

func receive_damage(damage):
	self.health_bar.value -= damage
	print(self.health_bar.value)
	if(self.health_bar.value <= 0):
		self.die()

func die():
	emit_signal("dead_signal")

func _ready():
	self.clock_time = 1
	self.max_health = 100
	self.damage = 50
	self.orientation = DIRECTION.south
	
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
	self.health_bar = get_node("Health_bar")
	
	self.health_bar.max_value = self.max_health
	self.health_bar.value = self.max_health
	self.sprite.play("SOUTH")
	
	self.interpreter.connect("walk_signal", self, "__walk__")
	self.interpreter.connect("add_signal", self, "__add_executed__")
	self.interpreter.connect("sub_signal", self, "__add_executed__")
	self.interpreter.connect("rotate_signal", self, "__rotate__")
	self.interpreter.connect("attack_signal", self, "__attack__")
	
	reset_active()
	pass

func _process(delta):
	self.clock_bar.value = ((self.clock_time-self.clock.time_left)/self.clock_time)*100
	pass

func reset_active():
	self.active = 0
	pass

func set_active():
	self.active = 1
	pass

func is_active():
	return self.active
	pass