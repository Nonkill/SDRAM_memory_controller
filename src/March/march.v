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
        .DI         (),             //  in, u[ DATA_WIDTH ], Data from RAM
        .A          (),             // out, u[ ADR_WIDTH ] , Address
        .DO         (),             // out, u[ DATA_WIDTH ], Data to RAM
        .WE         (),             // out, u[ 1 ], Write enable for memory
        .RE         (),             // out, u[ 1 ], Read enable for memory
        .RDY        (),             // out, u[ 1 ],  Ready
        .FLAG       (),             // out, u[ 1 ],  error flag
        .ADDR_ERR   (),             // out, u[ ADR_WIDTH ], address of error
        .VALUE_ERR  (),             // out, u[ 1 ],  value of error
        .VALUE_EXP  ()             // out, u[ 1 ],  expected value
    );
*/

module march
    #(
        parameter                                   ADR_WIDTH    =   13,  // bit amoiunt of address reg
        parameter                                   DATA_WIDTH   =   16,  // width of data stored in data cell of sdram
        parameter                                   ITERATION    =   5,    // how many times the memory will be scanned and filled
        parameter                                   POWER_OF_THE_CHECKED_ADRESSES = 6   // amount of bits subtract one, which will be used for counter, that roll adresses
                                                                                        // as an example 11 give a 2^11 = 2048 cells form 0 that will be checked during test
                                                                                        // for purposes of full mem check use 16
    )
    (
        input   wire                                CLK,                 //  in, u[ 1 ], Clock
        input   wire                                NRESET,              //  in, u[ 1 ], Async. negedge reset

        input   wire                                MEM_RDY,             //  in, u[ 1 ], Memory controller ready
        input   wire    [ DATA_WIDTH - 1 :  0 ]     DI,                  //  in, u[ DATA_WIDTH ], Data from RAM

        output  wire    [ ADR_WIDTH - 1 :  0  ]     A,                   // out, u[ ADR_WIDTH ], Address
        output  wire    [ DATA_WIDTH - 1 :  0 ]     DO,                  // out, u[ DATA_WIDTH ], Data to RAM
        output  wire                                WE,                  // out, u[ 1 ], Write enable for memory
        output  wire                                RE,                  // out, u[ 1 ], Read enable for memory

        output  wire                                RDY,                 // out, u[ 1 ],  Ready
        output  wire                                FLAG,                // out, u[ 1 ],  error flag
        output  wire    [ ADR_WIDTH - 1 :  0 ]      ADDR_ERR,            // out, u[ ADR_WIDTH ], address of error
        output  wire                                VALUE_ERR,           // out, u[ 1 ],  value of error
        output  wire                                VALUE_EXP            // out, u[ 1 ],  expected value
    );

wire                w_en_r_addr;
wire                w_sclr_r_addr;

wire                w_en_r_counter;
wire                w_sclr_r_counter;

wire                w_en_r_iter;

wire                w_en_r_do;

wire                w_en_r_addr_error;

wire                w_en_r_value_error;

wire                w_en_r_value;

wire                w_en_r_rdy;
wire                w_en_r_flag;

wire                w_rdy;
wire                w_flag;

localparam COUNTER_MSB      = POWER_OF_THE_CHECKED_ADRESSES;
localparam START_POINT      = 64;

reg     [ ADR_WIDTH   :  0 ]       r_addr;
reg     [ COUNTER_MSB :  0 ]       r_counter;      // [16:0] - full memory check, [11:0] - 2048 cells check
reg     [ $clog2(ITERATION) : 0 ]  r_iter;
reg                                r_do;           // value for comparing with read data and inverse writing 
reg                                r_rdy;
reg                                r_flag;
reg     [ ADR_WIDTH :  0 ]         r_addr_error;
reg     [ DATA_WIDTH - 1 :  0 ]    r_value_error;
reg     [ DATA_WIDTH - 1 :  0 ]    r_value;
reg     [  4 :  0 ]                r_state;

localparam INIT_1           = 4'b0000;
localparam INIT_2           = 4'b0001;
localparam WRITE_0          = 4'b0010;
localparam WRITE_0_WAIT     = 4'b0011;
localparam READ             = 4'b0100;
localparam READ_TO_WRITE    = 4'b0101;
localparam WRITE            = 4'b0110;
localparam WRITE_TO_READ    = 4'b0111;
localparam ERROR            = 4'b1000;
localparam PASS             = 4'b1001;


assign WE                 = (r_state == WRITE_0) || 
                            (r_state == WRITE) 
                            ? 1'b1 : 1'b0;
assign RE                 = (r_state == READ)  
                            ? 1'b1 : 1'b0;
assign DO                 = (r_state == WRITE)              
                            ? ~r_do : 1'b0;                 //!!!!!! attention after sim

assign w_en_r_rdy         = (r_state == INIT_1) ||
                            (r_state == READ_TO_WRITE && MEM_RDY && DI != r_do) ||
                            (r_state == READ && (r_iter == ITERATION))
                             ? 1'b1 : 1'b0;
