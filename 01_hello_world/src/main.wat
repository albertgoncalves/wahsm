(module
  (memory (export "memory") 1)
  (data (i32.const 0) "Hello, world!")
  (func (export "main")
    (i32.store (i32.const 13) (i32.const 300))
    (; NOTE: This de-sugars to
     ;    i32.const 13
     ;    i32.const 300
     ;    i32.store
     ;)
  )
)
