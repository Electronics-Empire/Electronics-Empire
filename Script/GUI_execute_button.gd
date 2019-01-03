extends Button

var line_edit
var target
var ctrl_global

signal button_pressed_signal

func _ready():
	
	line_edit = get_node("../TextEdit")
	ctrl_global = get_node("/root/ctrl_global")
	
	self.connect("pressed", self, "__button_pressed__")
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func __button_pressed__():
	
	emit_signal("button_pressed_signal",line_edit.text)
	line_edit.clear()
	
	pass # replace with function body

func _process(delta):
	if(self.ctrl_global.bool_text_select):
		if(Input.is_action_pressed("ENTER")):
			self.__button_pressed__()
	pass
