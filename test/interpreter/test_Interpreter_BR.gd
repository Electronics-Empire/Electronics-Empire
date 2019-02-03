extends "test_util.gd"

func before_each():
	__reset_register__()
	watch_signals(interpreter)

func after_each():
	assert_false(interpreter.error_occur, "an error have occured")
	pass

func before_all():
	randomize()
	interpreter = load("res://Script/Interpreter_BR.gd").new()

func after_all():
	pass

func test_walk():
	operand1 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	
	interpreter.load_line("walk " + str(operand1))
	interpreter.evaluate()
	
	assert_signal_emitted_with_parameters(interpreter, "walk_signal", [operand1])
	
	while(operand1 < interpreter.maxInt and operand1 > interpreter.minInt):
		operand1 = randi()
	
	interpreter.load_line("walk " + str(operand1))
	interpreter.evaluate()
	
	assert_signal_emitted_with_parameters(interpreter, "walk_signal", [0])

func test_attack():
	interpreter.load_line("att")
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "attack_signal")

func test_mine():
	interpreter.load_line("mine")
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "mine_signal")

func test_rot():
	operand1 = direction_string[randi()%direction_string.size()]
	
	interpreter.load_line("rot " + operand1)
	interpreter.evaluate()
	
	assert_signal_emitted_with_parameters(interpreter, "rotate_signal", [operand1])

func test_look():
	interpreter.load_line("look")
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "look_signal")

func test_jump():
	operand1 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	
	interpreter.load_line("jmp " + str(operand1))
	interpreter.evaluate()
	
	assert_signal_emitted_with_parameters(interpreter, "jump_signal", [operand1])

func test_jump_equal():
	operand1 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	
	interpreter.status_register["equal"] = false
	
	interpreter.load_line("je " + str(operand1))
	interpreter.evaluate()
	
	assert_signal_not_emitted(interpreter, "jump_signal")
	
	interpreter.status_register["equal"] = true
	
	interpreter.load_line("je " + str(operand1))
	interpreter.evaluate()
	
	assert_signal_emitted_with_parameters(interpreter, "jump_signal", [operand1])

func test_compare():
	operand1 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	
	interpreter.load_line("cmp " + str(operand1) + " " + str(operand1))
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "compare_signal")
	assert_true(interpreter.status_register["equal"])
	
	interpreter.load_line("cmp " + str(operand1) + " " + str(operand1+1))
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "compare_signal")
	assert_false(interpreter.status_register["equal"])

func test_add():
	operand1 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	operand2 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	
	interpreter.load_line("add " + str(operand1) + " " + str(operand2) + " x")
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "add_signal")
	assert_eq(interpreter.registers["x"], operand1 + operand2)

func test_sub():
	operand1 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	operand2 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	
	interpreter.load_line("sub " + str(operand1) + " " + str(operand2) + " x")
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "sub_signal")
	assert_eq(interpreter.registers["x"], operand1 - operand2)

func test_multiply():
	operand1 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	operand2 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	
	interpreter.load_line("mul " + str(operand1) + " " + str(operand2) + " x")
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "multiply_signal")
	assert_eq(interpreter.registers["x"], operand1 * operand2)

func test_divide():
	operand1 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	operand2 = int(rand_range(interpreter.minInt, interpreter.maxInt+1))
	
	interpreter.load_line("div " + str(operand1) + " " + str(operand2) + " x")
	interpreter.evaluate()
	
	assert_signal_emitted(interpreter, "divide_signal")
	assert_eq(interpreter.registers["x"], operand1 / operand2)

func test_invalid():
	var inst = random_string[randi()%random_string.size()]
	
	interpreter.load_line(inst)
	interpreter.evaluate()
	
	assert_true(interpreter.error_occur, "no error have occured")
	
	interpreter.error_occur = false