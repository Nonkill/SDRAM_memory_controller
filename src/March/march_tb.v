`timescale 100ps / 1ps

module march_tb;

reg r_clk = 0;
reg r_nreset = 1;
reg r_mem_rdy = 0;
reg [15:0] r_di;

reg r_re;
reg r_we;
reg r_rdy;
reg r_flag;
reg [12:0] r_addr_error;
reg r_value_err;
reg r_value_exp;



localparam POWER_OF_THE_CHECKED_ADRESSES = 6; 

march
    #(
        .POWER_OF_THE_CHECKED_ADRESSES (POWER_OF_THE_CHECKED_ADRESSES)
    )
    march_inst 
    (
        .CLK        (r_clk),                   //  in, u[ 1 ],          Clock
        .NRESET     (r_nreset),                //  in, u[ 1 ],          Async. negedge reset
        .MEM_RDY    (r_mem_rdy),               //  in, u[ 1 ],          Memory controller ready
        .DI         (r_di),                    //  in, u[ DATA_WIDTH ], Data from RAM
        .A          (),                        // out, u[ ADR_WIDTH ],  Address
        .DO         (),                        // out, u[ DATA_WIDTH ], Data to RAM
        .WE         (r_we),                        // out, u[ 1 ],          Write enable for memory
        .RE         (r_re),                    // out, u[ 1 ],          Read enable for memory
        .RDY        (r_rdy),                   // out, u[ 1 ],          Ready
        .FLAG       (r_flag),                  // out, u[ 1 ],          error flag
        .ADDR_ERR   (r_addr_error),            // out, u[ ADR_WIDTH ],  address of error
        .VALUE_ERR  (r_value_err),             // out, u[ 1 ],          value of error
        .VALUE_EXP  (r_value_exp)              // out, u[ 1 ],          expected value
    );

always 
    #35 r_clk = ~r_clk;

initial begin
    #50;
    r_nreset = 1;
    #80;
    r_nreset = 0;
    #50;
    r_nreset = 1;
    r_mem_rdy = 1; 
    #35;
    repeat (64) begin
        if (r_we) begin
            @(posedge r_clk)
            r_mem_rdy = ~r_mem_rdy; 
        end
    end

    repeat ( (64) * 5) begin
        if (r_re)
            r_mem_rdy <= 0;
        
        @(posedge r_clk)
        @(posedge r_clk)
        r_di <= '0;
        r_mem_rdy <= 1;
        @(posedge r_clk)
        r_mem_rdy <= 0;
        @(posedge r_clk)
        r_mem_rdy <= 1;

        if (r_flag) 
            $error ("During test handled the error in adress %d, value expected %b, got value %b", r_addr_error, r_value_exp, r_value_err );
        else if (r_rdy)
            $finish ("Test completed successful");

    end




end





endmodule