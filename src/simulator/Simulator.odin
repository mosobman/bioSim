package simulator

import "core:math/rand"
import "core:fmt"


DISPLAY :: [2]uint{64, 64}
SCALE :: 10
RESOLUTION :: [2]uint{DISPLAY.x*SCALE, DISPLAY.y*SCALE}

ENTITY_COUNT :: 40
CYCLE_RATE :: 60

Simulator :: struct {
	display : [DISPLAY.x*DISPLAY.y]u8,
	display_screen : [RESOLUTION.x*RESOLUTION.y]u32,
	displayUpdate  : bool,
	deltaTime : f64,
}

rgb :: proc(r: u8, g: u8, b: u8) -> u32{
	r_ :u32= u32(r)
	g_ :u32= u32(g)
	b_ :u32= u32(b)
	return (r_ << 16) | (g_ << 8) | (b_)
}
rgb_grey :: proc(val: u8) -> u32 {
	return rgb(val,val,val)
}

refresh :: proc(sim: ^Simulator) {
	for X in 0..<DISPLAY.x {
		for Y in 0..<DISPLAY.y {
			for x in X*SCALE..<X*SCALE+SCALE {
				for y in Y*SCALE..<Y*SCALE+SCALE {
					sim.display_screen[x + y*RESOLUTION.x] = rgb_grey(sim.display[X + Y*DISPLAY.x])
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
			sim.display[x + y*DISPLAY.x] = random_byte()
		}
	}
	sim.displayUpdate = true;
	
	fmt.println();
	generateRandomEntities(sim, ENTITY_COUNT)
	fmt.println();

	return sim;
}