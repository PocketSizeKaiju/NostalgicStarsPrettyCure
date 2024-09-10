extends Node
class_name NodoEncadenado

var valor
var prioridad: int
var siguiente: NodoEncadenado

func _init(valor_nodo: Vector2, prioridad_nodo: int, siguiente_nodo: NodoEncadenado = null):
	valor = valor_nodo
	prioridad = prioridad_nodo
	siguiente = siguiente_nodo

func set_valor(nuevo_valor: Vector2):
	valor = nuevo_valor

func set_prioridad(nueva_prioridad: int):
	prioridad = nueva_prioridad

func set_siguiente(nuevo_siguiente: NodoEncadenado):
	siguiente = nuevo_siguiente
