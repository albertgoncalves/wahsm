window.onload = function() {
    WebAssembly.instantiateStreaming(fetch("./bin/main.wasm"))
        .then(function(object) {
            var memory = object.instance.exports.memory.buffer;
            var byteOffset = {
                gradients: 0,
                permutations: 128 << 2,
            };
            var typedLength = {
                gradients: 128 << 1,
                permutations: 128 << 1,
            };
            var gradients = new Int16Array(memory, byteOffset.gradients,
                                           typedLength.gradient);
            var permutations = new Float32Array(
                memory, byteOffset.permutations, typedLength.permutations);
            object.instance.exports.main();
            console.log(gradients.slice(126 << 1, 128 << 1));
            console.log(permutations.slice(0, 16));
            console.log(permutations.slice(126 << 1, 128 << 1));
        });
};
