extends Panel

onready var textEdit = get_node("TextEdit")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func gui_input(event):
	if event is InputEventMouseButton:
		textEdit.release_focus()
	pass