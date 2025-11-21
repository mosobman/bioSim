package simulator

import "core:thread"
import "core:fmt"
import "core:os"
import "core:math/rand"


pass_for_evolution :: proc(x_, y_: uint) -> bool {
	x := f32(x_)-f32(GRID.x)/3.0
	x2 := f32(x_)-2.0*f32(GRID.x)/3.0
	y := f32(y_)-f32(GRID.y)/3.0
	y1 := f32(y_)-2.0*f32(GRID.y)/3.0
	x3 := f32(x_)-f32(GRID.x)/2.0
	y3 := f32(y_)-3.0*f32(GRID.y)/4.0
	
	return (x*x + y*y) <= (15*15) || (x2*x2 + y1*y1) <= (15*15); // || (abs(x3) <= 40 && abs(y3) <= 10)
}

generateRandomEntities :: proc(sim: ^Simulator, count: uint) {
	fmt.printfln("Generating %d entities", count)

	sim.entities = make([]Entity, count)

	for &entity in sim.entities {
		entity = make_entity(
			rand.uint64() & 0xFFFFFF,
			uint(rand.uint32() % u32(GRID.x)),
			uint(rand.uint32() % u32(GRID.y))
		);
	}

	fmt.printfln("Generated %d entities", count)
}

update :: proc(sim: ^Simulator) {
	if sim.steps%(60*3) == 0 do sim.toEpoch = true;
	if sim.toEpoch {
		// 1. Identify Winners Phase
		winners := make([dynamic]^Entity, 0, len(sim.entities), context.temp_allocator)

		for &e in sim.entities {
			if pass_for_evolution(e.pos.x, e.pos.y) {
				append(&winners, &e)
			}
		}

		lost := 0
		inherited := 0
		scrambled := 0

		// 2. Evolution & Reset Phase
		for &e in sim.entities {
			// Check status before we move them
			is_winner := pass_for_evolution(e.pos.x, e.pos.y)

			if !is_winner {
				lost += 1
				
				// Strategy: 
				// 75% Chance -> Copy from a random winner (if any exist)
				// 25% Chance -> Scramble brain (fresh start)
				should_copy_winner := (rand.float32() > 0.25) && (len(winners) > 0)

				if should_copy_winner {
					inherited += 1
					random_winner_idx := rand.int31_max(i32(len(winners)))
					winner_ptr := winners[random_winner_idx]
					entity_overwrite_brain(&e, winner_ptr)
				} else {
					scrambled += 1
					entity_randomise_brain(&e)
				}
			}

			// 3. Randomize Position for EVERYONE
			e.pos.x = uint(rand.uint32() % u32(GRID.x))
			e.pos.y = uint(rand.uint32() % u32(GRID.y))
		}

		fmt.printfln("Evolved epoch: '% 3d' -> '% 3d'", sim.epoch, sim.epoch+1)
		fmt.printfln("  - % 3d winners", len(winners))
		fmt.printfln("  - % 3d lost (re-rolled)", lost)
		fmt.printfln("    - % 3d inherited (mutated copy)", inherited)
		fmt.printfln("    - % 3d scrambled (fresh random)", scrambled)

		sim.epoch += 1
		sim.toEpoch = false
		sim.steps = 0
	}

	//for &entity in sim.entities {
	//	tick(&entity)
	//}
	//sim.steps += 1
	
	threaded_tick(sim)

}

threaded_tick :: proc(sim: ^Simulator) { // Thread Pool
	sim.steps += 4
	system_thread_count := os.processor_core_count();
	usable_thread_count := max(1, system_thread_count-1)

	task_proc :: proc(t: thread.Task) {
		tick(transmute(^Entity)t.data)
		tick(transmute(^Entity)t.data)
		tick(transmute(^Entity)t.data)
		tick(transmute(^Entity)t.data)
	}

	pool: thread.Pool
	thread.pool_init(&pool, allocator=context.allocator, thread_count=usable_thread_count)
	defer thread.pool_destroy(&pool)


	i := 0
	for &entity in sim.entities {
		// be mindful of the allocator used for tasks. The allocator needs to be thread safe, or be owned by the task for exclusive use
		thread.pool_add_task(&pool, allocator=context.allocator, procedure=task_proc, data=&entity, user_index=i)
		i += 1
	}

	thread.pool_start(&pool)
	thread.pool_finish(&pool)
}