assign w_rdy              = (r_state == INIT_1) ||
                            (r_state == READ_TO_WRITE && MEM_RDY && DI != r_do) ||
                            (r_state == READ && (r_iter == ITERATION))
                             ? 1'b0 : 1'b0;
assign w_en_r_flag        = (r_state == INIT_1) ||
                            (r_state == READ_TO_WRITE && MEM_RDY && DI != r_do) ||
                            (r_state == READ && (r_iter == ITERATION))
                            ? 1'b1 : 1'b0;
assign w_flag             = (r_state == INIT_1) ||
                            (r_state == READ_TO_WRITE && MEM_RDY && DI != r_do)
                            ? 1'b0 : 1'b0;

assign w_en_r_addr        = (r_state == INIT_1) ||
                            (r_state == INIT_2) ||
                            (r_state == WRITE_0 ) ||
                            (r_state == WRITE_0_WAIT && ~r_counter[COUNTER_MSB]) ||
                            (r_state == WRITE )                                  // mb need condition for more flexible behaviour
                            ? (r_iter < 2) : 1'b0;                                          // необходимо переписать через case или сделать длинное условие, наверное нет
assign w_sclr_r_addr      = (r_state == WRITE_0 ) ||
                            (r_state == WRITE ) ||
                            (r_state == WRITE_0_WAIT && r_counter[COUNTER_MSB]) 
                            ? 1'b1 : 1'b0;
assign w_en_r_counter     = (r_state == INIT_2) ||
                            (r_state == WRITE_0) ||
                            (r_state == WRITE ) ||
                            (r_state == WRITE_TO_READ && MEM_RDY && r_counter [COUNTER_MSB])
                            ? 1'b1 : 1'b0;
assign w_sclr_r_counter   = (r_state == INIT_2) ||
                            (r_state == WRITE_0_WAIT && r_counter[COUNTER_MSB]) ||
                            (r_state == WRITE_TO_READ && MEM_RDY && r_counter [COUNTER_MSB])
                            ? 1'b1 : 1'b0;


assign w_en_r_addr_error  = (r_state == READ_TO_WRITE && MEM_RDY && DI != r_do)                 ? 1'b1 : 1'b0;
assign w_en_r_value_error = (r_state == READ_TO_WRITE && MEM_RDY && DI != r_do)                 ? 1'b1 : 1'b0;
assign w_en_r_value       = (r_state == READ_TO_WRITE && MEM_RDY && DI != r_do)                 ? 1'b1 : 1'b0;
assign w_en_r_iter        = (r_state == WRITE_TO_READ && MEM_RDY && r_counter [COUNTER_MSB])    ? 1'b1 : 1'b0;

assign A                  = r_addr;                                 
assign RDY                = r_rdy;
assign FLAG               = r_flag;
assign ADDR_ERR           = r_addr_error;
assign VALUE_ERR          = r_value_error;
assign VALUE_EXP          = r_value;


    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_addr <= '0;
        else
            if (w_en_r_addr)
                if (w_sclr_r_addr)   
                    r_addr <= r_addr + 1;
                else
                    r_addr <= r_addr;

            else
                if(w_sclr_r_addr)
                    r_addr <= START_POINT - 1;
                else
                    r_addr <= r_addr - 1;


    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_counter <= START_POINT - 2;
        else
            if (w_en_r_counter)
                if(w_sclr_r_counter)
                    r_counter <= START_POINT - 2;
                else
                    if (~r_counter[COUNTER_MSB])
                        r_counter <= r_counter - 1;
            else 
                r_counter <= r_counter;


    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_iter <= 0;
        else
            if (w_en_r_iter)
                r_iter <= r_iter + 1;

    always @(posedge CLK or negedge NRESET)
        if (~NRESET)
            r_do <= 0;
        else
            if (w_en_r_do)
                r_do <= ~r_do;    


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
                r_value <= r_do;


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
                    INIT_1: begin
                            
                            r_state <= INIT_2;

                    end

                    INIT_2: begin

                        if (MEM_RDY) 
                            r_state   <= WRITE_0;
                        else
                            r_state   <= INIT_2;

                    end

                    WRITE_0: begin

                        if (~MEM_RDY)
                            r_state   <= WRITE_0_WAIT;
                    
                    end

                    WRITE_0_WAIT: begin

                        if (r_counter[COUNTER_MSB])
                            r_state   <= READ;

                        else if (MEM_RDY)                   
                            r_state   <= WRITE_0;


                    end

                    READ:  begin
                        if (r_iter == ITERATION - 1)
                            r_state   <= PASS;
                        else if (~MEM_RDY)
                            r_state <= READ_TO_WRITE;

                    end


                    READ_TO_WRITE: begin
                        if (MEM_RDY && (DI != r_do)) 
                            r_state <= ERROR;
                        
                        else if (MEM_RDY && (DI == r_do))
                            r_state <= WRITE;

                    end
                    
                    WRITE:  begin

                        if (~MEM_RDY)
                            r_state <= WRITE_TO_READ;

                    end

                    WRITE_TO_READ: begin

                        if (MEM_RDY) 
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
