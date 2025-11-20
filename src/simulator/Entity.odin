package simulator

import "core:fmt"
import "core:mem"
import "core:math/rand"
import math "core:math"


Entity :: struct {
	pos : [2]uint,
	brain: Brain,
	id: u64,
}

tick :: proc(e: ^Entity) {
	// 1. Prepare Inputs
	// We normalize inputs by GRID size if possible so they are 0.0 - 1.0.
	// If inputs are too large (like raw integer coordinates), tanh saturates 
	// and the brain stops learning/reacting.
	inputs := make([]f16, 3)
	inputs[0] = 1.0-(f16(e.pos.x) / f16(GRID.x))
	inputs[1] = 1.0-(f16(e.pos.y) / f16(GRID.y))
	inputs[2] = (f16(rand.float32())) * 2.0 - 1.0
	
	// 2. Process Brain
	// feedforward allocates a new slice for the result, we must delete it.
	outputs := feedforward(inputs, e.brain)
	
	// Clean up inputs immediately
	// mem.delete(inputs) 
	// Ensure outputs are cleaned up at end of scope
	defer mem.delete(outputs)

	// 3. Interpret Outputs (-1 to 1)
	// Output 0: X Axis Movement
	// Value magnitude determines probability, Sign determines direction.
	val_x := outputs[0]
	prob_x := math.abs(val_x)

	pos_x := int(e.pos.x)
	pos_y := int(e.pos.y)
	
	if f16(rand.float32()) < prob_x {
		if val_x > 0 do pos_x += 1
		else do pos_x -= 1
	}

	// Output 1: Y Axis Movement
	val_y := outputs[1]
	prob_y := math.abs(val_y)

	if f16(rand.float32()) < prob_y {
		if val_y > 0 do pos_y += 1
		else do pos_y -= 1
	}

	// 4. Wrap around grid
	pos_x = min(max(pos_x, 0), int(GRID.x)-1)
	pos_y = min(max(pos_y, 0), int(GRID.y)-1)
	e.pos.x = uint(((pos_x % int(GRID.x)) + int(GRID.x)) % int(GRID.x))
	e.pos.y = uint(((pos_y % int(GRID.y)) + int(GRID.y)) % int(GRID.y))
}


stringify :: proc(entity: ^Entity) -> string {
	return fmt.aprintf("Entity(pos=(%d, %d), id=%d)", entity.pos.x, entity.pos.y, entity.id)
}

make_entity :: proc(id: u64, x, y: uint) -> Entity {
	// 2 Inputs, 2 Outputs, 1 Hidden Layer (4 nodes)
	brain := create_brain(3, { 5, 8, 8, 5 }, 2)

	return Entity{
		pos = {x, y},
		id = id,
		brain = brain,
	}
}
destroy_entity :: proc(e: ^Entity) {
	destroy_brain(&e.brain)
}





// --- EVOLUTION HELPERS ---

// 1. Randomise inplace
entity_randomise_brain :: proc(e: ^Entity) {
	randomize_brain_inplace(&e.brain)
}

// 2. Slightly mutate
// rate=0.1 means 10% chance per weight to mutate
// power=0.2 means the weight changes by a random value between -0.2 and +0.2
entity_mutate_brain :: proc(e: ^Entity) {
	mutate_brain_inplace(&e.brain, 0.05, 0.1)
}

// 3. Overwrite target with source + mutation
entity_overwrite_brain :: proc(target: ^Entity, source: ^Entity) {
	// First, copy the brain structure values
	copy_brain_weights(&target.brain, source.brain)
	
	// Then apply mutation to the target so it's not an exact clone
	//entity_mutate_brain(target)
}