(module
  (memory (export "memory") 4)
  (func (export "main") (param $_t i32)
    (local $x i32)
    (local $y i32)
    (local $t i32)
    (local $y_t0 i32)
    (local $y_t1 i32)
    (local $y_t2 i32)
    (local $y_offset i32)
    (local $red i32)
    (local $green i32)
    (local $blue i32)
    (local $index i32)
    (local.set $t (i32.shr_u (local.get $_t) (i32.const 4)))
    (local.set $y (i32.const 0))
    (loop $y_continue
      (local.set $y_t0
        (; NOTE: (k % 256) == (k & (256 - 1)) ;)
        (i32.and (i32.add (local.get $y) (local.get $t)) (i32.const 255))
      )
      (local.set $y_t1
        (i32.and
          (i32.add (i32.shl (local.get $y) (i32.const 1)) (local.get $t))
          (i32.const 255)
        )
      )
      (local.set $y_t2
        (i32.and
          (i32.add (i32.shl (local.get $y) (i32.const 2)) (local.get $t))
          (i32.const 255)
        )
      )
      (; NOTE: (k * 256) == (k << 8) ;)
      (local.set $y_offset (i32.shl (local.get $y) (i32.const 8)))
      (local.set $x (i32.const 0))
      (loop $x_continue
        (local.set $red
          (i32.xor
            (i32.and (i32.add (local.get $x) (local.get $t)) (i32.const 255))
            (local.get $y_t0)
          )
        )
        (local.set $green
          (i32.xor
            (i32.and
              (i32.add (i32.shl (local.get $x) (i32.const 1)) (local.get $t))
              (i32.const 255)
            )
            (local.get $y_t1)
          )
        )
        (local.set $blue
          (i32.xor
            (i32.and
              (i32.add (i32.shl (local.get $x) (i32.const 2)) (local.get $t))
              (i32.const 255)
            )
            (local.get $y_t2)
          )
        )
        (local.set $index
          (i32.shl
            (i32.add (local.get $y_offset) (local.get $x))
            (i32.const 2)
          )
        )
        (; NOTE: `https://rsms.me/wasm-intro` ;)
        (i32.store8 offset=0 align=1 (local.get $index) (local.get $red))
        (i32.store8 offset=1 align=1 (local.get $index) (local.get $green))
        (i32.store8 offset=2 align=1 (local.get $index) (local.get $blue))
        (i32.store8 offset=3 align=1 (local.get $index) (i32.const 255))
        (local.set $x (i32.add (local.get $x) (i32.const 1)))
        (br_if $x_continue (i32.lt_u (local.get $x) (i32.const 256)))
      )
      (local.set $y (i32.add (local.get $y) (i32.const 1)))
      (br_if $y_continue (i32.lt_u (local.get $y) (i32.const 256)))
    )
  )
)
