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
	e.pos.x = uint(((pos_x % int(GRID.x)) + int(GRID.x)) % int(GRID.x))
	e.pos.y = uint(((pos_y % int(GRID.y)) + int(GRID.y)) % int(GRID.y))
}


stringify :: proc(entity: ^Entity) -> string {
	return fmt.aprintf("Entity(pos=(%d, %d), id=%d)", entity.pos.x, entity.pos.y, entity.id)
}

make_entity :: proc(id: u64, x, y: uint) -> Entity {
	// 2 Inputs, 2 Outputs, 1 Hidden Layer (4 nodes)
	brain := create_brain(3, 2, { 4 })

	return Entity{
		pos = {x, y},
		id = id,
		brain = brain,
	}
}
destroy_entity :: proc(e: ^Entity) {
	destroy_brain(&e.brain)
}