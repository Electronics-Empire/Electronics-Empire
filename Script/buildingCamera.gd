extends Camera2D

const camera_margin = 20
const mouvementSpeed = 7
var mouvement = Vector2(0,0)


func _physics_process(delta):
	if(self.current):
		mouvement = Vector2(0,0)
		
		#right
		if(Input.is_action_pressed("CAMERA_RIGHT")):
			mouvement.x += 1
		#left
		if(Input.is_action_pressed("CAMERA_LEFT")):
			mouvement.x -= 1
		#up
		if(Input.is_action_pressed("CAMERA_UP")):
			mouvement.y -= 1
		#down
		if(Input.is_action_pressed("CAMERA_DOWN")):
			mouvement.y += 1
		
		self.position += (mouvement.normalized() * mouvementSpeed)