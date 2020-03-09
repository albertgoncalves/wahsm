(module
  (memory (export "memory") 1)
  (func (export "main")
    (local $i i32)
    (local $n i32)
    (local $offset i32)
    (local $value i32)
    (local.set $i (i32.const 0))
    (local.set $n (i32.const 16))
    (block  (; NOTE: `labelidx 1` ;)
      (loop (; NOTE: `labelidx 0` ;)
        (local.set
          $value
          (if
            (result i32)
            (; NOTE:
             ;  if (i == 5) {
             ;    (i << 16) + (i + 1)
             ;  } else if (i < 15) {
             ;    1 - i
             ;  } else {
             ;    return
             ;  }
             ;)
            (i32.eq (local.get $i) (i32.const 5))
            (then (i32.sub (i32.const 1) (local.get $i)))
            (else
              (if
                (result i32)
                (i32.lt_s (local.get $i) (i32.const 15))
                (then
                  (i32.add
                    (i32.shl (local.get $i) (i32.const 16))
                    (i32.add (local.get $i) (i32.const 1))
                  )
                )
                (else return)
              )
            )
          )
        )
        (; NOTE: memory[0x00 + ($x << 2)] = $value;)
        (i32.store
          offset=0x00
          (i32.shl (local.get $i) (i32.const 2))
          (local.get $value)
        )
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br_if 1 (i32.eq (local.get $i) (local.get $n)))
        (br 0)
      )
    )
  )
)
