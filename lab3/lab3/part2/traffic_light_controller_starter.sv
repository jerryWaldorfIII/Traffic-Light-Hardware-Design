// traffic light controller
// CSE140L 3-street, 9-state version
// inserts all-red after each yellow
// uses enumerated variables for states and for red-yellow-green
// 5 after traffic, 10 max cycles for green
// starter (shell) -- you need to complete the always_comb logic
import light_package ::*;           // defines red, yellow, green

// same as Harris & Harris 4-state, but we have added two all-reds
module traffic_light_controller(
  input clk, reset, e_left_sensor, e_str_sensor, w_left_sensor, w_str_sensor, ns_sensor,  // traffic sensors, east-west straight, east-west left, north-south 
  output colors e_left_light, e_str_light, w_left_light, w_str_light, ns_light);     // traffic lights, east-west straight, east-west left, north-south


// HRR = red-red following YRR; RRH = red-red following RRY;
// ZRR = 2nd cycle yellow, follows YRR, etc.
  typedef enum {GRRRR, YRRRR, ZRRRR, RGGRR, RYYRR, RZZRR,
                RRRGG, RRRYY, RRRZZ, RRGRG, RRYRY, RRZRZ,
                RGRGR, RYRYR, RZRZR,
                HRRRR, RHHRR, RRRHH, RRHRH, RHRHR} tlc_states;
  tlc_states    present_state, next_state;
  integer ctr5, next_ctr5,       //  5 sec timeout when my traffic goes away
          ctr10, next_ctr10;     // 10 sec limit when other traffic presents

// sequential part of our state machine (register between C1 and C2 in Harris & Harris Moore machine diagram
// combinational part will reset or increment the counters and figure out the next_state
  always_ff @(posedge clk)
    if(reset) begin
	  present_state <= HRRRR;        // so that EWS has top priority after reset
      ctr5          <= 0;
      ctr10         <= 0;
    end
	else begin
    present_state <= next_state;
    ctr5          <= next_ctr5;
    ctr10         <= next_ctr10;
    end

// combinational part of state machine ("C1" block in the Harris & Harris Moore machine diagram)
// default needed because only 6 of 8 possible states are defined/used
  always_comb begin
    next_state = HRRRR;            // default to reset state
    next_ctr5  = 0;
    next_ctr10 = 0;
    case(present_state)
