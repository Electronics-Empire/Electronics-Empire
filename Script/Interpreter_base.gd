extends Node

enum BASE_type{
	INTEGER,
	REGISTER,
	EOF
}

var pos
var line
var current_token
var cur_lexeme

var instruction
var operand_1
var operand_2
var operand_3
var operand_4
var operand_5

var error_occur

var register_names
var registers

class Token:
	var type
	var value
	
	func _init(type,value):
		self.type = type
		self.value = value
		pass
		

func load_line(line):
	self.pos = 0
	self.line = line.split(' ')
	self.current_token = null
	self.error_occur = false
	pass

func advance():
	self.pos += 1
	

func error(string):
	print(string)
	self.error_occur = true
	pass

func eat(token_type):
	if(self.current_token == null):
		error("token does not exist")
		
	elif(self.current_token.type == token_type):
		self.current_token = null
		get_next_token()
		
	else:
		error("token does not match")

func get_next_token():
	if self.pos > line.size()-1:
		self.current_token = Token.new(BASE_type.EOF, null)
		return
	
	self.cur_lexeme = line[pos].to_lower()
	
	if self.cur_lexeme.is_valid_integer():
		advance()
		self.current_token = Token.new(BASE_type.INTEGER, int(cur_lexeme))
		return
	
	if self.cur_lexeme in self.register_names:
		advance()
		self.current_token = Token.new(BASE_type.REGISTER, cur_lexeme)
		return

# function for instruction with form INST REG/INT REG/INT REG
func inst_2V_1R():
	self.operand_1 = self.current_token
	if(operand_1.type == BASE_type.INTEGER):
		eat(BASE_type.INTEGER)
	else:
		eat(BASE_type.REGISTER)
	
	self.operand_2 = self.current_token
	if(operand_2.type == BASE_type.INTEGER):
		eat(BASE_type.INTEGER)
	else:
		eat(BASE_type.REGISTER)
	
	self.operand_3 = self.current_token
	eat(BASE_type.REGISTER)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
