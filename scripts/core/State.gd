extends Node
class_name State
## Base class for a single state inside a StateMachine. Attach concrete
## states as child nodes of a StateMachine node and override the methods
## below. `actor` is injected by the StateMachine on _ready.

var actor: Node
var state_machine: StateMachine

func enter(_msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
