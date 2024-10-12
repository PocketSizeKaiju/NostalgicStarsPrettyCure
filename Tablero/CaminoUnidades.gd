class_name CaminoUnidades
extends TileMapLayer

@export var grilla: Resource

var _pathfinder: PathFinder
var camino_actual := PackedVector2Array()


func initialize(celdas_caminable: Array) -> void:
	_pathfinder = PathFinder.new(grilla, celdas_caminable)


func draw(celda_inicial: Vector2, celda_final: Vector2) -> void:
	clear()
	camino_actual = _pathfinder.calcular_punto_camino(celda_inicial, celda_final)
	set_cells_terrain_connect(camino_actual, 0, 0)


func stop() -> void:
	_pathfinder = null
	clear()
