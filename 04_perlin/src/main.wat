(module
  (memory (export "memory") 2)
  (; NOTE:
   ;    memory       | start (bytes)     | length (bytes) | layout                | type
   ;   --------------+-------------------+----------------+-----------------------+-----------------
   ;    gradients    | 0                 | 128*2*2        | [x1, y1, ...]         | [u16; N * 2]
   ;    permutations | 128*2*2           | 128*4*2        | [x1, y1, ...]         | [f32; N * 2]
   ;    pixels       | 128*2*2 + 128*4*2 | 128*128*4      | [r1, g1, b1, a1, ...] | [u8; N * N * 4]
   ;)
  (global $N    i32 (i32.const 128))
  (global $NN   i32 (i32.const 16384))     (; NOTE: N * N == NN ;)
  (global $T    i32 (i32.const 5))
  (global $PI_2 f32 (f32.const 6.2831855)) (; NOTE: PI * 2.0 == PI_2 ;)
  (global $Z    f32 (f32.const 0.004))
  (global $W    f32 (f32.const 2.5))
  (func $get_gradient
      (param $origin_x   f32) (param $origin_y   f32)
      (param $gradient_x f32) (param $gradient_y f32)
      (param $point_x    f32) (param $point_y    f32)
      (result f32)
    (f32.add
      (f32.mul
        (f32.sub (local.get $point_x) (local.get $origin_x))
        (local.get $gradient_x)
      )
      (f32.mul
        (f32.sub (local.get $point_y) (local.get $origin_y))
        (local.get $gradient_y)
      )
    )
  )
  (func $smooth (param $x f32) (result f32)
    (f32.mul
      (local.get $x)
      (f32.mul
        (local.get $x)
        (f32.sub (f32.const 3.0) (f32.mul (f32.const 2.0) (local.get $x)))
      )
    )
  )
  (func $lerp (param $a f32) (param $b f32) (param $weight f32) (result f32)
    (f32.add
      (local.get $a)
      (f32.mul (local.get $weight) (f32.sub (local.get $b) (local.get $a)))
    )
  )
  (func $get_gradient_index (param $i i32) (result i32)
    (i32.shl (local.get $i) (i32.const 2))
  )
  (func $get_gradient_x (param $i i32) (result i32)
    (i32.load16_u offset=0 align=2 (local.get $i))
  )
  (func $get_gradient_y (param $i i32) (result i32)
    (i32.load16_u offset=2 align=2 (local.get $i))
  )
  (func $set_gradient (param $i i32) (param $x i32) (param $y i32)
    (i32.store16 offset=0 align=2 (local.get $i) (local.get $x))
    (i32.store16 offset=2 align=2 (local.get $i) (local.get $y))
  )
  (func $get_perm_index (param $i i32) (result i32)
    (i32.shl (local.get $i) (i32.const 3))
  )
  (func $get_perm_x (param $i i32) (result f32)
    (f32.load offset=512 align=4 (local.get $i))
  )
  (func $get_perm_y (param $i i32) (result f32)
    (f32.load offset=516 align=4 (local.get $i))
  )
  (func $set_perm (param $i i32) (param $x f32) (param $y f32)
    (f32.store offset=512 align=4 (local.get $i) (local.get $x))
    (f32.store offset=516 align=4 (local.get $i) (local.get $y))
  )
  (func $set_pixel
      (param $j i32) (param $i i32)
      (param $r i32) (param $g i32) (param $b i32) (param $a i32)
    (; NOTE:
     ;    j -> column -> x
     ;    i -> row    -> y
     ;)
    (local $index i32)
    (local.set $index
      (i32.shl
        (i32.add (i32.shl (local.get $i) (i32.const 7)) (local.get $j))
        (i32.const 2)
      )
    )
    (i32.store8 offset=1536 align=1 (local.get $index) (local.get $r))
    (i32.store8 offset=1537 align=1 (local.get $index) (local.get $g))
    (i32.store8 offset=1538 align=1 (local.get $index) (local.get $b))
    (i32.store8 offset=1539 align=1 (local.get $index) (local.get $a))
  )
  (func (export "main")
    (call $set_gradient
      (call $get_gradient_index (i32.const 126))
      (i32.const 2)
      (i32.const 3)
    )
    (call $set_gradient
      (call $get_gradient_index (i32.const 127))
      (i32.const 4)
      (i32.const 5)
    )
    (call $set_perm
      (call $get_perm_index (i32.const 0))
      (f32.const 9.1)
      (f32.const 9.2)
    ) (call $set_perm (call $get_perm_index (i32.const 7))
      (f32.const 9.3)
      (f32.const 9.4)
    )
    (call $set_perm
      (call $get_perm_index (i32.const 126))
      (f32.const 10.1)
      (f32.const 10.2)
    )
    (call $set_perm
      (call $get_perm_index (i32.const 127))
      (f32.const 10.3)
      (f32.const 10.4)
    )
    (call $set_pixel
      (i32.const 1)
      (i32.const 1)
      (i32.const 1)
      (i32.const 2)
      (i32.const 3)
      (i32.const 128)
    )
    (call $set_pixel
      (i32.const 127)
      (i32.const 127)
      (i32.const 2)
      (i32.const 3)
      (i32.const 4)
      (i32.const 255)
    )
  )
)
