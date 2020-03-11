(module
  (memory (export "memory") 1)
  (func (export "main")
    (local $i i32)
    (local $n i32)
    (local $offset i32)
    (local $value i32)
    (local.set $i (i32.const 0))
    (local.set $n (i32.const 16))
    (; NOTE:
     ;    do {
     ;        if (i == 5) {
     ;            value = 1 - i
     ;        } else if (15 <= i) {
     ;            break
     ;        } else {
     ;            value = (i << 16) + (i + 1)
     ;        }
     ;        memory[0 + ($x << 2)] = value
     ;        i = i + 1
     ;    } while (i < n)
     ;)
    (block $break
      (loop $continue
        (local.set $value
          (if (result i32) (i32.eq (local.get $i) (i32.const 5))
            (then (i32.sub (i32.const 1) (local.get $i)))
            (else
              (br_if $break (i32.le_u (i32.const 15) (local.get $i)))
              (i32.add
                (i32.shl (local.get $i) (i32.const 16))
                (i32.add (local.get $i) (i32.const 1))
              )
            )
          )
        )
        (i32.store offset=0
          (i32.shl (local.get $i) (i32.const 2))
          (local.get $value)
        )
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br_if $continue (i32.lt_u (local.get $i) (local.get $n)))
      )
    )
  )
)
