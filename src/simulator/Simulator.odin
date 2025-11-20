package simulator

import "core:mem"
import "core:math/rand"
import "core:fmt"


R :: 12
GRID :: [2]uint{10*R, 9*R}
SCALE :: 4
RESOLUTION :: [2]uint{GRID.x*SCALE, GRID.y*SCALE}

ENTITY_COUNT :: 500
CYCLE_RATE :: 60

Simulator :: struct {
	display_screen : [RESOLUTION.x*RESOLUTION.y]u32,
	displayUpdate  : bool,
	deltaTime : f64,
	epoch: u64,
	toEpoch: bool,
	steps: uint,

	entities: []Entity
}

rgb :: proc(r,g,b: u8) -> u32 {
	r_ := u32(r)
	g_ := u32(g)
	b_ := u32(b)
	return (r_ << 16) | (g_ << 8) | (b_)
}

refresh :: proc(sim: ^Simulator) {
	for X in 0..<GRID.x {
		for Y in 0..<GRID.y {
			for x in X*SCALE..<X*SCALE+SCALE {
				for y in Y*SCALE..<Y*SCALE+SCALE {
					sim.display_screen[x + y*RESOLUTION.x] = pass_for_evolution(X,Y) ? rgb(20,200,20) : rgb(0,0,0)
				}
			}
		}
	}
	//mem.zero(raw_data(&sim.display_screen), len(sim.display_screen)*size_of(sim.display_screen[0]))
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
	sim.toEpoch = true;
}