@tool
class_name Unidad
extends Path2D

signal termino_caminar

@export var grilla: Resource
@export var es_enemigo: bool
@export var esta_esperando := false
@export var rango_movimiento := 6
@export var velocidad_movida := 600.0
@export var rango_ataque := 0

@export var skin: Texture:
	set(value):
		skin = value
		if not _sprite:
			await ready
		_sprite.texture = value
@export var skin_offset := Vector2.ZERO:
	set(value):
		skin_offset = value
		if not _sprite:
			await ready
		_sprite.position = value

var celda := Vector2.ZERO:
	set(value):
		celda = grilla.clamp_grilla(value)
var esta_seleccionada := false:
	set(value):
		esta_seleccionada = value
		if esta_seleccionada:
			_anim_player.play("seleccionar")
		else:
			_anim_player.play("inactivo")

var _esta_caminando := false:
	set(value):
		_esta_caminando = value
		set_process(_esta_caminando)

@onready var _sprite: Sprite2D = $PathFollow2D/Sprite
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	set_process(false)
	_path_follow.rotates = false
	
	celda = grilla.calcular_coordinadas_grilla(position)
	position = grilla.calcular_posicion_mapa(celda)

	if not Engine.is_editor_hint():
		curve = Curve2D.new()


func _process(delta: float) -> void:
	_path_follow.progress += velocidad_movida * delta
	
	if _path_follow.progress_ratio >= 1.0:
		_esta_caminando = false
		_path_follow.progress = 0.00001
		position = grilla.calcular_posicion_mapa(celda)
		curve.clear_points()
		emit_signal("termino_caminar")


func caminando(camino: PackedVector2Array) -> void:
	if camino.is_empty():
		return
	
	curve.add_point(Vector2.ZERO)
	for punto in camino:
		curve.add_point(grilla.calcular_posicion_mapa(punto) - position)
	celda = camino[-1]
	_esta_caminando = true
