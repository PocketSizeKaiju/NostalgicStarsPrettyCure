@tool
class_name Cursor
extends Node2D

signal aceptar_presionada(celda)
signal movida(nueva_celda)

@export var grilla: Resource
@export var ui_cooldown := 0.1

var celda := Vector2.ZERO:
	set(valor):
		var nueva_celda: Vector2 = grilla.clamp_grilla(valor)
		if nueva_celda.is_equal_approx(celda):
			return

		celda = nueva_celda
		position = grilla.calcular_coordinadas_grilla(celda)
		emit_signal("movida", celda)
		_timer.start()

@onready var _timer: Timer = $Timer


func _ready() -> void:
	_timer.wait_time = ui_cooldown
	position = grilla.calcular_posicion_mapa(celda)


func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseMotion:
		celda = grilla.calcular_coordinadas_grilla(evento.position)
	elif evento.is_action_pressed("click") or evento.is_action_pressed("ui_accept"):
		emit_signal("aceptar_presionada", celda)
		get_viewport().set_input_as_handled()

	var deberia_moverse := evento.is_pressed() 
	if evento.is_echo():
		deberia_moverse = deberia_moverse and _timer.is_stopped()

	if not deberia_moverse:
		return

	if evento.is_action("ui_right"):
		celda += Vector2.RIGHT
	elif evento.is_action("ui_up"):
		celda += Vector2.UP
	elif evento.is_action("ui_left"):
		celda += Vector2.LEFT
	elif evento.is_action("ui_down"):
		celda += Vector2.DOWN


func _draw() -> void:
	draw_rect(Rect2(-grilla.tamanio_celda / 2, grilla.tamanio_celda), Color.ALICE_BLUE, false, 2.0)

