`timescale 1ns / 1ps

module elevator_control
(
    input wire clk,
    input wire rst,
    input wire open_request, // Open Door button (inside elevator)
    input wire outside_f1_up, outside_f2_up, outside_f2_down, outside_f3_up, outside_f3_down, outside_f4_down, // Outside elevator floor call buttons
    input wire close_request, // Close Door button (inside elevator)
    input wire sos_request, // SOS button (inside elevator)
    input wire door_jam, // Door jammed/cannot close due to elevator sensing object between door
    input wire [3:0] floor_request, // Specific floor button (inside elevator), total of 4 floors
    output reg [3:0] floor_requested,
    output reg [4:0] state,
    output reg [3:0] current_floor,
    output reg direction,
    output reg destination_floor_reached,
    output reg door_status,
    output reg flash, no_flash,
    output reg enable_speaker
);

reg [3:0] destination_floor;
reg [26:0] base_timer, base_waiting_timer, flash_counter;
reg [4:0] timer, waiting_timer;
reg slow_flash, fast_flash;

/* State set up */
reg [4:0] next_state;
reg reset, reset_waiting;
wire elevator_called; // Elevator call request of any kind (outside, inside)
assign elevator_called = (outside_f1_up || outside_f2_up || outside_f2_down || outside_f3_up || outside_f3_down || outside_f4_down || floor_request);
parameter [4:0] IDLE = 5'd0,
 SOS = 5'd1,
 OPENED_DOOR = 5'd2,
 CLOSED_DOOR = 5'd3,
 BEGIN_ELEVATOR_MOVEMENT = 5'd4,
 SLOW_START = 5'd5,
 DOOR_JAMMED = 5'd6,
 WAITING_AFTER_OPENING = 5'd7,
 OPEN_REQUEST_WHILE_CLOSED = 5'd8,
 WAITING_AFTER_JAMMED = 5'd9,
 FAST_FIRST_HALF = 5'd10,
 INCOMING_FLOOR = 5'd11,
 SLOW_END = 5'd12,
 ARRIVED = 5'd13,
 FAST_LAST_HALF = 5'd14;

/* Reg variables set up */
initial begin
	current_floor = 1;
	destination_floor = 1;
	state = IDLE;
	timer = 0;
	base_timer = 0;
	reset = 0;
	floor_requested = 0;
	base_waiting_timer = 0;
	waiting_timer = 0;
	door_status = 0; //closed
	flash = 0;
	no_flash = 1;
	slow_flash = 0;
	fast_flash = 0;
end

/* Determination of destination floor */
always@(posedge clk)
begin
    if((floor_request == 4'b0001) || outside_f1_up)
		destination_floor <= 4'b0001;
	else if((floor_request == 4'b0010) || outside_f2_up || outside_f2_down)
		destination_floor <= 4'b0010;
	else if((floor_request == 4'b0100) || outside_f3_up || outside_f3_down)
		destination_floor <= 4'b0100;
	else if((floor_request == 4'b1000) || outside_f4_down)
		destination_floor <= 4'b1000;
end

/* Sequential next state logic */
always @(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        state <= next_state;
end

/* 	Timer Initializations */
always@(posedge clk)
begin
	if(reset)
		begin
			base_timer <= 0;
			timer <= 0;
		end
	else
		begin
			// With this set up, timer ticks roughly every 1 second
			if(base_timer >= 27'd25000000) 
			begin
				timer <= timer + 1;
				base_timer <= 0;
			end
			else
				base_timer <= base_timer + 1;
	   end
end

always@(posedge clk)
begin
	if(reset_waiting)
		begin
			base_waiting_timer <= 0;
			waiting_timer <= 0;
		end
	else
		begin
			// With this set up, timer ticks roughly every 1 second
			if(base_waiting_timer >= 27'd25000000) 
			begin
				waiting_timer <= waiting_timer + 1;
				base_waiting_timer <= 0;
			end
			else
				base_waiting_timer <= base_waiting_timer + 1;
	   end
end

always@(posedge clk)
begin
    if(slow_flash)
        begin
        flash_counter <= flash_counter + 1;
        if (flash_counter == 27'd80000000)
            begin
            flash <= ~flash;
            flash_counter <= 0;
            end
        end
    else if(fast_flash)
        begin
        flash_counter <= flash_counter + 1;
        if (flash_counter == 27'd33333333)
            begin
            flash <= ~flash;
            flash_counter <= 0;
            end
        end
    else
        flash_counter <= 0;
end

always@(destination_floor)begin
        
    if((state==ARRIVED) || (state==IDLE) || (state==OPENED_DOOR) || (state==SOS)
       || (state==WAITING_AFTER_OPENING) || (state==CLOSED_DOOR) || (state==DOOR_JAMMED))
        floor_requested = 0;
    else
        floor_requested = destination_floor;
end

/* Combinational state  logic */
always@*
begin
	case(state)
		IDLE:
			if (sos_request)
				next_state = SOS;
			else if (elevator_called)
				next_state = BEGIN_ELEVATOR_MOVEMENT;
			else if (open_request)
				next_state = OPENED_DOOR;
			else begin
				next_state = IDLE;
//	            floor_requested = 0;
	        end
		SOS:
			if (timer == 15)
			    next_state = IDLE;
			else
			    next_state = SOS;
		OPENED_DOOR:
            if (timer == 15)
                next_state = WAITING_AFTER_OPENING;
		    else
		        next_state = OPENED_DOOR;
		WAITING_AFTER_OPENING:
		    if (door_jam)
		        next_state = DOOR_JAMMED;
		    else if (waiting_timer == 5 || close_request) // timer does not work in this case
		        next_state = CLOSED_DOOR;
		    else
		        next_state = WAITING_AFTER_OPENING;
		CLOSED_DOOR:
		    if (open_request)
		        next_state = OPEN_REQUEST_WHILE_CLOSED;
			else if (timer == 15)
                next_state = IDLE;
            else
                next_state = CLOSED_DOOR;
       OPEN_REQUEST_WHILE_CLOSED:
            if(waiting_timer == 3)
                next_state = OPENED_DOOR;
            else
                next_state = OPEN_REQUEST_WHILE_CLOSED;
	   DOOR_JAMMED:
	       if (!door_jam || close_request)
	           next_state = WAITING_AFTER_OPENING;
	       else
	           next_state = DOOR_JAMMED;
	    BEGIN_ELEVATOR_MOVEMENT:
	       if (current_floor == destination_floor)
	           next_state = OPENED_DOOR;
	       else
	           next_state = SLOW_START;
	    SLOW_START:
	       if (timer == 10)
	           next_state = FAST_FIRST_HALF;
	       else
	           next_state = SLOW_START;
	    FAST_FIRST_HALF:
	       if (waiting_timer == 10)
	           next_state = INCOMING_FLOOR;
	       else
	           next_state = FAST_FIRST_HALF;
	    INCOMING_FLOOR:
	       next_state = FAST_LAST_HALF;
	    FAST_LAST_HALF:
	       if (timer == 10 && (current_floor == destination_floor))
               next_state = SLOW_END;
           else if (timer == 10 && (current_floor != destination_floor))
               next_state = FAST_FIRST_HALF;
           else
               next_state = FAST_LAST_HALF;
	    SLOW_END:
	       if (waiting_timer == 10)
	           next_state = ARRIVED;
	       else
	           next_state = SLOW_END;
	    ARRIVED:
	       next_state = OPENED_DOOR;
        default:
            next_state = IDLE;
	endcase
end

/* Outputs */
always@(posedge clk)
begin
    case(state)
        IDLE:
        begin
            reset <= 1;
            reset_waiting <= 1;
            enable_speaker <= 0;
            direction <= 0;
            door_status <= 0;
            no_flash <= 1;
        end
        SOS:
        begin
            reset <= 0;
            reset_waiting <= 1;
            enable_speaker <= 1;
        end
        OPENED_DOOR:
        begin
            reset <= 0;
            reset_waiting <= 1;
            enable_speaker <= 1;
            door_status <= 1;
        end
        WAITING_AFTER_OPENING:
        begin
            reset <= 1;
            reset_waiting <= 0;
            enable_speaker <= 0;
            door_status <= 1;
        end
        CLOSED_DOOR:
        begin
            reset <= 0;
            reset_waiting <= 1;
            enable_speaker <= 1;
            door_status <= 0;
        end
        OPEN_REQUEST_WHILE_CLOSED:
        begin
            reset <= 1;
            reset_waiting <= 0;
            enable_speaker <= 0;
            door_status <= 0;
        end
        DOOR_JAMMED:
        begin
            reset <= 0;
            reset_waiting <= 1;
            enable_speaker <= 1;
            door_status <= 1;
        end
        BEGIN_ELEVATOR_MOVEMENT:
        begin
            if(current_floor < destination_floor)
                direction <= 1;
            else
                direction <= 0;
            reset <= 1;
            reset_waiting <= 1;
            enable_speaker <= 0;
        end
        SLOW_START:
        begin
            reset <= 0;
            reset_waiting <= 1;
            enable_speaker <= 1;
            no_flash <= 0;
            slow_flash <= 1;
        end
        FAST_FIRST_HALF:
        begin
            reset <= 1;
            reset_waiting <= 0;
            enable_speaker <= 0;
            no_flash <= 0;
            slow_flash <= 0;
            fast_flash <= 1;
        end
        INCOMING_FLOOR:
        begin
            if (direction)
                current_floor <= (current_floor << 1);
            else
                current_floor <= (current_floor >> 1);
            reset <= 1;
            reset_waiting <= 1;
            enable_speaker <= 0;
        end
        FAST_LAST_HALF:
        begin
            reset <= 0;
            reset_waiting <= 1;
            enable_speaker <= 1;
            no_flash <= 0;
            fast_flash <= 1;
        end
        SLOW_END:
        begin
            reset <= 1;
            reset_waiting <= 0;
            enable_speaker <= 0;
            no_flash <= 0;
            slow_flash <= 1;
        end
        ARRIVED:
        begin
            reset <= 1;
            reset_waiting <= 1;
            enable_speaker <= 0;
            no_flash <= 1;
            slow_flash <= 0;
            fast_flash <= 0;
        end
        default:
        begin
            reset <= 1;
            reset_waiting <= 1;
            direction <= 0;
            enable_speaker <= 0;
            no_flash <= 1;
            door_status <= 0;
        end
    endcase
end

endmodule
