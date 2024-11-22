`timescale 1ns / 1ps

module Seven_Seg(
        input clk, flash, direction, door_status, sos_request, no_flash,
        input [3:0] current_floor, floor_btn,
        output reg [7:0] ssg,
        output reg [3:0] digit,
        output reg RGB
    );

    // signal for the anode of the display
    wire [1:0]digit_select;  
    
    // signal for floor #
    reg [7:0] floor_ssg;
    
    // signal for direction
    reg [7:0] direction_ssg;

    
    // signal for door status 
    reg [7:0] door_ssg_r, door_ssg_l;
    
    // sos RGB
    reg [30:0]sos_counter;
    always @(posedge clk) begin
        sos_counter <= sos_counter + 1;
        if(sos_request)
            RGB <= sos_counter[5];
        else
            RGB <= 0;
    end
    
//---------------------------------------------------------//
//---------------------------------------------------------//
    //floor numbers digit[0](right digit) 
    parameter [7:0]     ssg_one =   8'b11111001,
                        ssg_two =   8'b10100100,
                        ssg_three = 8'b10110000,
                        ssg_four =  8'b10011001;
                        
    //up/down digit[1]
    reg [7:0]           ssg_up =    8'b11101010,
                        ssg_down =  8'b11010101;

    //door left = digit[3], right = digit[2]
    //  DOOR 1          DOOR2
    //  ----            ----
    //  |                   |
    //  |                   |
    //  ----            ----
    parameter [7:0]     ssg_door1 =    8'b11000110, 
                        ssg_door2 =    8'b11110000;
//---------------------------------------------------------//
//---------------------------------------------------------//
    // set up clock dividers and the display paramters
    reg [19:0]cnt;                  //creates~10ms refersh time
    
    //used to iterate the digit to display        
    assign digit_select = cnt[19:18];
    
    // flash the up/down
    reg [28:0]flasher;
    
    // initialize counters and displays
    initial begin
        cnt <= 0;
        ssg <= 8'b11000000;
        digit <= 4'b1111;
        flasher <= 0;
    end
//---------------------------------------------------------//
//---------------------------------------------------------//
    // floor SSG
    always@(*) begin
        case(current_floor) 
        1: floor_ssg <= ssg_one;
        2: floor_ssg <= ssg_two;
        4: floor_ssg <= ssg_three;
        8: floor_ssg <= ssg_four;
        default: floor_ssg <= 8'b11000000;
        endcase
    end
    
    // direction SSG    
    always@(*) begin
        case(direction) 
        0: direction_ssg <= ssg_down;
        1: direction_ssg <= ssg_up;
        endcase
    end
    
    // door ssg
    always @(*) begin
        case(door_status)
            0: begin // closed
            door_ssg_r <= ssg_door1;
            door_ssg_l <= ssg_door2;
            end
            1: begin // open
            door_ssg_r <= ssg_door2;
            door_ssg_l <= ssg_door1;
            end 
        endcase
    end
    
    always@(posedge clk) begin
        cnt <= cnt+1;
    end
    
    always@(*) begin
        case(digit_select)
            0: begin
            digit <= 4'b1110;
            ssg <= floor_ssg;
            end
            1: begin
            digit <= 4'b1101;
            ssg <= direction_ssg;
            end
            2: begin
            digit <= 4'b1011;
            ssg <= door_ssg_r;
            end
            3: begin
            digit <= 4'b0111;
            ssg <= door_ssg_l;
            end
        endcase
    end

    always @(posedge clk) 
    begin
        if(no_flash)
        begin
           ssg_up <=    8'b10111111;
           ssg_down <=  8'b10111111;         
        end
        else
        begin
            if(flash)
            begin
                    ssg_up <=    8'b11101010;
                    ssg_down <=  8'b11010101;            
            end
            else
            begin
                    ssg_up <= 8'b11011100;
                    ssg_down <=  8'b11100011; 
            end
        end
    end
endmodule