/* ************* Fill in the case statements ************** */

    //North South

    HRRRR: begin

      if( e_str_sensor || w_str_sensor ) begin
        next_state = RRGRG;
			end

      else if( e_left_sensor ) begin
        next_state = RGGRR;
			end

      else if( w_left_sensor ) begin
        next_state = RRRGG;
			end

      else if( ns_sensor ) begin
        next_state = GRRRR;
      end

			else begin
        next_state = HRRRR;
			end

    end

    GRRRR: begin

      next_state = GRRRR;

			if( ( ctr10 > 8 ) && ( e_left_sensor || e_str_sensor || w_left_sensor || w_str_sensor ) ) begin
        next_state = YRRRR;
			end

      if( !ns_sensor && ( ctr5 > 4 ) ) begin
        next_state = YRRRR;
			end

			if( !ns_sensor ) begin
        next_ctr5 = ctr5 + 1;
			end

      next_ctr10 = ctr10 + 1;

    end

    YRRRR: begin

      next_state = ZRRRR;

    end

    ZRRRR: begin

      next_state = HRRRR;

    end

    // East Left and East Straight
    RHHRR: begin

      if( ns_sensor ) begin
        next_state = GRRRR;
			end

      else if( e_str_sensor || w_str_sensor ) begin
        next_state = RRGRG;
			end

      else if( w_left_sensor ) begin
        next_state = RRRGG;
			end

      else if( e_left_sensor ) begin
        next_state = RGRGR;
			end

			else begin
        next_state = RHHRR;
			end

    end

    RGGRR: begin

      next_state = RGGRR;

			if( ( ctr10 > 8 ) && ( ns_sensor || w_left_sensor || w_str_sensor ) ) begin
        next_state = RYYRR;
			end

      if( !( e_left_sensor || e_str_sensor ) && ( ctr5 > 4 ) ) begin
        next_state = RYYRR;
			end

			if( !( e_left_sensor || e_str_sensor ) && ( ctr5 < 5 ) ) begin
        next_ctr5 = ctr5 + 1;
			end

      next_ctr10 = ctr10 + 1;

    end

    RYYRR: begin

      next_state = RZZRR;

    end

    RZZRR: begin

      next_state = RHHRR;

    end

    // West Left and West Straight
    RRRHH: begin

			if( ns_sensor ) begin
        next_state = GRRRR;
			end

			else if( e_str_sensor || w_str_sensor ) begin
        next_state = RRGRG;
			end

      else if( e_left_sensor ) begin
        next_state = RGGRR;
			end

      else if( w_left_sensor ) begin
        next_state = RGRGR;
			end

      else begin
        next_state = RRRHH;
			end

    end

    RRRGG: begin

      next_state = RRRGG;

			if( ( ctr10 > 8 ) && ( ns_sensor || e_left_sensor || e_str_sensor ) ) begin
        next_state = RRRYY;
			end

      if( !( w_left_sensor || w_str_sensor ) && ( ctr5 > 4 ) ) begin
        next_state = RRRYY;
			end

			if( !( w_left_sensor || w_str_sensor ) && ( ctr5 < 5 ) ) begin
        next_ctr5 = ctr5 + 1;
			end

      next_ctr10 = ctr10 + 1;

    end

    RRRYY: begin

      next_state = RRRZZ;

    end

    RRRZZ: begin

      next_state = RRRHH;

    end

    // East Straight and West Straight
    RRHRH: begin

      if( e_left_sensor || w_left_sensor ) begin
        next_state = RGRGR;
			end

      else if( e_str_sensor ) begin
        next_state = RGGRR;
			end

      else if( w_str_sensor ) begin
        next_state = RRRGG;
			end

      else if( ns_sensor ) begin
        next_state = GRRRR;
			end

      else begin
        next_state = RRHRH;
			end

    end

    RRGRG: begin

      next_state = RRGRG;

			if( ( ctr10 > 8 ) && ( ns_sensor || e_left_sensor || w_left_sensor ) ) begin
        next_state = RRYRY;
			end

      if( !( e_str_sensor || w_str_sensor ) && ( ctr5 > 4 ) ) begin
        next_state = RRYRY;
			end

			if( !( e_str_sensor || w_str_sensor ) && ( ctr5 < 5 ) ) begin
        next_ctr5 = ctr5 + 1;
			end

      next_ctr10 = ctr10 + 1;

    end

    RRYRY: begin

      next_state = RRZRZ;

    end

    RRZRZ: begin

      next_state = RRHRH;

    end

    // East Left and West Left
    RHRHR: begin

      if( ns_sensor ) begin
        next_state = GRRRR;
			end

      else if( e_str_sensor || w_str_sensor ) begin
        next_state = RRGRG;
			end

      else if( e_left_sensor ) begin
        next_state = RGGRR;
			end

      else if( w_left_sensor ) begin
        next_state = RRRGG;
			end

      else begin
        next_state = RHRHR;
			end

    end

    RGRGR: begin

      next_state = RGRGR;

			if( ( ctr10 > 8 ) && ( ns_sensor || e_str_sensor || w_str_sensor ) ) begin
        next_state = RYRYR;
			end

      if( !( e_left_sensor || w_left_sensor ) && ( ctr5 > 4 ) ) begin
        next_state = RYRYR;
			end

			if( !( e_left_sensor || w_left_sensor ) && ( ctr5 < 5 ) ) begin
        next_ctr5 = ctr5 + 1;
			end

      next_ctr10 = ctr10 + 1;


    end

    RYRYR: begin

      next_state = RZRZR;

    end

    RZRZR: begin

      next_state = RHRHR;

    end


    endcase
  end

// combination output driver  ("C2" block in the Harris & Harris Moore machine diagram)
  always_comb begin
    w_str_light = red;                // cover all red plus undefined cases
    e_str_light = red;
    e_left_light = red;
    w_left_light = red;
    ns_light = red;
    case(present_state)      // Moore machine

    GRRRR: ns_light = green;
    YRRRR, ZRRRR: ns_light = yellow;
    RGGRR: begin e_str_light = green; e_left_light = green; end
    RYYRR, RZZRR: begin e_str_light = yellow; e_left_light = yellow; end
    RRRGG: begin w_str_light = green; w_left_light = green; end
    RRRYY, RRRZZ: begin w_str_light = yellow; w_left_light = yellow; end
    RRGRG: begin e_str_light = green; w_str_light = green; end
    RRYRY, RRZRZ: begin e_str_light = yellow; w_str_light = yellow; end
    RGRGR: begin e_left_light = green; w_left_light = green; end
    RYRYR, RZRZR: begin e_left_light = yellow; w_left_light = yellow; end

    endcase
  end

endmodule