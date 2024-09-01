class_name OverlayUnidades
extends TileMap


func draw(celdas: Array) -> void:
	clear()
	for celda in celdas:
		set_cell(0, celda, 0, Vector2i(0,0))
