extends "res://addons/gut/test.gd"

var interpreter = load("res://Script/Interpreter_LG401.gd").new()
var operand1 = 0

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