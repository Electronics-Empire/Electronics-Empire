extends "Interpreter_base.gd"

enum LG401_type{
	PLUS,
	MINUS,
	WALK,
	ATTACK,
	ROTATE,
	DIRECTION
}

signal walk_signal
signal add_signal
signal sub_signal
signal attack_signal
signal rotate_signal

var direction_names

func _init():
	self.register_names = PoolStringArray(["x"])
	self.direction_names = PoolStringArray(["north", "south", "east", "west"])
	self.registers = {"x":0}
	pass

func evaluate():
	get_next_token()
	
	self.instruction = self.current_token
	
	if(instruction != null):
		match(instruction.type):
			
			LG401_type.PLUS:
				
				eat(LG401_type.PLUS)
				
				inst_2V_1R()
				
				if(!self.error_occur):
					var temp = 0
					
					if(self.operand_1.type == BASE_type.REGISTER):
						temp = self.registers[self.operand_1.value]
					else:
						temp = self.operand_1.value
						
					if(self.operand_2.type == BASE_type.REGISTER):
						temp += self.registers[self.operand_2.value]
					else:
						temp += self.operand_2.value
					
					self.registers[self.operand_3.value] = temp
					emit_signal("add_signal")
				
			LG401_type.MINUS:
				
				eat(LG401_type.MINUS)
				
				inst_2V_1R()
				
				if(!self.error_occur):
					var temp = 0
					
					if(self.operand_1.type == BASE_type.REGISTER):
						temp = self.registers[self.operand_1.value]
					else:
						temp = self.operand_1.value
						
					if(self.operand_2.type == BASE_type.REGISTER):
						temp -= self.registers[self.operand_2.value]
					else:
						temp -= self.operand_2.value
					
					self.registers[self.operand_3.value] = temp
					emit_signal("sub_signal")
				
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
	else:
		error("bad instruction")
	
	pass


func get_next_token():
	.get_next_token()
	
	if(self.current_token != null):
		return
	
	match(self.cur_lexeme):
		"add":
			advance()
			self.current_token = Token.new(LG401_type.PLUS, null)
			return
			
		"sub":
			advance()
			self.current_token = Token.new(LG401_type.MINUS, null)
			return
			
		"walk":
			advance()
			self.current_token = Token.new(LG401_type.WALK, null)
			return
			
		"attack":
			advance()
			self.current_token = Token.new(LG401_type.ATTACK, null)
			return
			
		"rotate":
			advance()
			self.current_token = Token.new(LG401_type.ROTATE, null)
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
