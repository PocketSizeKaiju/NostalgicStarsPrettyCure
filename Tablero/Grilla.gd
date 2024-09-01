class_name Grilla
extends Resource

@export var tamanio := Vector2(20, 20)
@export var tamanio_celda := Vector2(80, 80)

var _mitdad_tamanio_celda = tamanio_celda / 2

func calcular_posicion_mapa(posicion_grilla: Vector2) -> Vector2:
	return posicion_grilla * tamanio_celda + _mitdad_tamanio_celda

func calcular_coordinadas_grilla(posicion_mapa: Vector2) -> Vector2:
	return (posicion_mapa / tamanio_celda).floor()

func dentro_del_limite(coordinadas_celda: Vector2) -> bool:
	var out := coordinadas_celda.x >= 0 and coordinadas_celda.x < tamanio.x
	return out and coordinadas_celda.y >= 0 and coordinadas_celda.y < tamanio.y


func clamp_grilla(posicion_grilla: Vector2) -> Vector2:
	var out := posicion_grilla
	out.x = clamp(out.x, 0, tamanio.x - 1.0)
	out.y = clamp(out.y, 0, tamanio.y - 1.0)
	return out
