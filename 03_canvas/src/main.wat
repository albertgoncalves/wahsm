(module
  (memory (export "memory") 4)
  (func (export "main") (param $t i32)
    (local $x i32)
    (local $y i32)
    (local $offset i32)
    (local $y_offset i32)
    (local $y_width i32)
    (local $red i32)
    (local $green i32)
    (local $blue i32)
    (block $break
      (local.set $offset (i32.shr_u (local.get $t) (i32.const 4)))
      (local.set $y (i32.const 0))
      (loop $y_continue
        (local.set $y_offset
          (i32.rem_u
            (i32.add (local.get $y) (local.get $offset))
            (i32.const 256)
          )
        )
        (; NOTE: (y * 256) == (y << 8) ;)
        (local.set $y_width (i32.shl (local.get $y) (i32.const 8)))
        (local.set $x (i32.const 0))
        (loop $x_continue
          (local.set $red
            (i32.xor
              (i32.rem_u
                (i32.add (local.get $x) (local.get $offset))
                (i32.const 256)
              )
              (local.get $y_offset)
            )
          )
          (local.set $green
            (i32.xor
              (i32.rem_u
                (i32.add
                  (i32.shl (local.get $x) (i32.const 1))
                  (local.get $offset)
                )
                (i32.const 256)
              )
              (i32.rem_u
                (i32.add
                  (i32.shl (local.get $y) (i32.const 1))
                  (local.get $offset)
                )
                (i32.const 256)
              )
            )
          )
          (local.set $blue
            (i32.xor
              (i32.rem_u
                (i32.add
                  (i32.shl (local.get $x) (i32.const 2))
                  (local.get $offset)
                )
                (i32.const 256)
              )
              (i32.rem_u
                (i32.add
                  (i32.shl (local.get $y) (i32.const 2))
                  (local.get $offset)
                )
                (i32.const 256)
              )
            )
          )
          (i32.store
            offset=0
            (i32.shl
              (i32.add (local.get $y_width) (local.get $x))
              (i32.const 2)
            )
            (i32.add
              (i32.shl (i32.const 255) (i32.const 24))
              (i32.add
                (i32.shl (local.get $blue) (i32.const 16))
                (i32.add
                  (i32.shl (local.get $green) (i32.const 8))
                  (local.get $red)
                )
              )
            )
          )
          (local.set $x (i32.add (local.get $x) (i32.const 1)))
          (br_if $x_continue (i32.lt_u (local.get $x) (i32.const 256)))
        )
        (local.set $y (i32.add (local.get $y) (i32.const 1)))
        (br_if $y_continue (i32.lt_u (local.get $y) (i32.const 256)))
      )
    )
  )
)
