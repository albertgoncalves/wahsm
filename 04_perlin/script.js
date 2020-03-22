window.onload = function() {
    WebAssembly.instantiateStreaming(fetch("./bin/main.wasm"))
        .then(function(object) {
            var memory = object.instance.exports.memory.buffer;
            var byteOffset = {
                gradients: 0,
                permutations: 128 << 2,
                pixels: (128 << 2) * 3,
            };
            var typedLength = {
                gradients: 128 << 1,
                permutations: 128 << 1,
                pixels: 128 << 9,
            };
            var gradients = new Int16Array(memory, byteOffset.gradients,
                                           typedLength.gradient);
            var permutations = new Float32Array(
                memory, byteOffset.permutations, typedLength.permutations);
            var pixels =
                new Uint8Array(memory, byteOffset.pixels, typedLength.pixels);
            object.instance.exports.main();
            console.log(gradients.slice(126 << 1, 128 << 1));
            console.log(permutations.slice(0, 16));
            console.log(permutations.slice(126 << 1, 128 << 1));
            console.log(pixels.slice((128 << 2) + 4, (128 << 2) + 8));
            console.log(pixels.slice((128 << 9) - 4, 128 << 9));
        });
};
