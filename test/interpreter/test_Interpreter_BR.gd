extends "test_util.gd"

func before_each():
	__reset_register__()
	watch_signals(interpreter)

func after_each():
	assert_false(interpreter.error_occur, "an error have occured")
	pass

func before_all():
	randomize()

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

func test_invalid():
	var inst = random_string[randi()%random_string.size()]
	
	interpreter.load_line(inst)
	interpreter.evaluate()
	
	assert_true(interpreter.error_occur, "no error have occured")
	
	interpreter.error_occur = false