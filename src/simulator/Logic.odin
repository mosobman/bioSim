package simulator

import "core:fmt"
import "core:math/rand"


update :: proc(sim: ^Simulator) {
	for &entity in sim.entities {
		tick(&entity)
	}
}

generateRandomEntities :: proc(sim: ^Simulator, count: uint) {
	fmt.printfln("Generated %d entities", count)

	sim.entities = make([]Entity, count)

	for &entity in sim.entities {
		entity.id = rand.uint64();
		entity.pos.x = uint(rand.uint32() % u32(GRID.x));
		entity.pos.y = uint(rand.uint32() % u32(GRID.y));
	}
}
