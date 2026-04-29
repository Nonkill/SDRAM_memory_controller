`timescale 100ps / 1ps                                       //read не работает и ещё надо сделать так чтобы во врайт стейте выжавались сигналы, а не после

module march_controller_tb ();

//input   wire                                CLK;
//input   wire                                NRST; 
//output  reg                                 RDY_BUTTON;
//output  reg                                 FLAG_BUTTON;
//output  reg                                 ADDR_ERR;
//output  reg                                 VALUE_ERR;
//output  reg                                 VALUE_EXP;

localparam                                  DATA_WIDTH = 16;

reg                                         CLK;
reg                                         NRST; 
reg                                         RDY_BUTTON;
reg                                         FLAG_BUTTON;
reg               [21:0]                    ADDR_ERR;
reg                                         VALUE_ERR;
reg                                         VALUE_EXP;

reg               [21:0]                    ADR_IN; 
reg               [1:0]                     BDR_IN = 2'b00;
reg               [15:0]                    DIN; 
reg                                         RE_IN;  
reg                                         WE_IN; 
reg               [12:0]                    ADR_OUT;
reg               [1:0]                     BDR_OUT;
reg               [15:0]                    DOUT;  
reg                                         WE_OUT; 
reg                                         RDY; 
reg                                         CKE;       
reg                                         CS;        
reg                                         RAS;       
reg                                         CAS;       
reg              [15:0]                     DQ;        
wire             [12:0]                     adr_out; 
wire             [1:0]                      bdr_out;  
wire                                        we_out;  
wire                                        cke;       
wire                                        cs;        
wire                                        ras;       
wire                                        cas;       
wire             [15:0]                     dq;  
//reg              [4:0]                      counter;
//reg              [4:0]                      counter_db;
//reg              [4:0]                      difference;
reg                                         rdy;
reg              [ DATA_WIDTH - 1 : 0 ]     dout;
reg              [21:0]                     adr_in;
reg              [15:0]                     do_m;
reg                                         we_in;
reg                                         re_in;
                                         

top top_inst ( 
                        .ADR_IN  (ADR_IN), 
                        .ADR_OUT (ADR_OUT), 
                        .BDR_IN (BDR_IN),
                        .BDR_OUT (BDR_OUT),  
                        .DIN (DIN), 
                        .DOUT (DOUT), 
                        .RE_IN (RE_IN),  
                        .WE_IN (WE_IN),  
                        .NRST (NRST), 
                        .CLK (CLK), 
                        .RDY (RDY), 
                        .WE_OUT (WE_OUT),
                        .CKE (CKE), 
                        .CS (CS), 
                        .RAS (RAS), 
                        .CAS (CAS),
                        .DQ (DQ)  
);
// connection between SDRAM and mem_controller
assign #20 adr_out = ADR_OUT; 
assign #20 bdr_out = BDR_OUT;  
assign #20 we_out  = WE_OUT;  
assign #20 cke     = CKE;       
assign #20 cs      = CS;        
assign #20 ras     = RAS;       
assign #20 cas     = CAS ;       
assign #20 dq      = DQ;    

IS42S16160 memory_inst (
                        .Dq(dq),
                        .Addr(adr_out),
                        .Ba(bdr_out),
                        .Clk(CLK),
                        .Cke(cke),
                        .Cs_n(cs),
                        .Ras_n(ras),
                        .Cas_n(cas),
                        .We_n(we_out),
                        .Dqm(2'b00)
);

//connection between MARCH tester and controller

assign rdy      = RDY; 
assign dout     = DOUT;  
assign ADR_IN   = adr_in;  
assign DIN      = do_m;
assign WE_IN    = we_in;
assign RE_IN    = re_in;


march
    #(
        .ADR_WIDTH  (),                                      // bit amoiunt of address reg
        .DATA_WIDTH (),                                      // width of data stored in data cell of sdram
        .ITERATION  (),                                      // how many times the memory will be scanned and filled
        .POWER_OF_THE_CHECKED_ADRESSES  ()                   // amount of bits subtract one, which will be used for counter, that roll adresses
                                                             // as an example 11 give a 2^11 = 2048 cells form 0 that will be checked during test
                                                             // for purposes of full mem check use 16                
    )
    march_inst
    (
        .CLK        (CLK),                                   //  in, u[ 1 ], Clock
        .NRESET     (NRST),                                  //  in, u[ 1 ], Async. negedge reset
        .MEM_RDY    (rdy),                                   //  in, u[ 1 ], Memory controller ready
        .DI         (dout),                                  //  in, u[ DATA_WIDTH ], Data from RAM
        .A          (adr_in),                               // out, u[ ADR_WIDTH ] , Address
        .DO         (do_m),                                  // out, u[ DATA_WIDTH ], Data to RAM
        .WE         (we_in),                                 // out, u[ 1 ], Write enable for memory
        .RE         (re_in),                                 // out, u[ 1 ], Read enable for memory
        .RDY        (RDY_BUTTON),                            // out, u[ 1 ],  Ready
        .FLAG       (FLAG_BUTTON),                           // out, u[ 1 ],  error flag
        .ADDR_ERR   (ADDR_ERR),                              // out, u[ ADR_WIDTH ], address of error
        .VALUE_ERR  (VALUE_ERR),                             // out, u[ 1 ],  value of error
        .VALUE_EXP  (VALUE_EXP)                              // out, u[ 1 ],  expected value
    );         
   


initial begin
    #100;
    CLK = 0;
    NRST = 0; 
    #100;
    NRST = 1;

    forever begin
    #35;
    CLK = ~CLK;
    end

end

endmodule