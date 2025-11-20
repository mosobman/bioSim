package simulator

import "core:mem"
import math "core:math"
import "core:math/rand"

Layer :: struct {
	weights : []f16,
	biases : []f16,
}

Brain :: struct {
	layers : []Layer
}

apply_layer_vectorized :: proc(input: []f16, layer: Layer) -> []f16 {
    output_len := len(layer.biases)
	input_len  := len(input)

    output := make([]f16, output_len)

    // Process all outputs
    for i in 0..<output_len {
        sum: f16 = 0
        
		weights_row := layer.weights[(i*input_len) : ((i+1)*input_len)]
        for j in 0..<input_len {
            sum += input[j] * weights_row[j]
        }
        sum += layer.biases[i]
        output[i] = math.tanh(sum)
    }

	return output
}



random_f16 :: proc() -> f16 {
    return f16(rand.float32() * 2.0 - 1.0)
}
create_layer :: proc(input_size, output_size: int) -> Layer {
    layer: Layer
    layer.weights = make([]f16, input_size * output_size)
    layer.biases  = make([]f16, output_size)

    // Fill with random values
    for i in 0..<len(layer.weights) {
        layer.weights[i] = random_f16()
    }
    for i in 0..<output_size {
        layer.biases[i] = random_f16()
    }

    return layer
}
create_brain :: proc(input_size: int, nodes_per_layer: []int, output_size: int) -> Brain {
    brain: Brain
    num_layers := len(nodes_per_layer)
    brain.layers = make([]Layer, num_layers + 1) // hidden layers + output layer

    prev_size := input_size

    // Hidden layers
    for i in 0..<num_layers {
        layer_size := nodes_per_layer[i]
        brain.layers[i] = create_layer(prev_size, layer_size)
        prev_size = layer_size
    }

    // Output layer
    brain.layers[num_layers] = create_layer(prev_size, output_size)

    return brain
}
feedforward :: proc(input: []f16, brain: Brain) -> []f16 {
    current := input
    for layer in brain.layers {
		prev := current
        current = apply_layer_vectorized(current, layer)

		mem.delete_slice(prev)
    }
    return current
}




destroy_brain :: proc(brain: ^Brain) {
    if brain == nil {
        return
    }

    // Free each layer's weights and biases
    for &layer in brain.layers {
        if layer.weights != nil {
            mem.delete_slice(layer.weights)
            layer.weights = nil
        }
        if layer.biases != nil {
            mem.delete_slice(layer.biases)
            layer.biases = nil
        }
    }

    // Free the layers slice itself
    if brain.layers != nil {
        mem.delete_slice(brain.layers)
        brain.layers = nil
    }
}


// --- GENETICS / EVOLUTION METHODS ---

// Completely resets a brain with new random values
randomize_brain_inplace :: proc(brain: ^Brain) {
    for layer in brain.layers {
        for i in 0..<len(layer.weights) {
            layer.weights[i] = random_f16()
        }
        for i in 0..<len(layer.biases) {
            layer.biases[i] = random_f16()
        }
    }
}

// Modifies existing weights slightly
// rate: 0.0 to 1.0 (Probability of a gene mutating)
// power: Magnitude of mutation (added to existing value)
mutate_brain_inplace :: proc(brain: ^Brain, rate: f32, power: f16) {
    for layer in brain.layers {
        for i in 0..<len(layer.weights) {
            if rand.float32() < rate {
                layer.weights[i] += random_f16() * power
            }
        }
        for i in 0..<len(layer.biases) {
            if rand.float32() < rate {
                layer.biases[i] += random_f16() * power
            }
        }
    }
}

// Copies values from src to dest. 
// Assumes dest has already been allocated with the same topology (layers/sizes) as src.
copy_brain_weights :: proc(dest: ^Brain, src: Brain) {
    if len(dest.layers) != len(src.layers) {
        // Safety: if topology differs, we can't safely copy. 
        // In a real engine you might want to reallocate dest here.
        return 
    }

    for i in 0..<len(src.layers) {
        src_layer := src.layers[i]
        dest_layer := dest.layers[i]

        // Copy built-in copies data between slices
        if len(dest_layer.weights) == len(src_layer.weights) {
            copy(dest_layer.weights, src_layer.weights)
        }
        if len(dest_layer.biases) == len(src_layer.biases) {
            copy(dest_layer.biases, src_layer.biases)
        }
    }
}