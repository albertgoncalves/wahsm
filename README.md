# wahsm

Played around with [wasm](https://webassembly.org/) by way of [wat](https://developer.mozilla.org/en-US/docs/WebAssembly/Understanding_the_text_format).

<div align="center"><img src="cover.gif"></div>

<p align="center">
    <strong>.gif</strong> capture via <a href=https://hospodarets.com/demos/chrome-timeline-to-gif/>chrome-timeline-to-gif</a>
</p>


Needed things
---
*   [Nix](https://nixos.org/download.html)
*   [Disabled cache](https://stackoverflow.com/questions/5690269/disabling-chrome-cache-for-website-development)

Quick start
---
```
$ nix-shell
```
```
[nix-shell:path/to/wahsm]$ cd 03_canvas/
[nix-shell:path/to/wahsm/03_canvas]$ ./main
Serving HTTP on 192.168.?.? port 8080 (http://192.168.?.?:8080/) ...
```
```
[nix-shell:path/to/wahsm]$ cd 04_perlin/
[nix-shell:path/to/wahsm/04_perlin]$ ./main
Serving HTTP on 192.168.?.? port 8080 (http://192.168.?.?:8080/) ...
```
