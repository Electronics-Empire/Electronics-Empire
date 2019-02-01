extends "res://addons/gut/test.gd"

var interpreter = load("res://Script/Interpreter_LG401.gd").new()
var operand1
var operand2

const direction_string = ["north", "south", "east", "west"]
const random_string = ["string1", "string2", "string3", "string4"]

func before_each():
	watch_signals(interpreter)

func after_each():
	pass

func before_all():
	randomize()

func after_all():
	pass

func test_walk():
	operand1 = (randi()%100000) - 50000
	
	interpreter.load_line("walk " + str(operand1))
	interpreter.evaluate()
	
	assert_signal_emitted_with_parameters(interpreter, "walk_signal", [operand1])

func test_attack():
	interpreter.load_line("att")
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "attack_signal")

func test_mine():
	interpreter.load_line("mine")
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "mine_signal")

func test_build():
	operand1 = random_string[randi()%random_string.size()]
	operand2 = random_string[randi()%random_string.size()]
	
	interpreter.load_line("bld \"" + operand1 + "\" \"" + operand2 + "\"")
	interpreter.evaluate()
	
	assert_signal_emitted_with_parameters(interpreter, "build_signal", [operand1, operand2])

func test_rot():
	operand1 = direction_string[randi()%direction_string.size()]
	
	interpreter.load_line("rot " + operand1)
	interpreter.evaluate()
	
	assert_signal_emitted_with_parameters(interpreter, "rotate_signal", [operand1])