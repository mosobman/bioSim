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
create_brain :: proc(input_size, output_size, num_layers: int, nodes_per_layer: []int) -> Brain {
    brain: Brain
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
        current = apply_layer_vectorized(current, layer)
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