package simulator

import "core:mem"
import "core:math/rand"
import "core:fmt"


R :: 25
GRID :: [2]uint{16*R, 9*R}
SCALE :: 2
RESOLUTION :: [2]uint{GRID.x*SCALE, GRID.y*SCALE}

ENTITY_COUNT :: 1000
CYCLE_RATE :: 60

Simulator :: struct {
	display_screen : [RESOLUTION.x*RESOLUTION.y]u32,
	displayUpdate  : bool,
	deltaTime : f64,
	epoch: u64,

	entities: []Entity
}


refresh :: proc(sim: ^Simulator) {
	//for X in 0..<DISPLAY.x {
	//	for Y in 0..<DISPLAY.y {
	//		for x in X*SCALE..<X*SCALE+SCALE {
	//			for y in Y*SCALE..<Y*SCALE+SCALE {
	//				sim.display_screen[x + y*RESOLUTION.x] = (sim.display[X + Y*DISPLAY.x])
	//			}
	//		}
	//	}
	//}
	mem.zero(raw_data(&sim.display_screen), len(sim.display_screen)*size_of(sim.display_screen[0]))
	for &entity in sim.entities {
		X := entity.pos.x;
		Y := entity.pos.y;
		for x in (X*SCALE)..<((X*SCALE)+SCALE) {
			for y in (Y*SCALE)..<((Y*SCALE)+SCALE) {
				sim.display_screen[x + y*RESOLUTION.x] = u32(entity.id)
			}
		}
	}

	sim.displayUpdate = true;
}

random_byte :: proc() -> u8 {
	return u8(rand.uint32() & 0xFF)
}

makeSimulator :: proc() -> ^Simulator {
	sim := new(Simulator)
	// 32-bit RGBA or BGRA depending on your choice; miniFB accepts either (ARGB)
	sim.displayUpdate = true;
	
	fmt.println();
	generateRandomEntities(sim, ENTITY_COUNT)
	fmt.println();

	return sim;
}

evolve :: proc(sim: ^Simulator) {
	fmt.printfln("Evolving epoch: '% 3d' -> '% 3d'", sim.epoch, sim.epoch+1)
	sim.epoch += 1;
}