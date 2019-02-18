extends AcceptDialog

func show_dialog(text):
	self.dialog_text = text
	self.show()
	pass

func close_dialog():
	self.hide()
	pass

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
