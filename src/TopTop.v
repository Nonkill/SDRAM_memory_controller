module TopTop ();


reg               [12:0]                    ADR_IN; 
reg               [1:0]                     BDR_IN;
reg               [15:0]                    DIN; 
reg                                         RE_IN;  
reg                                         WE_IN; 
wire                                        NRST; 
wire                                        CLK; 
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
reg              [4:0]                      counter;
reg              [4:0]                      counter_db;
reg              [4:0]                      difference;





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
//////sdfdsfsdfsdfsdfsdfsdfsd
assign adr_out = ADR_OUT; 
assign bdr_out = BDR_OUT;  
assign we_out  = WE_OUT;  
assign cke     = CKE;       
assign cs      = CS;        
assign ras     = RAS;       
assign cas     = CAS ;       
assign dq      = DQ;    

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

MARCH march_inst (
                        .
);         
                            
always @(posedge clk or negedge NRST)
    if (NRST)
        ADR_IN = '0;
        WE_IN = 0;
        RE_IN = 0;
        DIN = '0;




endmodule