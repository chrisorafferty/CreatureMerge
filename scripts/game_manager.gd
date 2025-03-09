class_name GameManager extends Node2D

var wasTouching: bool = false
var objectPrefab: PackedScene = preload("res://prefabs/onject.tscn")
var curObj: RigidBody2D
@onready var camera: Camera2D = $Camera2D
var spawnHeight: float = 300

func _ready() -> void:
	spawnObj()

func onTouch(touchLocation: Vector2):
	if curObj != null:
		curObj.position.x = get_canvas_transform().affine_inverse().translated(touchLocation).origin.x

func onTouchEnd(touchLocation: Vector2):
	curObj.freeze = false
	
	spawnObj()

func spawnObj(): 
	curObj = objectPrefab.instantiate()
	curObj.position = Vector2.UP * spawnHeight
	curObj.freeze = true
	add_child(curObj)
	
func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed and event.index == 0:
			onTouch(event.position)
			wasTouching = true
			
		elif event.index == 0 and wasTouching:
			onTouchEnd(event.position)
			wasTouching = false
	if event is InputEventScreenDrag:
		if event.index == 0:
			onTouch(event.position)
			wasTouching = true
