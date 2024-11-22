`timescale 1 ns / 1 ps

module narrator (
  input  wire        clk,
  input wire        enable_speaker,
  input wire [4:0]   state,
  input [3:0] current_floor,
  input requested_floor_reached,
  input direction,
  input door_status,
  input destination_floor_reached,
  output wire        speaker
  );

  // Create a test circuit to exercise the chatter
  // module, rather than using switches and a
  // button.
  
  reg   [6:0] counter = 0;
  reg   [5:0] data;
  wire        write;
  wire        busy;
  parameter [3:0] FLOOR_ONE = 4'b0001,
                  FLOOR_TWO = 4'b0010,
                  FLOOR_THREE = 4'b0100,
                  FLOOR_FOUR = 4'b1000;     
  
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

  always @(posedge clk) 
    begin
    if (!busy) 
        counter <= counter + 1;
    if (!enable_speaker) 
        counter <= 0;
    end

  always @*
  begin
	  case(state)
		IDLE:
			case (counter[6:2]) // Silence
				0:	data = 6'h04;
				default: data = 6'h04;
			endcase
		SOS:
			case(counter[6:2]) // SOS
				0: data = 6'h07;
				1: data = 6'h37;
				2: data = 6'h03;
				3: data = 6'h35;
				4: data = 6'h03;
				5: data = 6'h07;
				6: data = 6'h37;
				7: data = 6'h04;
				default: data = 6'h04;
			endcase
		OPENED_DOOR:
			case (counter[6:2]) // Opening Door
				0:  data = 6'h35;
				1:  data = 6'h09;
				2:  data = 6'h07;
				3:  data = 6'h0b;
				4:  data = 6'h13;
				5:  data = 6'h0b;
				6:  data = 6'h24;
				7:  data = 6'h21;
				8:  data = 6'h3a;
				9:  data = 6'h04;
				default: data = 6'h04;
			endcase
		CLOSED_DOOR:
			case(counter[6:2]) // Closing Door
				0:  data = 6'h08;    
				1:  data = 6'h2d;      
				2:  data = 6'h35;   
				3:  data = 6'h2b;    
				4:  data = 6'h13;    
				5:  data = 6'h0b;  
				6:  data = 6'h24;  
				7:	data = 6'h21;
				8:	data = 6'h3a;
				default: data = 6'h04;
			endcase
		DOOR_JAMMED:
			case(counter[6:2]) //Door jammed
				0:  data = 6'h21;    
				1:  data = 6'h3a;
				2:	data = 6'h04;
				3:	data = 6'h0a;
				4:	data = 6'h18;
				5:	data = 6'h11;
				6:	data = 6'h15;
				7:	data = 6'h15;
				default: data = 6'h04;
	       endcase
	    SLOW_START:
                       if(direction)
                          case(counter[6:2]) // Going up
                              0:  data = 6'h3d;    
                              1:  data = 6'h35;    
                              2:  data = 6'h13;      
                              3:  data = 6'h0b;    
                              4:  data = 6'h24;
                              5:  data = 6'h03;
                              6:  data = 6'h24;    
                              7:  data = 6'h35;    
                              8:  data = 6'h09;
                              default: data = 6'h04;
                          endcase
                       else
                           case(counter[6:2]) // Going down
                              0:  data = 6'h3d;    
                              1:  data = 6'h35;    
                              2:  data = 6'h13;      
                              3:  data = 6'h0b;    
                              4:  data = 6'h24;
                              5:  data = 6'h03;
                              6:  data = 6'h21;    
                              7:  data = 6'h20;    
                              8:  data = 6'h0b;
                              default: data = 6'h04;
                          endcase
        FAST_LAST_HALF:
            case(current_floor)
                        FLOOR_ONE:
                           case(counter[6:2]) // Floor 1
                           0:  data =6'h28; 
                           1:  data =6'h2d; 
                           2:  data =6'h3a;   
                           3:  data = 6'h03;
                           4:  data = 6'h2e;
                           5:  data = 6'h0f;
                           6:  data = 6'h0f;
                           7:  data = 6'h0b;
                           default: data = 6'h04;
                        endcase
                        FLOOR_TWO:
                           case(counter[6:2]) // Floor 2
                           0:  data =6'h28; 
                           1:  data =6'h2d; 
                           2:  data =6'h3a;   
                           3:  data = 6'h03;
                           4:  data = 6'h0d;
                           5:  data = 6'h1f;
                           default: data = 6'h04;
                        endcase
                        FLOOR_THREE:
                           case(counter[6:2]) // Floor 3
                           0:  data =6'h28; 
                           1:  data =6'h2d; 
                           2:  data =6'h3a;   
                           3:  data = 6'h03;
                           4:  data = 6'h1d;
                           5:  data = 6'h0e;
                           6:  data = 6'h13;
                           default: data = 6'h04;
                        endcase
                        FLOOR_FOUR:
                           case(counter[6:2]) // Floor 4
                           0:  data =6'h28; 
                           1:  data =6'h2d; 
                           2:  data =6'h3a;   
                           3:  data = 6'h03;
                           4:  data = 6'h28;
                           5:  data = 6'h28;
                           6:  data = 6'h23;
                           7:  data = 6'h3a;
                           default: data = 6'h04;
                        endcase
                    endcase
		default:
			case (counter[6:2]) // Silence
				0:	data = 6'h04;
				default: data = 6'h04;
			endcase
	 endcase
  end

  assign write = (counter[1:0] == 2'b00);
  
  // Instantiate the chatter module, which is
  // driven by the test circuit.

  chatter chatter_inst (
    .data(data),
    .write(write),
    .busy(busy),
    .clk(clk),
    .speaker(speaker)
  );

endmodule
