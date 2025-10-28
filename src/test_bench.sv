`timescale 100ps / 1ps

module memory_controller_tb();
logic      [12:0]                    ADR_IN; 
wire       [12:0]                    ADR_OUT; 
logic      [1:0]                     BDR_IN;
wire       [1:0]                     BDR_OUT; 
logic      [15:0]                    DIN; 
logic      [15:0]                    DOUT; 
logic                                RE_IN;  
logic                                WE_IN; 
wire                                 WE_OUT; 
logic                                NRST; 
logic                                CLK; 
logic                                RDY; 
wire                                 CKE;       
wire                                 CS;        
wire                                 RAS;       
wire                                 CAS;       
wire      [15:0]                     DQ;        

int                                  cnt;
int                                  addr_row;
int                                  addr_collumn;
logic     [1:0][12:0][8:0][15:0]     mem_doubler;

memory_controller memory_contoller_inst ( 
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

IS42S16160 memory_inst (
                        .Dq(DQ),
                        .Addr(ADR_OUT),
                        .Ba(BDR_OUT),
                        .Clk(CLK),
                        .Cke(CKE),
                        .Cs_n(CS),
                        .Ras_n(RAS),
                        .Cas_n(CAS),
                        .We_n(WE_OUT),
                        .Dqm(2'b00)
);

task mem_WRITE_row (output logic [12:0] ADR_IN);
        ADR_IN = addr_row;
endtask

task mem_WRITE_collumn (output logic [12:0] ADR_IN);
        ADR_IN = addr_collumn;
endtask

task automatic mem_WRITE (ref logic CLK, input logic RDY, inout logic [12:0] ADR_IN, inout logic [1:0] BDR_IN, output logic RE_IN, output logic WE_IN, output logic [15:0] DIN);

                @(posedge CLK);
                if (RDY) begin
                        if (addr_collumn < 512) begin
                                mem_WRITE_row (ADR_IN);
                                WE_IN = 1;
                                RE_IN = 0;
                                DIN = $urandom();
                                mem_doubler [BDR_IN][addr_row][addr_collumn] = DIN;
                                @(posedge CLK)
                                mem_WRITE_collumn (ADR_IN);
                                addr_collumn += 1;
                                //wait for write command and tDPL
                                @(posedge CLK);
                                @(posedge CLK);
                                @(posedge CLK);
                                if (&addr_row && addr_collumn >= 512)
                                        BDR_IN = BDR_IN + 1;
                        end
                        else begin
                                addr_row = addr_row + 1;
                                addr_collumn = 0;
                                mem_WRITE_row (ADR_IN);
                                WE_IN = 1;
                                RE_IN = 0;
                                DIN = $urandom();
                                @(posedge CLK);
                                mem_WRITE_collumn (ADR_IN);
                                addr_collumn += 1;
                                //wait for write command and tDPL
                                @(posedge CLK);
                                @(posedge CLK);
                                @(posedge CLK);
                        end
                end

endtask

task automatic mem_READ (ref logic CLK, input logic RDY, inout logic ADR_IN, inout logic BDR_IN, output logic RE_IN, output logic WE_IN);

                @(posedge CLK);
                if (RDY) begin
                        ADR_IN = ADR_IN + 1;
                        if (&ADR_IN)
                                BDR_IN = BDR_IN + 1;
                        WE_IN = 0;
                        RE_IN = 1;
                end

endtask

 always begin
        #35; CLK = ~CLK;
    end

initial begin
        
        //reseting
        #5;
        NRST = 0;
        #10;
        NRST = 1;
        #5
        CLK = 1;

        addr_row = addr_row + 1;
        addr_collumn = 0;

        repeat (14400)
                @(posedge CLK);

        repeat (16777216)
                mem_WRITE(CLK, RDY, ADR_IN, BDR_IN, RE_IN, WE_IN, DIN);

end
endmodule