`timescale 1 ns / 1 ps


//////////////////////////////////////////////Top Level TB////////////////////////////////////////
module testbench;
	
	// Inputs
	reg clk, rst;
	reg outside_f1_up, outside_f2_up, outside_f2_down, outside_f3_up, outside_f3_down, outside_f4_down;
	reg [3:0] floor_request;
	reg open_request, close_request, sos_request, door_jam;

	// Outputs
	wire [3:0] floor_requested;
	wire speaker;
	wire [7:0] ssg;
	wire [3:0] digit;

	
    // Instantiate the Unit Under Test (UUT)
    top uut (
        .clk(clk),
        .rst(rst),
        .outside_f1_up(outside_f1_up), .outside_f2_up(outside_f2_up), .outside_f2_down(outside_f2_down), 
        .outside_f3_up(outside_f3_up), .outside_f3_down(outside_f3_down), .outside_f4_down(outside_f4_down),
        .floor_request(floor_request),
        .open_request(open_request), .close_request(close_request), .sos_request(sos_request), .door_jam(door_jam),
        .floor_requested(floor_requested),
        .speaker(speaker),
        .ssg(ssg),
        .digit(digit)
        //.RGB(RGB)
    );
	
    // Clock generation
    always #5 clk = ~clk;  // Generate a clock with a period of 10ns
    
    // Initial block for test cases
    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        open_request = 0;
        close_request = 0;
        sos_request = 0;
        door_jam = 0;
        floor_request = 4'b0000;
        outside_f1_up = 0; outside_f2_up = 0; outside_f2_down = 0; outside_f3_up = 0; outside_f3_down = 0; outside_f4_down = 0;

        
        // Wait for 100 ns for global reset to finish
        #50;
        rst = 0;

        // Add test cases here
        // Example: Request floor 3 from inside
        floor_request = 4'b0100;
        #50; // wait some time
        floor_request = 4'b0000;

        // Example: Request floor 2 from inside
        floor_request = 4'b0010;
        #50; // wait some time
        floor_request = 4'b0000;
        
        // Example: Request floor 1 from inside
        floor_request = 4'b0001;
        #50; // wait some time
        floor_request = 4'b0000;
        
        // Example: Request floor 4 from inside
        floor_request = 4'b1000;
        #50; // wait some time
        floor_request = 4'b0000;
        
        // Request from outside, floor 2 up
        outside_f2_up = 1;
        #50;
        outside_f2_up = 0;

        // Simulate door jam
        door_jam = 1;
        #50;
        door_jam = 0;

        // Assert SOS
        #10;
        sos_request = 1;
        #10;
        sos_request = 0;

        // Finish simulation
        #50000;
        $finish;
    end

endmodule

//////////////////////////////////////////////Elevator Control TB////////////////////////////////////////
//module testbench;
//    // Inputs
//    reg clk;
//    reg rst;
//    reg open_request;
//    reg outside_f1_up, outside_f2_up, outside_f2_down, outside_f3_up, outside_f3_down, outside_f4_down;
//    reg close_request;
//    reg sos_request;
//    reg door_jam;
//    reg [3:0] floor_request;

//    // Outputs
//    wire [3:0] floor_requested;
//    wire [3:0] state;
//    wire [3:0] current_floor;
//    wire direction;
//    wire door_status;
//    wire flash, no_flash;
//    wire enable_speaker;

//    // Instantiate the elevator control module
//    elevator_control uut (
//        .clk(clk),
//        .rst(rst),
//        .open_request(open_request),
//        .outside_f1_up(outside_f1_up),
//        .outside_f2_up(outside_f2_up),
//        .outside_f2_down(outside_f2_down),
//        .outside_f3_up(outside_f3_up),
//        .outside_f3_down(outside_f3_down),
//        .outside_f4_down(outside_f4_down),
//        .close_request(close_request),
//        .sos_request(sos_request),
//        .door_jam(door_jam),
//        .floor_request(floor_request),
//        .floor_requested(floor_requested),
//        .state(state),
//        .current_floor(current_floor),
//        .direction(direction),
//        .door_status(door_status),
//        .flash(flash),
//        .no_flash(no_flash),
//        .enable_speaker(enable_speaker)
//    );

//    // Clock generation
//    initial begin
//        clk = 0;
//        forever #5 clk = ~clk; // 20ns period => 50 MHz clock
//    end

//    // Test stimulus
//    initial begin
//        // Initialize all inputs
//        rst = 0;
//        open_request = 0;
//        outside_f1_up = 0;
//        outside_f2_up = 0;
//        outside_f2_down = 0;
//        outside_f3_up = 0;
//        outside_f3_down = 0;
//        outside_f4_down = 0;
//        close_request = 0;
//        sos_request = 0;
//        door_jam = 0;
//        floor_request = 0;

//        // Apply Reset
//        rst = 1;
//        #10;
//        rst = 0;
//        #10;

//        // Case 1: Request elevator to floor 2
//        outside_f2_up = 1;
//        #10;
//        outside_f2_up = 0;
//        #900;


//        // Case 2: Request elevator to floor 3 with a door jam
////        outside_f3_up = 1;
////        #10;
////        outside_f3_up = 0;
//        floor_request = 4'b0100;
//        #10;
//        floor_request = 0;
//        #900;

//        // Simulate door jam
//        door_jam = 1;
//        $display("Time = %0dns: Simulating door jam", $time);
//        #50;
//        door_jam = 0;
//    end

//endmodule

//////////////////////////////////////////////Seven Segment TB////////////////////////////////////////
//module testbench;

//    reg clk;
//    reg flash;
//    reg direction;
//    reg door_status;
//    reg sos_request;
//    reg no_flash;
//    reg [3:0] current_floor;
//    //reg [3:0] floor_requested;
//    wire [7:0] ssg;
//    wire [3:0] digit;
//    wire RGB;

//    // Instantiate the Design Under Test (DUT)
//    Seven_Seg dut (
//        .clk(clk),
//        .flash(flash),
//        .direction(direction),
//        .door_status(door_status),
//        .sos_request(sos_request),
//        .no_flash(no_flash),
//        //.current_floor(floor_requested),
//        .current_floor(current_floor),
//        .ssg(ssg),
//        .digit(digit),
//        .RGB(RGB)
//    );

//    // Clock Generation
//    initial begin
//        clk = 0;
//    end
//    always #5 clk = ~clk;  // 100 MHz clock, clock period 10ns

//    // Stimulus
//    initial begin
//        // Initialize inputs
//        flash = 0;
//        direction = 0;
//        door_status = 0;
//        sos_request = 0;
//        no_flash = 0;
//        current_floor = 4'b0000;

//        // Reset signals
//        #20;
//        current_floor = 4'b0001;
//        #20;
//        current_floor = 4'b0010;
//        #20;
//        current_floor = 4'b0100;
//        #20;
//        current_floor = 4'b1000;
//        #20;
//        current_floor = 4'b0001;

//        // Direction up and down
//        direction = 1;
//        #50;
//        direction = 0;

//        // Flashing test
//        flash = 1;
//        #50;
//        flash = 0;

//        // Door open/close
//        door_status = 1;
//        #100;
//        door_status = 0;

//        // SOS Request
//        sos_request = 1;
//        #100;
//        sos_request = 0;

//        // No Flash Mode
//        no_flash = 1;
//        #50;
//        no_flash = 0;

//        // End simulation
//        #5000;
//        $finish;
//    end

//endmodule
/////////////////////////////////////////////Narrator TB///////////////////////////////
//module testbench;

//  // Generate a free running 100 MHz clock
//  // signal to mimic what is on the board
//  // provided for prototyping.

//  reg clk;

//  always
//  begin
//    clk = 1'b0;
//    #5;
//    clk = 1'b1;
//    #5;
//  end

//  wire speaker;
  
//  initial
//  begin
//    $display("If simulation ends before the testbench");
//    $display("completes, use the menu option to run all.");
//    #40000000;  // allow it to run
//    $display("Simulation is over, check the waveforms.");
//    $stop;
//  end

//  narrator my_narrator (
//    .clk(clk),
//    .speaker(speaker)
//  );

//endmodule
