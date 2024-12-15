class_name CommandList

var _commands = []
var _executedCommands = []

func Clear():
	_commands.clear()
	_executedCommands.clear()

func Add(command:Command, list = _commands):
	list.append(command)

func Remove(command:Command, list = _commands):
	list.remove(list.find(command))

func ExecuteLast():
	var lastCMD = _commands[_commands.size()]
	lastCMD.Execute()
	Add (lastCMD, _executedCommands)
	Remove (lastCMD, _commands)

func ExecuteAll():
	for command in _commands:
		command.Execute()
		Add(command,_executedCommands)
		Remove (command,_commands)

func UndoLast():
	if _executedCommands.size() > 0:
		var command = _executedCommands[_executedCommands.size()-1]
		command.Undo()
		Remove (command,_executedCommands)

func UndoAll():
	if _executedCommands.size() > 0: 
		for command in _executedCommands:
			command.Undo()
		Clear()
