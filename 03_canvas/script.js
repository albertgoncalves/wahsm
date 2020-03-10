window.onload = function() {
    WebAssembly.instantiateStreaming(fetch("./bin/main.wasm"))
        .then(function(object) {
            var canvas = document.getElementById("canvas");
            var ctx = canvas.getContext("2d");
            var buffer = new Uint8Array(
                object.instance.exports.memory.buffer,
                0,
                (canvas.width * canvas.height) << 2,
            );
            var imageData = ctx.createImageData(canvas.width, canvas.height);
            function loop(t) {
                window.requestAnimationFrame(loop);
                object.instance.exports.main(t);
                imageData.data.set(buffer);
                ctx.putImageData(imageData, 0, 0);
            }
            loop(0);
        });
};
