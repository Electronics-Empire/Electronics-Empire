extends LineEdit

var ctrl_global
var mouse_here = true

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	self.ctrl_global = get_node("/root/ctrl_global")
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func focus_entered():
	self.ctrl_global.bool_text_select = true
	pass 


func focus_exited():
	self.ctrl_global.bool_text_select = false
	pass

func mouse_entered():
	mouse_here = true
	pass

func mouse_exited():
	mouse_here = false
	pass

func _input(event):
	if event is InputEventMouseButton:
		if not mouse_here:
			self.release_focus()
	pass