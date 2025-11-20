package main

import "core:fmt"
import "core:c"
import "core:time"
import simulator "simulator"
import mfb "minifb"


keyboard :mfb.keyboard_func: proc(window: ^mfb.window, key: mfb.key, mod: mfb.key_mod, isPressed: c.bool) {
    fmt.println("KEY :", isPressed ? "DOWN" : "UP", ":", key)
    if (!isPressed) {
        if (key == mfb.key.KEY_ESCAPE) {
            mfb.close(window)
        }
    }
}

sim : ^simulator.Simulator

main :: proc() {
    width  := simulator.RESOLUTION.x;
    height := simulator.RESOLUTION.y;
    fmt.printfln("Window Size: (%d, %d) = (%d, %d)*%d", width, height, simulator.DISPLAY.x, simulator.DISPLAY.y, simulator.SCALE)

    mfb.set_target_fps(60)
    window := mfb.open_ex("bioSim Odin", cast(c.uint)width, cast(c.uint)height, cast(c.uint)mfb.window_flags.RESIZABLE);
    if window == nil {
        fmt.println("Failed to open window");
        return;
    }
    mfb.set_keyboard_callback(window, keyboard);

    sim = simulator.makeSimulator();

    old := time.now()._nsec
    ticks :u64= 0
    for ;; {
        value := mfb.update(window, raw_data(&sim.display_screen))
        if value != mfb.update_state.OK {
            fmt.println("Window State: ", value)
            break
        }

        simulator.update(sim)
        if sim.displayUpdate do simulator.refresh(sim)
        
        // avoid burning 100% CPU
        mfb.wait_sync(window);
        //time.accurate_sleep(16 * time.Millisecond)

        sim.deltaTime = f64(time.now()._nsec - old) / 1e9
        old = time.now()._nsec

        if ticks%(60*10) == 0 {
            fmt.printfln("FPS: %f", 1.0/sim.deltaTime)
            fmt.printfln("DeltaTime: %f ms", 1000.0*sim.deltaTime)
            fmt.printfln("Entity Count: %d", len(sim.entities))
        }
        ticks += 1
    }
    free(sim)

    mfb.close(window);
}
