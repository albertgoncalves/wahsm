"use strict";

window.onload = function() {
    WebAssembly.instantiateStreaming(fetch("./bin/main.wasm"))
        .then(function(object) {
            var buffer = object.instance.exports.memory.buffer;
            var string =
                new TextDecoder("utf8").decode(new Uint8Array(buffer, 0, 13));
            console.log(string);
            console.log(new Uint32Array(buffer.slice(13, 17)));
            object.instance.exports.main();
            console.log(new Uint32Array(buffer.slice(13, 17)));
        });
};
