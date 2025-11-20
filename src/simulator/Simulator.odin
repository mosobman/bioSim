package simulator

import "core:math/rand"
import "core:fmt"


DISPLAY :: [2]uint{64, 64}
SCALE :: 1
RESOLUTION :: [2]uint{DISPLAY.x*SCALE, DISPLAY.y*SCALE}

ENTITY_COUNT :: 40
CYCLE_RATE :: 60

Simulator :: struct {
	display : [DISPLAY.x*DISPLAY.y]u32,
	display_screen : [RESOLUTION.x*RESOLUTION.y]u32,
	displayUpdate  : bool,
	deltaTime : f64,

	entities: []Entity
}


refresh :: proc(sim: ^Simulator) {
	for X in 0..<DISPLAY.x {
		for Y in 0..<DISPLAY.y {
			for x in X*SCALE..<X*SCALE+SCALE {
				for y in Y*SCALE..<Y*SCALE+SCALE {
					sim.display_screen[x + y*RESOLUTION.x] = (sim.display[X + Y*DISPLAY.x])
				}
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
	for x in 0..<DISPLAY.x {
		for y in 0..<DISPLAY.y {
			sim.display[x + y*DISPLAY.x] = rand.uint32()
		}
	}
	sim.displayUpdate = true;
	
	fmt.println();
	generateRandomEntities(sim, ENTITY_COUNT)
	fmt.println();

	return sim;
}