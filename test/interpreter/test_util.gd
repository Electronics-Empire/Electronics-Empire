extends "res://addons/gut/test.gd"

var interpreter
var operand1
var operand2

const direction_string = ["north", "south", "east", "west"]
const random_string = ["string1", "string2", "string3", "string4"]

func __reset_register__():
	for name in interpreter.register_names:
		interpreter.registers[name] = 0