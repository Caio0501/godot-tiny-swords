extends Node2D

const FOAM: PackedScene = preload("res://tiny_swords/management/foam.tscn")

@onready var grass_tilemap: TileMap = get_node("Grass")
@onready var water_tilemap: TileMap = get_node("Water")

var grass_used_cells: Array
var water_used_cells: Array

func _ready() -> void:
	var used_grass_rect: Rect2 = grass_tilemap.get_used_rect()
	grass_used_cells = grass_tilemap.get_used_cells(0)
	generate_water_tiles(used_grass_rect)
	generate_foam_tiles()


func generate_water_tiles(used_rec: Rect2) -> void:
	for x in range(used_rec.position.x - 10, used_rec.size.x + 10):
		for y in range(used_rec.position.y - 10, used_rec.size.y + 10):
			if grass_used_cells.has(Vector2i(x,y)):
				continue
				
			water_tilemap.set_cell(0, Vector2i(x,y), 0, Vector2i(0,0))
	
	water_used_cells = water_tilemap.get_used_cells(0)
	
func generate_foam_tiles() ->void:
	for cell in grass_used_cells:
		if check_grass_neigbors(cell):
			spawn_foan(cell)
	
func check_grass_neigbors(cell: Vector2i) -> bool:
	var left_neigbors: Vector2i = Vector2i(cell.x - 1, cell.y)
	var rigth_neigbors: Vector2i = Vector2i(cell.x + 1, cell.y)
	var up_neigbors: Vector2i = Vector2i(cell.x , cell.y - 1)
	var bottom_neigbors: Vector2i = Vector2i(cell.x, cell.y + 1)
	
	var neigbors_list: Array = [left_neigbors, rigth_neigbors, up_neigbors, bottom_neigbors]
	
	for neigbors in neigbors_list:
		if (water_used_cells.has(neigbors)):
			return true
			
	return false
	
func spawn_foan(foam_cell: Vector2i) -> void:
	var foam =  FOAM.instantiate()
	add_child(foam)
	
	foam.position = (foam_cell * 64.0) + Vector2(32,32)
	
