class_name GameManager extends Node2D

var wasTouching: bool = false
var creatures: Array[PackedScene] = [
	preload("res://prefabs/creatures/1.tscn"),
	preload("res://prefabs/creatures/2.tscn"),
	preload("res://prefabs/creatures/3.tscn"),
	preload("res://prefabs/creatures/4.tscn"),
	preload("res://prefabs/creatures/5.tscn"),
	preload("res://prefabs/creatures/6.tscn"),
	preload("res://prefabs/creatures/7.tscn"),
	preload("res://prefabs/creatures/8.tscn"),
]
var curCreature: RigidBody2D
var curCreatureRadius: float = 0
var spawnHeight: float = 300

var spawnDelay: float = 0.5
var spawnTimer: float = 0

var mergeDelay: float = 0.2
var merges: Array[MergeData] = []

var spawnedCreatures: Dictionary = {}

class MergeData:
	var timer: float
	var creatureIndex: int
	var position: Vector2
	
	func _init(_creatureIndex: int, _position: Vector2):
		timer = 0
		creatureIndex = _creatureIndex
		position = _position

func _ready() -> void:
	spawnDropCreature()
	
func _process(delta: float) -> void:
	spawnTimer += delta
	
	if spawnTimer > spawnDelay && curCreature == null:
		spawnDropCreature()
	
	for i in range(merges.size() - 1, -1, -1):
		merges[i].timer += delta
		if merges[i].timer > mergeDelay:
			spawnCreature(merges[i].creatureIndex, merges[i].position)
			merges.remove_at(i)

func onTouch(touchLocation: Vector2):
	if curCreature == null: return

	moveCurCreature(touchLocation)

func onTouchEnd(touchLocation: Vector2):
	if curCreature == null: return
	
	moveCurCreature(touchLocation)

	curCreature.freeze = false
	curCreature = null
	spawnTimer = 0

func spawnDropCreature(): 
	var index: int = randi_range(0, 2)
	
	curCreature = spawnCreature(index, Vector2.UP * spawnHeight)
	curCreature.freeze = true
	
	for child in curCreature.get_children():
		if child is CollisionShape2D:
			curCreatureRadius = child.shape.radius

func spawnCreature(index: int, pos: Vector2) -> RigidBody2D: 
	var spawnedCreature: RigidBody2D = creatures[index].instantiate()
	spawnedCreature.position = pos
	add_child(spawnedCreature)
	spawnedCreature.body_entered.connect(onCollision.bind(spawnedCreature))
	spawnedCreatures[spawnedCreature] = index
	return spawnedCreature

func moveCurCreature(touchLocation: Vector2):
	if curCreature == null: return
	
	var maxX = (get_viewport().size.x / 2) - curCreatureRadius
	var posX = get_canvas_transform().affine_inverse().translated(touchLocation).origin.x
	
	curCreature.position = Vector2(clampf(posX, -maxX, maxX), -spawnHeight)
	
func onCollision(other: Node, creature: RigidBody2D):
	if !spawnedCreatures.has(other) or !spawnedCreatures.has(creature): return
	
	var index = spawnedCreatures[creature]
	if spawnedCreatures[other] != index: return
	if index >= creatures.size() - 1: return

	var spawnPos = ((other as Node2D).position + creature.position) / 2

	spawnedCreatures.erase(other)
	spawnedCreatures.erase(creature)
	other.queue_free()
	creature.queue_free()
	
	merges.append(MergeData.new(index + 1, spawnPos))
	
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
