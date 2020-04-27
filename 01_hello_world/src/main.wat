(module
  (memory (export "memory") 1)
  (data (i32.const 0) "Hello, world!")
  (func (export "main")
    (f32.store (i32.const 13) (f32.reinterpret_i32 (i32.const 0x7f7fffff)))
  )
)
