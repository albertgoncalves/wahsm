(module
  (memory (export "memory") 2)
  (; NOTE:
   ;    memory       | byte offset     | byte length    | layout                | type
   ;   --------------+-----------------+----------------+-----------------------+-----------------
   ;    permutations | 0               | 128*4          | [p1, p2, ...]         | [u32; 128]
   ;    gradients    | 128*4           | 128*4*2        | [x1, y1, x2, y2, ...] | [f32; 128*2]
   ;    pixels       | 128*4 + 128*4*2 | 128*128*4      | [r1, g1, b1, a1, ...] | [u8; 128*128*4]
   ;)
  (global $T i32 (i32.const 5))
  (global $Z f32 (f32.const 0.0035))
  (global $W f32 (f32.const 2.5))
  (func $get_gradient
      (param $origin_x f32) (param $origin_y f32) (param $gradient_x f32)
      (param $gradient_y f32) (param $point_x f32) (param $point_y f32)
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
  (func $get_gradient_index (param $x i32) (param $y i32) (result i32)
    (i32.shl
      (i32.and
        (i32.add
          (i32.load offset=0 align=4
            (i32.shl (i32.and (local.get $x) (i32.const 127)) (i32.const 2))
          )
          (i32.load offset=0 align=4
            (i32.shl (i32.and (local.get $y) (i32.const 127)) (i32.const 2))
          )
        )
        (i32.const 127)
      )
      (i32.const 2)
    )
  )
  (func $get_noise (param $x f32) (param $y f32) (result f32)
    (local $x_0f f32)
    (local $y_0f f32)
    (local $x_1f f32)
    (local $y_1f f32)
    (local $x_0 i32)
    (local $y_0 i32)
    (local $x_1 i32)
    (local $y_1 i32)
    (local $w_0 f32)
    (local $w_1 f32)
    (local $w_2 f32)
    (local $w_3 f32)
    (local $smooth_x f32)
    (local $smooth_y f32)
    (local $index i32)
    (local.set $x_0f (f32.floor (local.get $x)))
    (local.set $y_0f (f32.floor (local.get $y)))
    (local.set $x_1f (f32.add (local.get $x_0f) (f32.const 1.0)))
    (local.set $y_1f (f32.add (local.get $y_0f) (f32.const 1.0)))
    (local.set $x_0 (i32.trunc_f32_u (local.get $x_0f)))
    (local.set $y_0 (i32.trunc_f32_u (local.get $y_0f)))
    (local.set $x_1 (i32.trunc_f32_u (local.get $x_1f)))
    (local.set $y_1 (i32.trunc_f32_u (local.get $y_1f)))
    (local.set $index
      (call $get_gradient_index (local.get $x_0) (local.get $y_0))
    )
    (local.set $w_0
      (call $get_gradient
        (local.get $x_0f)
        (local.get $y_0f)
        (f32.load offset=512 align=4 (local.get $index))
        (f32.load offset=516 align=4 (local.get $index))
        (local.get $x)
        (local.get $y)
      )
    )
    (local.set $index
      (call $get_gradient_index (local.get $x_1) (local.get $y_0))
    )
    (local.set $w_1
      (call $get_gradient
        (local.get $x_1f)
        (local.get $y_0f)
        (f32.load offset=512 align=4 (local.get $index))
        (f32.load offset=516 align=4 (local.get $index))
        (local.get $x)
        (local.get $y)
      )
    )
    (local.set $index
      (call $get_gradient_index (local.get $x_0) (local.get $y_1))
    )
    (local.set $w_2
      (call $get_gradient
        (local.get $x_0f)
        (local.get $y_1f)
        (f32.load offset=512 align=4 (local.get $index))
        (f32.load offset=516 align=4 (local.get $index))
        (local.get $x)
        (local.get $y)
      )
    )
    (local.set $index
      (call $get_gradient_index (local.get $x_1) (local.get $y_1))
    )
    (local.set $w_3
      (call $get_gradient
        (local.get $x_1f)
        (local.get $y_1f)
        (f32.load offset=512 align=4 (local.get $index))
        (f32.load offset=516 align=4 (local.get $index))
        (local.get $x)
        (local.get $y)
      )
    )
    (local.set $smooth_x
      (call $smooth (f32.sub (local.get $x) (local.get $x_0f)))
    )
    (local.set $smooth_y
      (call $smooth (f32.sub (local.get $y) (local.get $y_0f)))
    )
    (call $lerp
      (call $lerp (local.get $w_0) (local.get $w_1) (local.get $smooth_x))
      (call $lerp (local.get $w_2) (local.get $w_3) (local.get $smooth_x))
      (local.get $smooth_y)
    )
  )
  (func (export "main")
    (local $x i32)
    (local $y i32)
    (local $x_f f32)
    (local $y_f f32)
    (local $y_n i32)
    (local $t i32)
    (local $t_f f32)
    (local $value f32)
    (local $pixel i32)
    (local $max f32)
    (local $min f32)
    (local $delta f32)
    (local $octave f32)
    (local $decay f32)
    (local $i i32)
    (local $index i32)
    (local.set $max (f32.const 0.0))
    (; NOTE: That's close to `f32`'s *max*, right? ;)
    (local.set $min (f32.const 3.4e+38))
    (local.set $y (i32.const 0))
    (loop $y_continue
      (local.set $y_n (i32.shl (local.get $y) (i32.const 7)))
      (local.set $x (i32.const 0))
      (loop $x_continue
        (local.set $x_f (f32.convert_i32_u (local.get $x)))
        (local.set $y_f (f32.convert_i32_u (local.get $y)))
        (local.set $value (f32.const 0))
        (local.set $t (i32.const 0))
        (loop $t_continue
          (local.set $t_f (f32.convert_i32_u (local.get $t)))
          (local.set $octave (f32.mul (global.get $Z) (local.get $t_f)))
          (local.set $decay
            (f32.div
              (global.get $W)
              (f32.mul (local.get $t_f) (local.get $t_f))
            )
          )
          (local.set $value
            (f32.add
              (local.get $value)
              (call $get_noise
                (f32.mul (local.get $x_f) (local.get $octave))
                (f32.mul (local.get $y_f) (local.get $octave))
              )
            )
          )
          (local.set $t (i32.add (local.get $t) (i32.const 1)))
          (br_if $t_continue (i32.lt_u (local.get $t) (global.get $T)))
        )
        (f32.store offset=1536 align=4
          (i32.shl (i32.add (local.get $y_n) (local.get $x)) (i32.const 2))
          (local.get $value)
        )
        (if (f32.lt (local.get $value) (local.get $min))
          (local.set $min (local.get $value))
        )
        (if (f32.lt (local.get $max) (local.get $value))
          (local.set $max (local.get $value))
        )
        (local.set $x (i32.add (local.get $x) (i32.const 1)))
        (br_if $x_continue (i32.lt_u (local.get $x) (i32.const 128)))
      )
      (local.set $y (i32.add (local.get $y) (i32.const 1)))
      (br_if $y_continue (i32.lt_u (local.get $y) (i32.const 128)))
    )
    (local.set $delta (f32.sub (local.get $max) (local.get $min)))
    (local.set $i (i32.const 0))
    (loop $i_continue
      (local.set $index (i32.shl (local.get $i) (i32.const 2)))
      (local.set $value
        (f32.mul
          (f32.div
            (f32.sub
              (f32.load offset=1536 align=4 (local.get $index))
              (local.get $min)
            )
            (local.get $delta)
          )
          (f32.const 255.0)
        )
      )
      (local.set $pixel (i32.trunc_f32_u (local.get $value)))
      (i32.store8 offset=1536 align=1 (local.get $index) (local.get $pixel))
      (i32.store8 offset=1537 align=1 (local.get $index) (local.get $pixel))
      (i32.store8 offset=1538 align=1 (local.get $index) (local.get $pixel))
      (i32.store8 offset=1539 align=1 (local.get $index) (i32.const 255))
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br_if $i_continue (i32.lt_u (local.get $i) (i32.const 16384)))
    )
  )
)
