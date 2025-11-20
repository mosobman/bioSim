package simulator

import "core:fmt"
import "core:math/rand"


Entity :: struct {
	pos : [2]uint,
	id: u64,
}

tick :: proc(e: ^Entity) {
	if (rand.float32() < 0.25) {
		if rand.float32() < 0.5 do e.pos.x += 1;
		else do e.pos.x -= 1;
	}
	if (rand.float32() < 0.25) {
		if rand.float32() < 0.5 do e.pos.y += 1;
		else do e.pos.y -= 1;
	}
	e.pos.x %= GRID.x
	e.pos.y %= GRID.y
}


stringify :: proc(entity: ^Entity) -> string {
	return fmt.aprintf("Entity(pos=(%d, %d), id=%d)", entity.pos.x, entity.pos.y, entity.id)
}
