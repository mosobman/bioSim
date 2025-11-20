package simulator

import "core:fmt"
import "core:math/rand"


update :: proc(sim: ^Simulator) {
	for &entity in sim.entities {
		tick(&entity)
	}
}

generateRandomEntities :: proc(sim: ^Simulator, count: uint) {
	fmt.printfln("Generating %d entities", count)

	sim.entities = make([]Entity, count)

	for &entity in sim.entities {
		entity = make_entity(
			rand.uint64(),
			uint(rand.uint32() % u32(GRID.x)),
			uint(rand.uint32() % u32(GRID.y))
		);
	}

	fmt.printfln("Generated %d entities", count)
}
