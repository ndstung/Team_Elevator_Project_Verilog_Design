`timescale 1ns / 1ps

module top(
	input wire clk,
	input wire rst,
	input wire outside_f1_up, outside_f2_up, outside_f2_down, outside_f3_up, outside_f3_down, outside_f4_down, // Outside elevator floor call buttons
	input wire [3:0] floor_request, // Specific floor button (inside elevator), total of 4 floors
    input wire open_request, // Open Door button (inside elevator)
    input wire close_request, // Close Door button (inside elevator)
    input wire sos_request, // SOS button (inside elevator)
    input wire door_jam, // Door jammed/cannot close due to elevator sensing object between door
    output wire [3:0] floor_requested,
	output wire speaker,
	output wire [7:0] ssg,
	output wire [3:0] digit,
	output wire RGB
    );

	wire [4:0] state;
	wire [3:0] current_floor;
	wire door_status;
	wire flash, no_flash;
	wire destination_floor_reached;
	wire enable_speaker;
	wire direction;
	
	elevator_control my_elevator( .clk(clk),
    .open_request(open_request), 
    .close_request(close_request), 
    .sos_request(sos_request), 
    .door_jam(door_jam), 
    .floor_request(floor_request), 
	.outside_f1_up(outside_f1_up), .outside_f2_up(outside_f2_up), .outside_f2_down(outside_f2_down), .outside_f3_up(outside_f3_up), .outside_f3_down(outside_f3_down), .outside_f4_down(outside_f4_down), 
    .state(state),
	.direction(direction), 
	.destination_floor_reached(destination_floor_reached), .enable_speaker(enable_speaker), .floor_requested(floor_requested), 
	.rst(rst), .current_floor(current_floor), .door_status(door_status), .flash(flash), .no_flash(no_flash)); 
	
	narrator my_narrator(.clk(clk), .speaker(speaker),
	.current_floor(current_floor), .door_status(door_status), .state(state), .direction(direction), 
    .destination_floor_reached(destination_floor_reached), .enable_speaker(enable_speaker));
    
    Seven_Seg display(
            .clk(clk), .flash(flash), .no_flash(no_flash), .direction(direction), .door_status(door_status), .sos_request(sos_request),
            .current_floor(floor_requested), .floor_btn(floor_requested),
            //output [3:0] floor_sel,
            .ssg(ssg),
            .digit(digit),
            .RGB(RGB)
        );
    
endmodule
