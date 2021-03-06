(module
  (memory (export "memory") 2)
  (; NOTE:
   ;    memory       | byte offset   | byte length | layout                | type
   ;   --------------+---------------+-------------+-----------------------+-----------------
   ;    permutations | 0             | 128         | [p1, p2, ...]         | [u8; 128]
   ;    gradients    | 128           | 128*4*2     | [x1, y1, x2, y2, ...] | [f32; 128*2]
   ;    values       | 128 + 128*4*2 | 128*128*4   | [v1, v2, ...]         | [f32; 128*128]
   ;    pixels       | 128 + 128*4*2 | 128*128*4   | [r1, g1, b1, a1, ...] | [u8; 128*128*4]
   ;)
  (global $RESOLUTION f32 (f32.const 32.0))
  (func $get_gradient (param $origin_x f32) (param $origin_y f32)
      (param $gradient_x f32) (param $gradient_y f32) (param $point_x f32)
      (param $point_y f32) (result f32)
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
        (f32.mul
          (local.get $x)
          (f32.add
            (f32.mul
              (local.get $x)
              (f32.sub
                (f32.mul (local.get $x) (f32.const 6.0))
                (f32.const 15.0)
              )
            )
            (f32.const 10.0)
          )
        )
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
          (i32.load8_u offset=0 align=1
            (i32.shl (i32.and (local.get $x) (i32.const 127)) (i32.const 2))
          )
          (i32.load8_u offset=0 align=1
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
        (f32.load offset=128 align=4 (local.get $index))
        (f32.load offset=132 align=4 (local.get $index))
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
        (f32.load offset=128 align=4 (local.get $index))
        (f32.load offset=132 align=4 (local.get $index))
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
        (f32.load offset=128 align=4 (local.get $index))
        (f32.load offset=132 align=4 (local.get $index))
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
        (f32.load offset=128 align=4 (local.get $index))
        (f32.load offset=132 align=4 (local.get $index))
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
  (func (export "main") (param $t f32)
    (local $i i32)
    (local $t_scale f32)
    (local $max f32)
    (local $min f32)
    (local $x i32)
    (local $y i32)
    (local $y_component f32)
    (local $value f32)
    (local $delta f32)
    (local $pixel i32)
    (local.set $t_scale (f32.div (local.get $t) (f32.const 1024.0)))
    (local.set $max (f32.const -inf))
    (local.set $min (f32.const inf))
    (local.set $i (i32.const 0))
    (local.set $y (i32.const 0))
    (loop $y_continue
      (local.set $y_component
        (f32.add
          (f32.div (f32.convert_i32_u (local.get $y)) (global.get $RESOLUTION))
          (local.get $t_scale)
        )
      )
      (local.set $x (i32.const 0))
      (loop $x_continue
        (local.set $value
          (call $get_noise
            (f32.add
              (f32.div
                (f32.convert_i32_u (local.get $x))
                (global.get $RESOLUTION)
              )
              (local.get $t_scale)
            )
            (local.get $y_component)
          )
        )
        (f32.store offset=1152 align=4 (local.get $i) (local.get $value))
        (local.set $i (i32.add (local.get $i) (i32.const 4)))
        (if (f32.lt (local.get $value) (local.get $min))
          (local.set $min (local.get $value))
        )
        (if (f32.lt (local.get $max) (local.get $value))
          (local.set $max (local.get $value))
        )
        (local.set $x (i32.add (local.get $x) (i32.const 1)))
        (br_if $x_continue (i32.ne (local.get $x) (i32.const 128)))
      )
      (local.set $y (i32.add (local.get $y) (i32.const 1)))
      (br_if $y_continue (i32.ne (local.get $y) (i32.const 128)))
    )
    (local.set $delta (f32.sub (local.get $max) (local.get $min)))
    (local.set $i (i32.const 0))
    (loop $i_continue
      (local.set $value
        (f32.mul
          (f32.div
            (f32.sub
              (f32.load offset=1152 align=4 (local.get $i))
              (local.get $min)
            )
            (local.get $delta)
          )
          (f32.const 255.0)
        )
      )
      (local.set $pixel (i32.trunc_f32_u (local.get $value)))
      (i32.store8 offset=1152 align=1 (local.get $i) (local.get $pixel))
      (i32.store8 offset=1153 align=1 (local.get $i) (local.get $pixel))
      (i32.store8 offset=1154 align=1 (local.get $i) (local.get $pixel))
      (i32.store8 offset=1155 align=1 (local.get $i) (i32.const 255))
      (local.set $i (i32.add (local.get $i) (i32.const 4)))
      (br_if $i_continue (i32.ne (local.get $i) (i32.const 65536)))
    )
  )
)
