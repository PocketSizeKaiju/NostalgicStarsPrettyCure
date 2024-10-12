extends TileMapLayer
var datos_movimiento

func _ready():
	datos_movimiento = tile_set.datos_movimiento


func obtener_costos_movimiento(grilla: Grilla):
	var costos_movimiento = []
	for y in range(grilla.tamanio.y):
		costos_movimiento.append([])
		for x in range(grilla.tamanio.x):
			#Esto requiere que todas las celdas con un costo de movimiento esten en la capa 0 del mapa
			var celda = get_cell_source_id(Vector2i(x, y))
			var costo_movimento = datos_movimiento.get(celda)
			costos_movimiento[y].append(costo_movimento)
	return costos_movimiento
