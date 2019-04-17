extends Node

enum BASE_type{
	INTEGER,
	REGISTER,
	STRING,
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

var status_register = Dictionary()
var maxInt
var minInt

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
		var integer = int(cur_lexeme)
		if(integer > maxInt or integer < minInt):
			integer = 0
		self.current_token = Token.new(BASE_type.INTEGER, integer)
		return
	
	if self.cur_lexeme in self.register_names:
		advance()
		self.current_token = Token.new(BASE_type.REGISTER, cur_lexeme)
		return
		
	if(self.cur_lexeme.begins_with("\"") and self.cur_lexeme.ends_with("\"")):
		self.cur_lexeme = line[pos]
		advance()
		self.cur_lexeme.erase(0, 1)
		self.cur_lexeme.erase(self.cur_lexeme.length()-1, 1)
		self.current_token = Token.new(BASE_type.STRING, self.cur_lexeme)
		return

func variant(operand):
	if(operand.type == BASE_type.INTEGER):
		eat(BASE_type.INTEGER)
	else:
		operand.value = self.registers[operand.value]
		eat(BASE_type.REGISTER)

# function for instruction with form INST REG/INT REG/INT REG
func inst_2V_1R():
	self.operand_1 = self.current_token
	variant(self.operand_1)
	
	self.operand_2 = self.current_token
	variant(self.operand_2)
	
	self.operand_3 = self.current_token
	eat(BASE_type.REGISTER)
