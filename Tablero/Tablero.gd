class_name Tablero
extends Node2D

const DIRECCIONES = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

@export var grilla: Resource

var _unidades := {}
var _unidad_activa: Unidad
var _celdas_caminables := []

@onready var _overlay_unidades: OverlayUnidades = $OverlayUnidades
@onready var _camino_unidades: CaminoUnidades = $CaminoUnidades


func _ready() -> void:
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
	return _llenar_area_caminable(unidad.celda, unidad.rango_movimiento)


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
