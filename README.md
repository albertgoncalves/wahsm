# wahsm

Played around with `wasm` via `wat`.
- `03_canvas` is a direct translation of [this](https://github.com/albertgoncalves/werkshop/blob/master/03_canvas_buffer/src/main.ts) [animation](https://albertgoncalves.github.io/werkshop/03_canvas_buffer/index.html)
- `04_perlin` is an animation generated with [Perlin noise](https://en.wikipedia.org/wiki/Perlin_noise), _slow_-motion **gif** captured via [chrome-timeline-to-gif](https://hospodarets.com/demos/chrome-timeline-to-gif/)

<div align="center"><img src="cover.gif"></div>


Needed things
---
*   [Nix](https://nixos.org/nix/)
*   [Disabled cache](https://stackoverflow.com/questions/5690269/disabling-chrome-cache-for-website-development)

Quick start
---
```
$ nix-shell
```
```
[nix-shell:path/to/wahsm]$ cd 03_perlin/
[nix-shell:path/to/wahsm/03_perlin]$ ./main
Serving HTTP on 192.168.?.? port 8080 (http://192.168.?.?:8080/) ...
```
```
[nix-shell:path/to/wahsm]$ cd 04_perlin/
[nix-shell:path/to/wahsm/04_perlin]$ ./main
Serving HTTP on 192.168.?.? port 8080 (http://192.168.?.?:8080/) ...
```
