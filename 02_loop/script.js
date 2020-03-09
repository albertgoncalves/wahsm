window.onload = function() {
    WebAssembly.instantiateStreaming(fetch("./bin/main.wasm"))
        .then(function(object) {
            object.instance.exports.main();
            var buffer = object.instance.exports.memory.buffer;
            console.log(new Int32Array(buffer.slice(0, 4 * 10)));
        });
}
