class_name Tablero
extends Node2D

const DIRECCIONES = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

@export var grilla: Resource

var _unidades := {}
var _unidad_activa: Unidad
var _celdas_caminables := []
var _costos_movimientos

@onready var _overlay_unidades: OverlayUnidades = $OverlayUnidades
@onready var _camino_unidades: CaminoUnidades = $CaminoUnidades
@onready var _mapa: TileMap = $Mapa

const VALOR_MAXIMO: int = 99999


func _ready() -> void:
	_costos_movimientos = _mapa.obtener_costos_movimiento(grilla)
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if _unidad_activa and event.is_action_pressed("ui_cancel"):
		_deseleccionar_unidad_activa()
		_limpiar_unidad_activa()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grilla:
		warning = "Necesitas una grilla para este nodo."
	return warning


func esta_ocupada(celda: Vector2) -> bool:
	return _unidades.has(celda)


func obtener_celdas_caminables(unidad: Unidad) -> Array:
	return _dijkstra(unidad.celda, unidad.rango_movimiento)


func _reinitialize() -> void:
	_unidades.clear()

	for child in get_children():
		var unidad := child as Unidad
		if not unidad:
			continue
		_unidades[unidad.celda] = unidad


func _llenar_area_caminable(celda: Vector2, distancia_maxima: int) -> Array:
	var array := []
	var stack := [celda]
	while not stack.size() == 0:
		var actual = stack.pop_back()
		if not grilla.dentro_del_limite(actual):
			continue
		if actual in array:
			continue

		var diferencia: Vector2 = (actual - celda).abs()
		var distancia := int(diferencia.x + diferencia.y)
		if distancia > distancia_maxima:
			continue

		array.append(actual)
		for direccion in DIRECCIONES:
			var coordinadas: Vector2 = actual + direccion
			if esta_ocupada(coordinadas):
				continue
			if coordinadas in array:
				continue
			if coordinadas in stack:
				continue

			stack.append(coordinadas)
	return array

#genera una lista de celdas caminables basadas en el valor de movimiento de 
#la unidad y el costo de movimiento de la celda
func _dijkstra(celda: Vector2, distancia_maxima: int, es_atacable:bool = false) -> Array:
	var celdas_movibles = [celda]
	var visitado = []
	var distancias = []
	var previas = []
	
	for y in range(grilla.tamanio.y):
		visitado.append([])
		distancias.append([])
		previas.append([])
		for x in range(grilla.tamanio.x):
			visitado[y].append(false)
			distancias[y].append(VALOR_MAXIMO)
			previas[y].append(null)
		
	var fila = FilaPrioridad.new()
	
	fila.agregar(celda, 0)
	distancias[celda.y][celda.x] = 0
	
	var costo_celda
	var distancia_al_nodo
	var celdas_ocupadas = []
	
	while not fila.esta_vacia():
		var actual = fila.quitar()
		visitado[actual.valor.y][actual.valor.x] = true
		
		for direccion in DIRECCIONES:
			var coordenadas = actual.valor + direccion
			if grilla.dentro_del_limite(coordenadas):
				if visitado[coordenadas.y][coordenadas.x]:
					continue
				else:
					costo_celda = _costos_movimientos[coordenadas.y][coordenadas.x]
					
					distancia_al_nodo = actual.prioridad + costo_celda
					
					visitado[coordenadas.y][coordenadas.x] = true
					distancias[coordenadas.y][coordenadas.x] = distancia_al_nodo
				if distancia_al_nodo <= distancia_maxima:
					previas[coordenadas.y][coordenadas.x] = actual.valor
					celdas_movibles.append(coordenadas)
					fila.agregar(coordenadas, distancia_al_nodo)
	return celdas_movibles

func _mover_unidad_activa(nueva_celda: Vector2) -> void:
	if esta_ocupada(nueva_celda) or not nueva_celda in _celdas_caminables:
		return
	_unidades.erase(_unidad_activa.celda)
	_unidades[nueva_celda] = _unidad_activa
	_deseleccionar_unidad_activa()
	_unidad_activa.caminando(_camino_unidades.camino_actual)
	await _unidad_activa.termino_caminar
	_limpiar_unidad_activa()


func _seleccionar_unidad(celda: Vector2) -> void:
	if not _unidades.has(celda):
		return

	_unidad_activa = _unidades[celda]
	_unidad_activa.esta_seleccionada = true
	_celdas_caminables = obtener_celdas_caminables(_unidad_activa)
	_overlay_unidades.draw(_celdas_caminables)
	_camino_unidades.initialize(_celdas_caminables)


func _deseleccionar_unidad_activa() -> void:
	_unidad_activa.esta_seleccionada = false
	_overlay_unidades.clear()
	_camino_unidades.stop()


func _limpiar_unidad_activa() -> void:
	_unidad_activa = null
	_celdas_caminables.clear()


func _on_Cursor_aceptar_presionada(celda: Vector2) -> void:
	if not _unidad_activa:
		_seleccionar_unidad(celda)
	elif _unidad_activa.esta_seleccionada:
		_mover_unidad_activa(celda)


func _on_Cursor_movido(nueva_celda: Vector2) -> void:
	if _unidad_activa and _unidad_activa.esta_seleccionada:
		_camino_unidades.draw(_unidad_activa.celda, nueva_celda)
