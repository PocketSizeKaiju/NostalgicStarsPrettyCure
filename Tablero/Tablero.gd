class_name Tablero
extends Node2D

const DIRECCIONES = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

@export var grilla: Resource

var _unidades := {}
var _unidad_activa: Unidad
var _celdas_caminables := []
var _celdas_atacables := []
var _costos_movimientos

@onready var _overlay_unidades: OverlayUnidades = $OverlayUnidades
@onready var _camino_unidades: CaminoUnidades = $CaminoUnidades
@onready var _mapa: TileMapLayer = $Mapa

const VALOR_MAXIMO: int = 99999
const ATLAS_ID_OBSTACULOS = 2

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
	return _dijkstra(unidad.celda, unidad.rango_movimiento, false)

func obtener_celdas_atacables(unidad: Unidad) -> Array:
	var celdas_atacables = []
	var celdas_caminables_reales = _dijkstra(unidad.celda, unidad.rango_movimiento, true)
	
	for celda_actual in celdas_caminables_reales:
		for rango_actual in range(1, unidad.rango_ataque + 1):
			celdas_atacables = celdas_atacables + _llenar_area_caminable(celda_actual, unidad.rango_ataque)
	
	return celdas_atacables.filter(func(i): return i not in celdas_caminables_reales)


func _reinitialize() -> void:
	_unidades.clear()

	for child in get_children():
		var unidad := child as Unidad
		if not unidad:
			continue
		_unidades[unidad.celda] = unidad


func _llenar_area_caminable(celda: Vector2, distancia_maxima: int) -> Array:
	var array_completo := []
	var array_paredes := []
	var stack := [celda]
	while not stack.size() == 0:
		var actual = stack.pop_back()
		if not grilla.dentro_del_limite(actual):
			continue
		if actual in array_completo:
			continue

		var diferencia: Vector2 = (actual - celda).abs()
		var distancia := int(diferencia.x + diferencia.y)
		if distancia > distancia_maxima:
			continue

		array_completo.append(actual)
		for direccion in DIRECCIONES:
			var coordenadas: Vector2 = actual + direccion
			
			#comentar esto si las unidades NO pueden atacar sobre las paredes y solo alrededor
			if _mapa.get_cell_source_id(coordenadas) == ATLAS_ID_OBSTACULOS:
				array_paredes.append(coordenadas)
			
			#if esta_ocupada(coordenadas):
			#	continue
			if coordenadas in array_completo:
				continue
			if coordenadas in stack:
				continue

			stack.append(coordenadas)
	
	return array_completo.filter(func(i): return i not in array_paredes)

#genera una lista de celdas caminables basadas en el valor de movimiento de 
#la unidad y el costo de movimiento de la celda
func _dijkstra(celda: Vector2, distancia_maxima: int, es_atacable:bool) -> Array:
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
					
					if esta_ocupada(coordenadas):
						if _unidad_activa.es_enemigo != _unidades[coordenadas].es_enemigo: #comentar esto para que no pueda pasar por ninguna unidad, no solo los enemigos
							distancia_al_nodo = actual.prioridad + VALOR_MAXIMO
						elif _unidades[coordenadas].esta_esperando and es_atacable:
							celdas_ocupadas.append(coordenadas)
					
					visitado[coordenadas.y][coordenadas.x] = true
					distancias[coordenadas.y][coordenadas.x] = distancia_al_nodo
				if distancia_al_nodo <= distancia_maxima:
					previas[coordenadas.y][coordenadas.x] = actual.valor
					celdas_movibles.append(coordenadas)
					fila.agregar(coordenadas, distancia_al_nodo)
	
	return celdas_movibles.filter(func(i): return i not in celdas_ocupadas)

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
	_celdas_atacables = obtener_celdas_atacables(_unidad_activa)
	
	_overlay_unidades.dibujar_celdas_atacables(_celdas_atacables)
	_overlay_unidades.dibujar_celdas_caminables(_celdas_caminables)
	
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
