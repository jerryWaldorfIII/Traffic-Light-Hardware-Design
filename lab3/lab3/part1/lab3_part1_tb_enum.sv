// test bench for Lab 3  -- write to file version
// CSE140L
// expanded version -- try the simpler traffic_tb first if
//  you do not pass this one
//`timescale 1ns/1ns
import light_package::*;
module lab3_part1_tb;

logic  clk   = 1'b0;
logic  reset = 1'b1;		   // should put your design in all-red
logic  ew_left_sensor = 1'b0,  // left traffic on e-w street
	   ew_str_sensor  = 1'b0,  // thru traffic on e-w street
	   ns_sensor      = 1'b0;  // traffic on n-s street
colors ew_left_light,          // left arrow e-w turn onto n-s
	   ew_str_light,	       // straight ahead e-w
	   ns_light;	           // n-s (no left/thru differentiation)
//typedef enum logic[1:0] {red,yellow,green} color;

// your controller goes here
// input ports = logics above
// output ports = colors (each 2 bits wide)
traffic_light_controller dut(.*);

int fi;
int test_cnt;          // lets testbench track tests
initial begin
  fi = $fopen("lab3_part1_results.txt","w");
  $fdisplay(fi,"t   t   t   e   e   n");	   // header for y, g status display
  $fdisplay(fi,"s   l   n   w   w   s");
  $fdisplay(fi,"            s   l    ");
  $fmonitor(fi, "Test Case: %d", test_cnt);
  #20ns reset    = 1'b0;
  #10ns;
// Test EW_LEFT to EW_STR without more traffic
  test_cnt++                  ;
  ew_left_sensor       = 1'b1 ;
  fork
    begin
      #10ns ew_str_sensor = 1'b1;
      wait   (ew_str_light == green);
	  #25ns ew_str_sensor = 1'b0;
	end
    begin
      wait 	(ew_left_light == green);
      #15ns ew_left_sensor = 1'b0 ;
	end
  join
  #200ns;

// Now set traffic at NS. Green NS lasts past sensor falling
  test_cnt++                  ;
  ns_sensor           = 1'b1  ;
  wait (ns_light == green);
  #35ns ns_sensor     = 1'b0  ;
  #200ns;

// Check NS again, but hold for more than 5 cycles.
//   NS should cycle green-yellow-red when side traffic appears
  test_cnt++;
  ns_sensor              = 1'b1;
  #100ns  ew_left_sensor = 1'b1;
  #200ns ns_sensor       = 1'b0;
  #10ns ew_left_sensor  = 1'b0;
  #200ns;

// All three sensors become 1 at once.
//  EW_STR should come first, then LEFT, then NS
  test_cnt++;
  ew_left_sensor = 1'b1;
  ew_str_sensor  = 1'b1;
  ns_sensor      = 1'b1;
  #1000ns;
  ew_left_sensor = 1'b0;
  #200ns;
  ew_str_sensor  = 1'b0;
  ns_sensor      = 1'b0;
  #200ns;

// All
  test_cnt++;
  $stop;
end

always begin
  #5ns clk = 1'b1;
  #3ns;
// print active sensors into result file
  if(ew_str_sensor)
    $fwrite(fi,"es  ");
  else
    $fwrite(fi,"    ");
  if(ew_left_sensor)
    $fwrite(fi,"el  ");
  else
    $fwrite(fi,"    ");
  if(ns_sensor)
    $fwrite(fi,"ns  ");
  else
    $fwrite(fi,"    ");
// print yellow and green states into result file
  case({ew_str_light,ew_left_light,ns_light})
    {red,red,red}   : $fdisplay(fi,"             %t",$time);
	{yellow,red,red}: $fdisplay(fi,"sy           %t",$time);
	{green,red,red} : $fdisplay(fi,"sg           %t",$time);
	{red,yellow,red}: $fdisplay(fi,"    ly       %t",$time);
	{red,green,red} : $fdisplay(fi,"    lg       %t",$time);
	{red,red,yellow}: $fdisplay(fi,"        ny   %t",$time);
	{red,red,green} : $fdisplay(fi,"        ng   %t",$time);
	default    : $fdisplay(fi,"***ERROR**   %t",$time);
  endcase
  #2ns clk = 1'b0;
end

endmodule
