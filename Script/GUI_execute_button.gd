extends Button

var line_edit
var target

signal button_pressed_signal

func _ready():
	
	line_edit = get_node("../TextEdit")
	
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
