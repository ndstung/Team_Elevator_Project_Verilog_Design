`timescale 1 ns / 1 ps

module fsm (
  output wire        busy,
  input  wire        period_expired,
  input  wire        data_arrived,
  input  wire        val_match,
  output wire        load_ptrs,
  output wire        increment,
  output wire        sample_capture,
  input  wire        clk
  );

  // Describe the actual circuit for the assignment.
   	reg [2:0] cur_state;
 	reg [2:0] next_state;
	reg [2:0] count;

	parameter [2:0] IDLE  = 0;
	parameter [2:0] LOAD  = 1;
	parameter [2:0] WAIT  = 2;
	parameter [2:0] INCREMENT  = 3;                            
	parameter [2:0] CAPTURE	= 4;
	parameter [2:0] DELAY = 5;

    // initialize state into idle, count to 0
	initial 
	begin
		cur_state <= IDLE;
		count <= 0;
	end
	
	// sensitivity to all
	always @(*)
	begin
		cur_state <= next_state;
	end
	
	always @(posedge clk)
	begin
		case(cur_state)
			IDLE:	begin 
				if (data_arrived==1) next_state = LOAD;
				else next_state = IDLE;
			end
			LOAD: begin
				next_state = DELAY;
			end
			WAIT: begin
				if (period_expired == 1) next_state = INCREMENT;
				else next_state = WAIT;
			end
			INCREMENT: begin
				if (val_match==1) next_state = IDLE;
				else next_state = DELAY;
			end
			CAPTURE: begin 
				if (val_match==1) next_state = IDLE;
				else next_state = WAIT;
			end
			DELAY:begin 
				if (count == 4) next_state = CAPTURE;
				else next_state = DELAY;
			end
			default: next_state = cur_state;
		endcase
	end

	always @(posedge clk)
	begin
		if (cur_state == DELAY) begin 
			count <= count + 1;
		end
		else count <= 0;
	end

  //output logic
	assign busy = ~(cur_state == IDLE);
	assign load_ptrs = (cur_state == LOAD);
	assign increment = (cur_state == INCREMENT);
	assign sample_capture = (cur_state == CAPTURE);
endmodule
