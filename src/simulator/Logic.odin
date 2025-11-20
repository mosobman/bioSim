package simulator

import "core:fmt"


update :: proc(sim: ^Simulator) {

}

generateRandomEntities :: proc(sim: ^Simulator, count: uint) {
	fmt.printfln("Generated %d entities", count)
}
