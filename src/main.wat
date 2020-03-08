(module
  (memory $memory 1)
  (export "memory" (memory $memory))
  (data (i32.const 0) "Hello, world!")
  (func (export "mutate")
    (i32.store (i32.const 13) (i32.const 300))
  )
)
