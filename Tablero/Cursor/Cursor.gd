@tool
class_name Cursor
extends Node2D

signal aceptar_presionada(celda)
signal movida(nueva_celda)

@export var grilla: Resource
@export var ui_cooldown := 0.1

var es_mouse = false

var celda := Vector2.ZERO:
	set(valor):
		var nueva_celda: Vector2 = grilla.clamp_grilla(valor)
		if nueva_celda.is_equal_approx(celda):
			return

		celda = nueva_celda
		position = grilla.calcular_posicion_mapa(celda)
		emit_signal("movida", celda)
		_timer.start()

@onready var _timer: Timer = $Timer


func _ready() -> void:
	_timer.wait_time = ui_cooldown
	celda = grilla.calcular_coordinadas_grilla(position)
	position = grilla.calcular_posicion_mapa(celda)

func _process(_delta):
	if(es_mouse):
		var coordenadas_grilla = grilla.calcular_coordinadas_grilla(get_global_mouse_position())
		if(celda != coordenadas_grilla):
			celda = coordenadas_grilla

func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseMotion:
		es_mouse = true
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
		es_mouse = false
	elif evento.is_action("ui_up"):
		celda += Vector2.UP
		es_mouse = false
	elif evento.is_action("ui_left"):
		celda += Vector2.LEFT
		es_mouse = false
	elif evento.is_action("ui_down"):
		celda += Vector2.DOWN
		es_mouse = false


func _draw() -> void:
	draw_rect(Rect2(-grilla.tamanio_celda / 2, grilla.tamanio_celda), Color.ALICE_BLUE, false, 2.0)

