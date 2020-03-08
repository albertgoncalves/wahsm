WebAssembly.instantiateStreaming(fetch("./bin/main.wasm"))
    .then(function(object) {
        var bytes =
            new Uint8Array(object.instance.exports.memory.buffer, 0, 13);
        var string = new TextDecoder("utf8").decode(bytes);
        console.log(string);
    });
