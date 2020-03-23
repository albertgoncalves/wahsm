(module
  (memory (export "memory") 2)
  (; NOTE:
   ;    memory       | byte offset     | byte length    | layout                | type
   ;   --------------+-----------------+----------------+-----------------------+-----------------
   ;    permutations | 0               | 128*4          | [p1, p2, ...]         | [u32; 128]
   ;    gradients    | 128*4           | 128*4*2        | [x1, y1, x2, y2, ...] | [f32; 128*2]
   ;    pixels       | 128*4 + 128*4*2 | 128*128*4      | [r1, g1, b1, a1, ...] | [u8; 128*128*4]
   ;)
  (global $N    i32 (i32.const 128))
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
  (func $get_perm (param $i i32) (result i32)
    (i32.load offset=0 align=4 (local.get $i))
  )
  (func $set_perm (param $i i32) (param $p i32)
    (i32.store offset=0 align=4 (local.get $i) (local.get $p))
  )
  (func $get_gradient_index (param $i i32) (result i32)
    (i32.shl (local.get $i) (i32.const 3))
  )
  (func $set_gradient (param $i i32) (param $x f32) (param $y f32)
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
    (call $set_perm (i32.shl (i32.const 0) (i32.const 2)) (i32.const 8))
    (call $set_perm (i32.shl (i32.const 7) (i32.const 2)) (i32.const 9))
    (call $set_perm (i32.shl (i32.const 126) (i32.const 2)) (i32.const 10))
    (call $set_perm (i32.shl (i32.const 127) (i32.const 2)) (i32.const 11))
    (call $set_gradient
      (call $get_gradient_index (i32.const 126))
      (f32.const 2.25)
      (f32.const 3.25)
    )
    (call $set_gradient
      (call $get_gradient_index (i32.const 127))
      (f32.const 4.5)
      (f32.const 5.5)
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
