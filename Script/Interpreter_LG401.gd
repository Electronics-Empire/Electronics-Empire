extends "Interpreter_base.gd"

enum LG401_type{
	WALK,
	ATTACK,
	ROTATE,
	DIRECTION,
	MINE
}

signal walk_signal
signal add_signal
signal sub_signal
signal attack_signal
signal rotate_signal
signal mine_signal

var direction_names

func _init():
	self.register_names = PoolStringArray()
	self.direction_names = PoolStringArray(["north", "south", "east", "west"])
	self.registers = {}
	pass

func evaluate():
	get_next_token()
	
	self.instruction = self.current_token
	
	if(instruction != null):
		match(instruction.type):
			LG401_type.WALK:
				
				eat(LG401_type.WALK)
				
				self.operand_1 = self.current_token
				eat(BASE_type.INTEGER)
				
				if(!self.error_occur):
					emit_signal("walk_signal",operand_1.value)
				
			LG401_type.ATTACK:
				
				eat(LG401_type.ATTACK)
				
				if(!self.error_occur):
					emit_signal("attack_signal")
				
			LG401_type.ROTATE:
				
				eat(LG401_type.ROTATE)
				
				self.operand_1 = self.current_token
				eat(LG401_type.DIRECTION)
				
				if(!self.error_occur):
					emit_signal("rotate_signal",operand_1.value)
				
			LG401_type.MINE:
				
				eat(LG401_type.MINE)
				
				if(!self.error_occur):
					emit_signal("mine_signal")
	else:
		error("bad instruction")
	
	pass


func get_next_token():
	.get_next_token()
	
	if(self.current_token != null):
		return
	
	match(self.cur_lexeme):
		"walk":
			advance()
			self.current_token = Token.new(LG401_type.WALK, null)
			return
			
		"att":
			advance()
			self.current_token = Token.new(LG401_type.ATTACK, null)
			return
			
		"rot":
			advance()
			self.current_token = Token.new(LG401_type.ROTATE, null)
			return
			
		"mine":
			advance()
			self.current_token = Token.new(LG401_type.MINE, null)
			return
			
	if(self.cur_lexeme in direction_names):
		advance()
		self.current_token = Token.new(LG401_type.DIRECTION, self.cur_lexeme)
		return
		
	pass

func _ready():
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
