"use strict";

var PI_2 = Math.PI * 2;

function shuffle(array) {
    for (var i = array.length - 1; 0 < i; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var tmp = array[i];
        array[i] = array[j];
        array[j] = tmp;
    }
    return array;
}

window.onload = function() {
    WebAssembly.instantiateStreaming(fetch("./bin/main.wasm"))
        .then(function(object) {
            var canvas = document.getElementById("canvas");
            var ctx = canvas.getContext("2d");
            var memory = object.instance.exports.memory.buffer;
            var byteOffset = {
                permutations: 0,
                gradients: 128 << 2,
                pixels: (128 << 2) * 3,
            };
            var typedLength = {
                permutations: 128,
                gradients: 128 << 1,
                pixels: 128 << 9,
            };
            var permutations = new Int32Array(memory, byteOffset.permutations,
                                              typedLength.permutations);
            var i;
            for (i = 0; i < typedLength.permutations; i++) {
                permutations[i] = i;
            }
            shuffle(permutations);
            var gradients = new Float32Array(memory, byteOffset.gradients,
                                             typedLength.gradient);
            for (i = 0; i < typedLength.gradients; i += 2) {
                var theta = PI_2 * Math.random();
                gradients[i] = Math.cos(theta);
                gradients[i + 1] = Math.sin(theta);
            }
            var pixels =
                new Uint8Array(memory, byteOffset.pixels, typedLength.pixels);
            var imageData = ctx.createImageData(canvas.width, canvas.height);
            function loop(t) {
                window.requestAnimationFrame(loop);
                object.instance.exports.main(t);
                imageData.data.set(pixels);
                ctx.putImageData(imageData, 0, 0);
            }
            loop(0);
        });
};
