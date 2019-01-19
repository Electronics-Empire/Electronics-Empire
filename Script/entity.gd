extends KinematicBody2D

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

signal add_ressource_signal
signal build_signal

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

func walk(count):
	if(count):
		if(!self.ray_cast.is_colliding()):
			self.movement.interpolate_property(self, "position", self.position, self.position + self.ray_cast.cast_to, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			self.movement.interpolate_callback(self, self.movement.get_runtime(), "walk", count-1)
			self.movement.start()
		else:
			__reset_active__()
	else:
		__reset_active__()
	pass

func tween_stopped():
	__reset_active__()
	pass

func add_executed():
	__reset_active__()
	pass

func sub_executed():
	__reset_active__()
	pass

func multiply_executed():
	__reset_active__()
	pass

func divide_executed():
	__reset_active__()
	pass

func rotate(direction):
	match(direction):
		"north":
			self.orientation = DIRECTION.north
			self.ray_cast.cast_to = Vector2(0,-globals.tileSize.y)
			sprite.play("NORTH")
		"south":
			self.orientation = DIRECTION.south
			self.ray_cast.cast_to = Vector2(0,globals.tileSize.y)
			sprite.play("SOUTH")
		"east":
			self.orientation = DIRECTION.east
			self.ray_cast.cast_to = Vector2(globals.tileSize.x,0)
			sprite.play("EAST")
		"west":
			self.orientation = DIRECTION.west
			self.ray_cast.cast_to = Vector2(-globals.tileSize.x,0)
			sprite.play("WEST")
	self.ray_cast.force_raycast_update()
	__reset_active__()
	pass

func attack():
	if(self.ray_cast.is_colliding()):
		var obj = self.ray_cast.get_collider()
		if(obj is KinematicBody2D):
			obj.__receive_damage__(self.damage)
	__reset_active__()
	pass

func build(file_path, unit_type):
	if(!self.ray_cast.is_colliding()):
		emit_signal("build_signal", file_path, unit_type, self.position + self.ray_cast.cast_to)
	__reset_active__()
	pass

func __receive_damage__(damage):
	self.health_bar.value -= damage
	print(self.health_bar.value)
	if(self.health_bar.value <= 0):
		self.__die__()

func mine():
	if(self.ray_cast.is_colliding()):
		var obj = self.ray_cast.get_collider()
		if(obj.is_in_group("Ressource")):
			emit_signal("add_ressource_signal", obj.ressource_name, obj.mine())
	__reset_active__()

func _process(delta):
	self.clock_bar.value = ((self.clock_time-self.clock.time_left)/self.clock_time)*100
	pass

func _ready():
	self.orientation = DIRECTION.south
	
	self.clock = Timer.new()
	self.clock.set_one_shot(true)
	self.add_child(self.clock)
	
	self.clock_bar = get_node("Clock_bar")
	self.movement = get_node("Movement")
	self.globals = get_node("/root/globals")
	self.sprite = get_node("AnimatedSprite")
	self.ray_cast = get_node("Collision_checker")
	self.health_bar = get_node("Health_bar")
	
	self.ray_cast.cast_to = Vector2(0,globals.tileSize.y)
	
	self.sprite.play("SOUTH")
	pass
