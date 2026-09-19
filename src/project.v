/*
 * Animated Space Scene
 *
 * 640x480 VGA
 *
 * Features:
 * - Large bright star field
 * - Twinkling stars
 * - Sun
 * - Mercury
 * - Venus
 * - Earth + Moon
 * - Mars
 * - Jupiter
 * - Saturn + rings
 * - Moving rocket
 */

`default_nettype none

module tt_um_vga_example(
  input  wire [7:0] ui_in,
  output wire [7:0] uo_out,
  input  wire [7:0] uio_in,
  output wire [7:0] uio_out,
  output wire [7:0] uio_oe,
  input  wire       ena,
  input  wire       clk,
  input  wire       rst_n
);

  // ================================================================
  // VGA
  // ================================================================

  wire hsync;
  wire vsync;

  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;

  assign uo_out = {
    hsync,
    B[0], G[0], R[0],
    vsync,
    B[1], G[1], R[1]
  };

  assign uio_out = 0;
  assign uio_oe  = 0;

  wire _unused_ok = &{ena, ui_in, uio_in};

  wire [9:0] x;
  wire [9:0] y;

  wire video_active;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(x),
    .vpos(y)
  );


  // ================================================================
  // FRAME COUNTER
  // ================================================================

  reg [10:0] frame_counter;

  reg [3:0] phase_mercury;
  reg [3:0] phase_venus;
  reg [3:0] phase_earth;
  reg [3:0] phase_mars;
  reg [3:0] phase_jupiter;
  reg [3:0] phase_saturn;
  reg [3:0] phase_moon;

  reg [9:0] rocket_pos;


  // ================================================================
  // ANIMATION UPDATE
  // ================================================================

  always @(posedge clk) begin

    if (~rst_n) begin

      frame_counter <= 0;

      phase_mercury <= 0;
      phase_venus   <= 3;
      phase_earth   <= 6;
      phase_mars    <= 9;
      phase_jupiter <= 12;
      phase_saturn  <= 15;
      phase_moon    <= 0;

      rocket_pos <= 0;

    end

    else if (x == 0 && y == 0) begin

      if (frame_counter == 2047)
        frame_counter <= 0;
      else
        frame_counter <= frame_counter + 1;

      if (frame_counter[2:0] == 0)
        phase_mercury <= phase_mercury + 1;

      if (frame_counter[3:0] == 0)
        phase_venus <= phase_venus + 1;

      if (frame_counter[2:0] == 0)
        phase_earth <= phase_earth + 1;

      if (frame_counter[4:0] == 0)
        phase_mars <= phase_mars + 1;

      if (frame_counter[5:0] == 0)
        phase_jupiter <= phase_jupiter + 1;

      if (frame_counter[6:0] == 0)
        phase_saturn <= phase_saturn + 1;

      if (frame_counter[1:0] == 0)
        phase_moon <= phase_moon + 1;

      if (rocket_pos >= 699)
        rocket_pos <= 0;
      else
        rocket_pos <= rocket_pos + 2;

    end

  end


  // ================================================================
  // COORDINATES
  // ================================================================

  wire signed [10:0] xs =
      $signed({1'b0, x});

  wire signed [10:0] ys =
      $signed({1'b0, y});


  // ================================================================
  // ORBIT FUNCTIONS
  // ================================================================

  function automatic signed [10:0] orbit_x;

    input signed [10:0] radius;
    input [3:0] phase;

    integer factor;

    begin

      case (phase)

        4'd0:  factor = 100;
        4'd1:  factor = 92;
        4'd2:  factor = 71;
        4'd3:  factor = 38;

        4'd4:  factor = 0;

        4'd5:  factor = -38;
        4'd6:  factor = -71;
        4'd7:  factor = -92;

        4'd8:  factor = -100;

        4'd9:  factor = -92;
        4'd10: factor = -71;
        4'd11: factor = -38;

        4'd12: factor = 0;

        4'd13: factor = 38;
        4'd14: factor = 71;
        4'd15: factor = 92;

        default: factor = 0;

      endcase

      orbit_x = (radius * factor) / 100;

    end

  endfunction


  function automatic signed [10:0] orbit_y;

    input signed [10:0] radius;
    input [3:0] phase;

    integer factor;

    begin

      case (phase)

        4'd0:  factor = 0;
        4'd1:  factor = 38;
        4'd2:  factor = 71;
        4'd3:  factor = 92;

        4'd4:  factor = 100;

        4'd5:  factor = 92;
        4'd6:  factor = 71;
        4'd7:  factor = 38;

        4'd8:  factor = 0;

        4'd9:  factor = -38;
        4'd10: factor = -71;
        4'd11: factor = -92;

        4'd12: factor = -100;

        4'd13: factor = -92;
        4'd14: factor = -71;
        4'd15: factor = -38;

        default: factor = 0;

      endcase

      orbit_y = (radius * factor) / 100;

    end

  endfunction


  // ================================================================
  // PLANET POSITIONS
  // ================================================================

  wire signed [10:0] mercury_x =
      320 + orbit_x(50, phase_mercury);

  wire signed [10:0] mercury_y =
      240 + orbit_y(28, phase_mercury);


  wire signed [10:0] venus_x =
      320 + orbit_x(82, phase_venus);

  wire signed [10:0] venus_y =
      240 + orbit_y(46, phase_venus);


  wire signed [10:0] earth_x =
      320 + orbit_x(118, phase_earth);

  wire signed [10:0] earth_y =
      240 + orbit_y(68, phase_earth);


  wire signed [10:0] mars_x =
      320 + orbit_x(155, phase_mars);

  wire signed [10:0] mars_y =
      240 + orbit_y(88, phase_mars);


  wire signed [10:0] jupiter_x =
      320 + orbit_x(195, phase_jupiter);

  wire signed [10:0] jupiter_y =
      240 + orbit_y(112, phase_jupiter);


  wire signed [10:0] saturn_x =
      320 + orbit_x(225, phase_saturn);

  wire signed [10:0] saturn_y =
      240 + orbit_y(130, phase_saturn);


  wire signed [10:0] moon_x =
      earth_x + orbit_x(22, phase_moon);

  wire signed [10:0] moon_y =
      earth_y + orbit_y(22, phase_moon);


  // ================================================================
  // CIRCLE FUNCTION
  // ================================================================

  function automatic in_circle;

    input signed [10:0] px;
    input signed [10:0] py;

    input signed [10:0] cx;
    input signed [10:0] cy;

    input [9:0] r;

    reg signed [11:0] dx;
    reg signed [11:0] dy;

    reg signed [23:0] d2;

    reg [19:0] rr;

    begin

      dx = px - cx;
      dy = py - cy;

      d2 = dx * dx + dy * dy;

      rr = r * r;

      in_circle =
          (d2 <= $signed({1'b0, rr}));

    end

  endfunction


  // ================================================================
  // SUN
  // ================================================================

  wire sun =
      in_circle(
        xs,
        ys,
        320,
        240,
        34
      );


  // ================================================================
  // PLANETS
  // ================================================================

  wire mercury =
      in_circle(
        xs,
        ys,
        mercury_x,
        mercury_y,
        7
      );


  wire venus =
      in_circle(
        xs,
        ys,
        venus_x,
        venus_y,
        11
      );


  wire earth =
      in_circle(
        xs,
        ys,
        earth_x,
        earth_y,
        14
      );


  wire moon =
      in_circle(
        xs,
        ys,
        moon_x,
        moon_y,
        4
      );


  wire mars =
      in_circle(
        xs,
        ys,
        mars_x,
        mars_y,
        10
      );


  wire jupiter =
      in_circle(
        xs,
        ys,
        jupiter_x,
        jupiter_y,
        24
      );


  wire saturn =
      in_circle(
        xs,
        ys,
        saturn_x,
        saturn_y,
        20
      );


  // ================================================================
  // SATURN RINGS
  // ================================================================

  wire saturn_ring_outer =
      in_circle(
        xs,
        ys,
        saturn_x,
        saturn_y,
        32
      );

  wire saturn_ring_inner =
      in_circle(
        xs,
        ys,
        saturn_x,
        saturn_y,
        24
      );

  wire saturn_ring =
      saturn_ring_outer &
      (~saturn_ring_inner);


  // ================================================================
  // STAR FIELD
  // Normal stars are 5x5 pixels
  // ================================================================

  wire stars =

      // Top
      (x >= 18  && x <= 22  && y >= 23  && y <= 27)  |
      (x >= 56  && x <= 60  && y >= 68  && y <= 72)  |
      (x >= 94  && x <= 98  && y >= 30  && y <= 34)  |
      (x >= 138 && x <= 142 && y >= 50  && y <= 54)  |
      (x >= 183 && x <= 187 && y >= 22  && y <= 26)  |
      (x >= 228 && x <= 232 && y >= 76  && y <= 80)  |
      (x >= 273 && x <= 277 && y >= 38  && y <= 42)  |
      (x >= 313 && x <= 317 && y >= 23  && y <= 27)  |
      (x >= 363 && x <= 367 && y >= 58  && y <= 62)  |
      (x >= 408 && x <= 412 && y >= 30  && y <= 34)  |
      (x >= 453 && x <= 457 && y >= 80  && y <= 84)  |
      (x >= 498 && x <= 502 && y >= 33  && y <= 37)  |
      (x >= 548 && x <= 552 && y >= 65  && y <= 69)  |
      (x >= 608 && x <= 612 && y >= 26  && y <= 30)  |

      // Second row
      (x >= 38  && x <= 42  && y >= 128 && y <= 132) |
      (x >= 80  && x <= 84  && y >= 173 && y <= 177) |
      (x >= 118 && x <= 122 && y >= 113 && y <= 117) |
      (x >= 168 && x <= 172 && y >= 153 && y <= 157) |
      (x >= 213 && x <= 217 && y >= 123 && y <= 127) |
      (x >= 258 && x <= 262 && y >= 173 && y <= 177) |
      (x >= 298 && x <= 302 && y >= 118 && y <= 122) |
      (x >= 348 && x <= 352 && y >= 158 && y <= 162) |
      (x >= 388 && x <= 392 && y >= 113 && y <= 117) |
      (x >= 433 && x <= 437 && y >= 173 && y <= 177) |
      (x >= 478 && x <= 482 && y >= 128 && y <= 132) |
      (x >= 528 && x <= 532 && y >= 183 && y <= 187) |
      (x >= 573 && x <= 577 && y >= 138 && y <= 142) |
      (x >= 623 && x <= 627 && y >= 168 && y <= 172) |

      // Middle
      (x >= 13  && x <= 17  && y >= 238 && y <= 242) |
      (x >= 63  && x <= 67  && y >= 283 && y <= 287) |
      (x >= 103 && x <= 107 && y >= 223 && y <= 227) |
      (x >= 153 && x <= 157 && y >= 313 && y <= 317) |
      (x >= 198 && x <= 202 && y >= 258 && y <= 262) |
      (x >= 243 && x <= 247 && y >= 303 && y <= 307) |
      (x >= 283 && x <= 287 && y >= 268 && y <= 272) |
      (x >= 353 && x <= 357 && y >= 298 && y <= 302) |
      (x >= 398 && x <= 402 && y >= 248 && y <= 252) |
      (x >= 443 && x <= 447 && y >= 318 && y <= 322) |
      (x >= 488 && x <= 492 && y >= 273 && y <= 277) |
      (x >= 538 && x <= 542 && y >= 333 && y <= 337) |
      (x >= 583 && x <= 587 && y >= 253 && y <= 257) |
      (x >= 623 && x <= 627 && y >= 308 && y <= 312) |

      // Bottom
      (x >= 28  && x <= 32  && y >= 378 && y <= 382) |
      (x >= 78  && x <= 82  && y >= 428 && y <= 432) |
      (x >= 123 && x <= 127 && y >= 363 && y <= 367) |
      (x >= 173 && x <= 177 && y >= 408 && y <= 412) |
      (x >= 218 && x <= 222 && y >= 448 && y <= 452) |
      (x >= 268 && x <= 272 && y >= 388 && y <= 392) |
      (x >= 318 && x <= 322 && y >= 428 && y <= 432) |
      (x >= 368 && x <= 372 && y >= 373 && y <= 377) |
      (x >= 418 && x <= 422 && y >= 438 && y <= 442) |
      (x >= 463 && x <= 467 && y >= 393 && y <= 397) |
      (x >= 513 && x <= 517 && y >= 448 && y <= 452) |
      (x >= 558 && x <= 562 && y >= 383 && y <= 387) |
      (x >= 608 && x <= 612 && y >= 423 && y <= 427);


  // ================================================================
  // LARGE BRIGHT STARS
  // ================================================================

  wire bright_star_1 =
      ((x >= 68 && x <= 76) && (y >= 54 && y <= 56)) |
      ((x >= 70 && x <= 74) && (y >= 50 && y <= 60));

  wire bright_star_2 =
      ((x >= 241 && x <= 249) && (y >= 54 && y <= 56)) |
      ((x >= 243 && x <= 247) && (y >= 50 && y <= 60));

  wire bright_star_3 =
      ((x >= 471 && x <= 479) && (y >= 54 && y <= 56)) |
      ((x >= 473 && x <= 477) && (y >= 50 && y <= 60));

  wire bright_star_4 =
      ((x >= 71 && x <= 79) && (y >= 349 && y <= 351)) |
      ((x >= 73 && x <= 77) && (y >= 345 && y <= 355));

  wire bright_star_5 =
      ((x >= 181 && x <= 189) && (y >= 349 && y <= 351)) |
      ((x >= 183 && x <= 187) && (y >= 345 && y <= 355));

  wire bright_star_6 =
      ((x >= 426 && x <= 434) && (y >= 364 && y <= 366)) |
      ((x >= 428 && x <= 432) && (y >= 360 && y <= 370));

  wire bright_star_7 =
      ((x >= 576 && x <= 584) && (y >= 354 && y <= 356)) |
      ((x >= 578 && x <= 582) && (y >= 350 && y <= 360));


  wire bright_stars =
      bright_star_1 |
      bright_star_2 |
      bright_star_3 |
      bright_star_4 |
      bright_star_5 |
      bright_star_6 |
      bright_star_7;


  // ================================================================
  // TWINKLING
  // ================================================================

  wire twinkle =
      frame_counter[4];

  wire twinkling_stars =
      bright_stars & twinkle;


  // ================================================================
  // ROCKET
  // ================================================================

  wire signed [10:0] rocket_x =
      -30 + rocket_pos;

  wire signed [10:0] rocket_y =
      105 + orbit_y(18, frame_counter[7:4]);


  wire rocket_body =

      (xs >= rocket_x - 14) &
      (xs <= rocket_x + 9)  &
      (ys >= rocket_y - 7)  &
      (ys <= rocket_y + 7);


  wire rocket_nose =

      in_circle(
        xs,
        ys,
        rocket_x + 10,
        rocket_y,
        8
      );


  wire rocket_window =

      in_circle(
        xs,
        ys,
        rocket_x + 2,
        rocket_y,
        3
      );


  wire rocket_fin_top =

      (xs >= rocket_x - 9) &
      (xs <= rocket_x - 1) &
      (ys >= rocket_y - 13) &
      (ys <= rocket_y - 6);


  wire rocket_fin_bottom =

      (xs >= rocket_x - 9) &
      (xs <= rocket_x - 1) &
      (ys >= rocket_y + 6) &
      (ys <= rocket_y + 13);


  wire rocket_flame =

      in_circle(
        xs,
        ys,
        rocket_x - 18,
        rocket_y,
        7
      );


  wire rocket_inner_flame =

      in_circle(
        xs,
        ys,
        rocket_x - 20,
        rocket_y,
        3
      );


  wire rocket =
      rocket_body       |
      rocket_nose       |
      rocket_fin_top    |
      rocket_fin_bottom |
      rocket_flame;


  // ================================================================
  // COLORS
  // ================================================================

  localparam [5:0]

    SPACE_COLOR =
        6'b00_00_00,

    STAR_COLOR =
        6'b11_11_11,

    BRIGHT_STAR_COLOR =
        6'b11_11_11,

    SUN_COLOR =
        6'b11_11_00,

    MERCURY_COLOR =
        6'b11_11_11,

    VENUS_COLOR =
        6'b11_10_01,

    EARTH_COLOR =
        6'b00_10_11,

    MOON_COLOR =
        6'b11_11_11,

    MARS_COLOR =
        6'b11_01_00,

    JUPITER_COLOR =
        6'b11_10_10,

    SATURN_COLOR =
        6'b10_10_01,

    RING_COLOR =
        6'b11_11_01,

    ROCKET_BODY_COLOR =
        6'b11_11_11,

    ROCKET_WINDOW_COLOR =
        6'b00_10_11,

    ROCKET_FIN_COLOR =
        6'b11_01_01,

    ROCKET_FLAME_COLOR =
        6'b11_10_00,

    ROCKET_INNER_FLAME_COLOR =
        6'b11_11_11;


  // ================================================================
  // PIXEL COLOR
  // ================================================================

  reg [5:0] pixel_color;


  always @* begin

    pixel_color = SPACE_COLOR;

    // Stars
    if (stars)
      pixel_color = STAR_COLOR;

    if (twinkling_stars)
      pixel_color = BRIGHT_STAR_COLOR;


    // Saturn ring
    if (saturn_ring)
      pixel_color = RING_COLOR;


    // Planets
    if (saturn)
      pixel_color = SATURN_COLOR;

    if (jupiter)
      pixel_color = JUPITER_COLOR;

    if (mars)
      pixel_color = MARS_COLOR;

    if (moon)
      pixel_color = MOON_COLOR;

    if (earth)
      pixel_color = EARTH_COLOR;

    if (venus)
      pixel_color = VENUS_COLOR;

    if (mercury)
      pixel_color = MERCURY_COLOR;


    // Sun
    if (sun)
      pixel_color = SUN_COLOR;


    // Rocket
    if (rocket_flame)
      pixel_color = ROCKET_FLAME_COLOR;

    if (rocket_inner_flame)
      pixel_color = ROCKET_INNER_FLAME_COLOR;

    if (rocket_fin_top | rocket_fin_bottom)
      pixel_color = ROCKET_FIN_COLOR;

    if (rocket_body | rocket_nose)
      pixel_color = ROCKET_BODY_COLOR;

    if (rocket_window)
      pixel_color = ROCKET_WINDOW_COLOR;

  end


  // ================================================================
  // VGA OUTPUT
  // ================================================================

  assign {R, G, B} =

      (~video_active)
      ? 6'b00_00_00
      : pixel_color;


endmodule