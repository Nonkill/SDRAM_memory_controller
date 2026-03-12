////////////////////////////////////////////////////////////////////////////////
//
// Company:
// Engineer:        Ilinov Artem Alekseevich
//
// Create Date:     15:22 11.03.2026
// Design Name:
// Module Name:     march
// Project Name:
// Target Devices:
// Tool versions:
// Description:     march algorithm
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/100 ps
`default_nettype none

/*
march
    march_inst
    (
        .CLK        (),             //  in, u[ 1 ], Clock
        .NRESET     (),             //  in, u[ 1 ], Async. negedge reset
        .MEM_RDY    (),             //  in, u[ 1 ], Memory controller ready
        .DI         (),             //  in, u[ 16 ], Data from RAM
        .A          (),             // out, u[ 16 ], Address
        .DO         (),             // out, u[ 16 ], Data to RAM
        .WE         (),             // out, u[ 16 ], Write enable for memory
        .RE         (),             // out, u[ 16 ], Read enable for memory
        .RDY        (),             // out, u[ 1 ],  Ready
        .FLAG       (),             // out, u[ 1 ],  error flag
        .ADDR_ERR   (),             // out, u[ 16 ], address of error
        .VALUE_ERR  (),             // out, u[ 1 ],  value of error
        .VALUE_EXP  (),             // out, u[ 1 ],  expected value
    );
*/

localparam INIT_1           = 4'b0000;
localparam INIT_2           = 4'b0001;
localparam WRITE            = 4'b0010;
localparam WRITE_WAIT       = 4'b0011;
localparam WRITE_TO_READ    = 4'b0100;
localparam READ             = 4'b0101;
localparam READ_WAIT        = 4'b0110;
localparam ERROR            = 4'b0111;
localparam PASS             = 4'b0111;

localparam VALUE = 0; 
localparam COUNTER_MSB = 11;

module march
    (
        input   wire                CLK,                 //  in, u[ 1 ], Clock
        input   wire                NRESET,              //  in, u[ 1 ], Async. negedge reset

        input   wire                MEM_RDY,             //  in, u[ 1 ], Memory controller ready

        input   wire    [ 15 :  0 ] DI,                  //  in, u[ 16 ], Data from RAM

        output  wire    [ 15 :  0 ] A,                   // out, u[ 16 ], Address
        output  wire    [ 15 :  0 ] DO,                  // out, u[ 16 ], Data to RAM
        output  wire    [ 15 :  0 ] WE,                  // out, u[ 16 ], Write enable for memory
        output  wire    [ 15 :  0 ] RE,                  // out, u[ 16 ], Read enable for memory

        output  wire                RDY,                 // out, u[ 1 ],  Ready
        output  wire                FLAG,                // out, u[ 1 ],  error flag
        output  wire                ADDR_ERR,            // out, u[ 16 ], address of error
        output  wire                VALUE_ERR,           // out, u[ 1 ],  value of error
        output  wire                VALUE_EXP           // out, u[ 1 ],  expected value
    );

wire                w_en_r_addr;
wire                w_sclr_r_addr;

wire                w_en_r_counter;
wire                w_sclr_r_counter;

wire                w_en_r_addr_error;

wire                w_en_r_value_error;

wire                w_en_r_value;

wire                w_en_r_rdy;
wire                w_en_r_flag;

wire                w_rdy;
wire                w_flag;


reg     [ 15 :  0 ]          r_addr;
reg     [ COUNTER_MSB :  0 ] r_counter;      // [16:0] - full memory check, [11:0] - 2048 cells check
reg                          r_rdy;
reg                          r_flag;
reg     [ 15 :  0 ]          r_addr_error;
reg     [ 15 :  0 ]          r_value_error;
reg     [ 15 :  0 ]          r_value;
reg     [  4 :  0 ]          r_state;


assign w_en_r_rdy         = (r_state == INIT_1) ? 1'b1 : 1'b0;
assign w_rdy              = (r_state == INIT_1) ? 1'b0 : 1'b0;
assign w_en_r_flag        = (r_state == INIT_1) ? 1'b1 : 1'b0;
assign w_flag             = (r_state == INIT_1) ? 1'b0 : 1'b0;

assign w_en_r_addr        = (r_state == INIT_2) ? 1'b1 : 1'b0;
assign w_sclr_r_addr      = (r_state == INIT_2) ? 1'b1 : 1'b0;
assign w_en_r_counter     = (r_state == INIT_2) ? 1'b1 : 1'b0;
assign w_sclr_r_counter   = (r_state == INIT_2) ? 1'b1 : 1'b0;

assign DO                 = (r_state == WRITE && ~MEM_RDY)  ? VALUE : 1'b0;
assign WE                 = (r_state == WRITE && ~MEM_RDY)  ? 1'b1 : 1'b0;
assign w_en_r_addr        = (r_state == WRITE && ~MEM_RDY)  ? 1'b1 : 1'b0;
assign w_sclr_r_addr      = (r_state == WRITE && ~MEM_RDY)  ? 1'b0 : 1'b0;
assign w_en_r_counter     = (r_state == WRITE && ~MEM_RDY)  ? 1'b1 : 1'b0;
assign w_sclr_r_counter   = (r_state == WRITE && ~MEM_RDY)  ? 1'b0 : 1'b0;

assign WE                 = (r_state == WRITE_WAIT) ? 1'b0 : 1'b0;
assign w_en_r_addr        = (r_state == WRITE_WAIT && r_counter[COUNTER_MSB])  ? 1'b1 : 1'b0;
assign w_sclr_r_addr      = (r_state == WRITE_WAIT && r_counter[COUNTER_MSB])  ? 1'b1 : 1'b0;
assign w_en_r_counter     = (r_state == WRITE_WAIT && r_counter[COUNTER_MSB])  ? 1'b1 : 1'b0;
assign w_sclr_r_counter   = (r_state == WRITE_WAIT && r_counter[COUNTER_MSB])  ? 1'b1 : 1'b0;

assign RE                 = (r_state == READ && ~MEM_RDY)  ? 1'b1 : 1'b0;

assign RE                 = (r_state == READ_WAIT)                                ? 1'b0 : 1'b0;
assign w_en_r_rdy         = (r_state == READ_WAIT && r_counter[COUNTER_MSB])      ? 1'b1 : 1'b0;
assign w_rdy              = (r_state == READ_WAIT && r_counter[COUNTER_MSB])      ? 1'b1 : 1'b0;
assign w_en_r_flag        = (r_state == READ_WAIT && r_counter[COUNTER_MSB])      ? 1'b1 : 1'b0;
assign w_flag             = (r_state == READ_WAIT && r_counter[COUNTER_MSB])      ? 1'b0 : 1'b0;
assign w_en_r_rdy         = (r_state == READ_WAIT && (MEM_RDY && (DI != VALUE)))  ? 1'b1 : 1'b0;
assign w_rdy              = (r_state == READ_WAIT && (MEM_RDY && (DI != VALUE)))  ? 1'b1 : 1'b0;
assign w_en_r_flag        = (r_state == READ_WAIT && (MEM_RDY && (DI != VALUE)))  ? 1'b1 : 1'b0;
assign w_flag             = (r_state == READ_WAIT && (MEM_RDY && (DI != VALUE)))  ? 1'b1 : 1'b0;
assign w_en_r_addr_error  = (r_state == READ_WAIT && (MEM_RDY && (DI != VALUE)))  ? 1'b1 : 1'b0;
assign w_en_r_value_error = (r_state == READ_WAIT && (MEM_RDY && (DI != VALUE)))  ? 1'b1 : 1'b0;
assign w_en_r_value       = (r_state == READ_WAIT && (MEM_RDY && (DI != VALUE)))  ? 1'b1 : 1'b0;
assign w_en_r_addr        = (r_state == READ_WAIT && (MEM_RDY && (DI == VALUE)))  ? 1'b1 : 1'b0;
assign w_sclr_r_addr      = (r_state == READ_WAIT && (MEM_RDY && (DI == VALUE)))  ? 1'b0 : 1'b0;
assign w_en_r_counter     = (r_state == READ_WAIT && (MEM_RDY && (DI == VALUE)))  ? 1'b1 : 1'b0;
assign w_sclr_r_counter   = (r_state == READ_WAIT && (MEM_RDY && (DI == VALUE)))  ? 1'b0 : 1'b0;
               
assign A                  = r_addr;                  
                  
assign RDY                = r_rdy;    
assign FLAG               = r_flag;
assign ADDR_ERR           = r_addr_error;
assign VALUE_ERR          = r_value_error;
assign VALUE_EXP          = r_value;



    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_addr <= 0;
        else
            if (w_en_r_addr)
                if(w_sclr_r_addr)
                    r_addr <= 0;
                else
                    r_addr = r_addr + 1;


    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_counter <= 2046;
        else
            if (w_en_r_counter)
                if(w_sclr_r_counter)
                    r_counter <= 2046;
                else
                    if (~r_counter[COUNTER_MSB])
                        r_counter = r_counter - 1;


    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_addr_error <= 0;
        else
            if (w_en_r_addr_error)
                r_addr_error <= r_addr;


    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_value_error <= 0;
        else
            if (w_en_r_value_error)
                r_value_error <= DI;

    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_value <= 0;
        else
            if (w_en_r_value)
                r_value <= VALUE;

    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_rdy <= 0;
        else
            if (w_en_r_rdy)
                r_rdy <= w_rdy;


    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_flag <= 0;
        else
            if (w_en_r_flag)
                r_flag <= w_flag;



    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_state <= INIT_1;
        else
            case
                (r_state)
                    INIT_1: 
                            r_state <= INIT_2;

                    INIT_2:
                        if (MEM_RDY) 
                            r_state   <= WRITE;

                    WRITE: begin

                        if (~MEM_RDY)
                            r_state   <= WRITE_WAIT;
                    
                    end

                    WRITE_WAIT: begin

                        if (r_counter[COUNTER_MSB])
                            r_state   <= WRITE_TO_READ;

                        else if (MEM_RDY)                   
                            r_state   <= WRITE;


                    end

                    WRITE_TO_READ: begin

                        if (MEM_RDY) 
                            r_state <= READ;

                    end

                    READ:  begin

                        if (~MEM_RDY)
                            r_state <= READ_WAIT;

                    end


                    READ_WAIT: begin
                        if (r_counter[COUNTER_MSB])
                            r_state <= PASS;

                        else if (MEM_RDY && (DI != VALUE)) 
                            r_state <= ERROR;

                        else 
                            r_state <= READ;
                    end

                    ERROR:  begin

                            r_state <= ERROR;

                    end

                    PASS:  begin

                            r_state <= PASS;

                    end

                    default: begin

                            r_state <= INIT_1;

                    end

            endcase


endmodule

`resetall
