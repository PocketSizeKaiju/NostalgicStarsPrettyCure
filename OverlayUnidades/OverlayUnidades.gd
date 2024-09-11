class_name OverlayUnidades
extends TileMap


func dibujar_celdas_caminables(celdas: Array) -> void:
	#clear()
	for celda in celdas:
		set_cell(0, celda, 0, Vector2i(0,0))

func dibujar_celdas_atacables(celdas: Array) -> void:
	for celda in celdas:
		set_cell(0, celda, 1, Vector2i(0,0))
