extends LineEdit

var ctrl_global

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
