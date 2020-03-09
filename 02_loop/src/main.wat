(module
  (memory (export "memory") 1)
  (func (export "main")
    (local $i i32)
    (local $n i32)
    (local $offset i32)
    (local $index i32)
    (local $value i32)
    (local.set $i (i32.const 0))
    (local.set $n (i32.const 10))
    (local.set $offset (i32.const 4))
    (block
      (loop
        (local.set
          $value
          (i32.add
            (i32.mul (local.get $i) (i32.const 900000))
            (local.get $i)
          )
        )
        (local.set
          $index
          (i32.mul (local.get $i) (local.get $offset))
        )
        (i32.store (local.get $index) (local.get $value))
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br_if 1 (i32.eq (local.get $i) (local.get $n)))
        (br 0)
      )
    )
  )
)
