extends Camera2D

const camera_margin = 20
const mouvementSpeed = 7
var mouvement = Vector2(0,0)

func _physics_process(delta):
	if self.current:
		mouvement = Vector2(0,0)
		
		if get_viewport().get_mouse_position().x >= get_viewport_rect().size.x - self.camera_margin:
			mouvement += Vector2(1, 0)
		elif get_viewport().get_mouse_position().x < self.camera_margin:
			mouvement += Vector2(-1, 0)
		if get_viewport().get_mouse_position().y >= get_viewport_rect().size.y - self.camera_margin:
			mouvement += Vector2(0, 1)
		elif get_viewport().get_mouse_position().y < self.camera_margin:
			mouvement += Vector2(0, -1)
		
		self.position += (mouvement.normalized() * mouvementSpeed)