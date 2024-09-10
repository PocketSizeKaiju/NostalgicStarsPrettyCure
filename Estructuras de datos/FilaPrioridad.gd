extends Node
class_name FilaPrioridad

var principio
var nuevo_nodo
var temp

func _init():
	principio = null

func esta_vacia():
	return principio == null

func agregar(valor: Vector2, prioridad: int):
	if esta_vacia():
		principio = NodoEncadenado.new(valor, prioridad)
	elif principio.prioridad > prioridad:
		nuevo_nodo = NodoEncadenado.new(valor, prioridad, principio)
		nuevo_nodo.siguiente = principio
	else:
		temp = principio
		
		while temp.siguiente:
			if prioridad <= temp.siguiente.prioridad:
				break
			
			temp = temp.siguiente
		
		nuevo_nodo = NodoEncadenado.new(valor, prioridad, temp.siguiente)
		temp.siguiente = nuevo_nodo

func quitar():
	if esta_vacia():
		return
	else:
		temp = principio
		principio = principio.siguiente
		return temp
