extends AcceptDialog

func __show_dialog__(text):
	self.dialog_text = text
	self.show()
	pass

func __close_dialog__():
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
