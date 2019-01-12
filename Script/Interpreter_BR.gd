extends "Interpreter_base.gd"

enum BR_type{
	PLUS,
	MINUS,
	MULTIPLY,
	DIVIDE,
	WALK,
	ATTACK,
	ROTATE,
	DIRECTION
}

signal walk_signal
signal add_signal
signal sub_signal
signal multiply_signal
signal divide_signal
signal attack_signal
signal rotate_signal

var direction_names

func _init():
	self.register_names = PoolStringArray(["x", "y", "a"])
	self.direction_names = PoolStringArray(["north", "south", "east", "west"])
	self.registers = {"x":0, "y":0, "a":0}
	pass

func evaluate():
	get_next_token()
	
	self.instruction = self.current_token
	
	if(instruction != null):
		match(instruction.type):
			
			BR_type.PLUS:
				
				eat(BR_type.PLUS)
				
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
				
			BR_type.MINUS:
				
				eat(BR_type.MINUS)
				
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
				
			BR_type.MULTIPLY:
				
				eat(BR_type.MULTIPLY)
				
				inst_2V_1R()
				
				if(!self.error_occur):
					var temp = 0
					
					if(self.operand_1.type == BASE_type.REGISTER):
						temp = self.registers[self.operand_1.value]
					else:
						temp = self.operand_1.value
						
					if(self.operand_2.type == BASE_type.REGISTER):
						temp *= self.registers[self.operand_2.value]
					else:
						temp *= self.operand_2.value
					
					self.registers[self.operand_3.value] = temp
					emit_signal("multiply_signal")
				
			BR_type.DIVIDE:
				
				eat(BR_type.DIVIDE)
				
				inst_2V_1R()
				
				if(!self.error_occur):
					var temp = 0
					
					if(self.operand_1.type == BASE_type.REGISTER):
						temp = self.registers[self.operand_1.value]
					else:
						temp = self.operand_1.value
						
					if(self.operand_2.type == BASE_type.REGISTER):
						temp /= self.registers[self.operand_2.value]
					else:
						temp /= self.operand_2.value
					
					self.registers[self.operand_3.value] = temp
					emit_signal("divide_signal")
				
			BR_type.WALK:
				
				eat(BR_type.WALK)
				
				self.operand_1 = self.current_token
				eat(BASE_type.INTEGER)
				
				if(!self.error_occur):
					emit_signal("walk_signal",operand_1.value)
				
			BR_type.ATTACK:
				
				eat(BR_type.ATTACK)
				
				if(!self.error_occur):
					emit_signal("attack_signal")
				
			BR_type.ROTATE:
				
				eat(BR_type.ROTATE)
				
				self.operand_1 = self.current_token
				eat(BR_type.DIRECTION)
				
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
			self.current_token = Token.new(BR_type.PLUS, null)
			return
			
		"sub":
			advance()
			self.current_token = Token.new(BR_type.MINUS, null)
			return
			
		"mul":
			advance()
			self.current_token = Token.new(BR_type.MULTIPLY, null)
			return
			
		"div":
			advance()
			self.current_token = Token.new(BR_type.DIVIDE, null)
			return
			
		"walk":
			advance()
			self.current_token = Token.new(BR_type.WALK, null)
			return
			
		"att":
			advance()
			self.current_token = Token.new(BR_type.ATTACK, null)
			return
			
		"rot":
			advance()
			self.current_token = Token.new(BR_type.ROTATE, null)
			return
			
	if(self.cur_lexeme in direction_names):
		advance()
		self.current_token = Token.new(BR_type.DIRECTION, self.cur_lexeme)
		return
		
	pass

func _ready():
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
