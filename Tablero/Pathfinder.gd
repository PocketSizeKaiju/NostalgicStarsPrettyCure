class_name PathFinder
extends Resource

const DIRECCIONES = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

var _grilla: Resource
var _astar := AStarGrid2D.new()


func _init(grilla: Grilla, celdas_caminables: Array) -> void:
	_grilla = grilla
	_astar.region = Rect2(Vector2(0,0), _grilla.tamanio)
	_astar.cell_size = _grilla.tamanio_celda
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.update()

	for y in _grilla.tamanio.y:
		for x in _grilla.tamanio.x:
			if not celdas_caminables.has(Vector2(x,y)):
				_astar.set_point_solid(Vector2(x,y))

func calcular_punto_camino(inicio: Vector2, final: Vector2) -> PackedVector2Array:
	return _astar.get_id_path(inicio, final)
