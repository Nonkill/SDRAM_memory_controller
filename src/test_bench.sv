`timescale 100ps / 1ps

module memory_controller_tb();

int                                  cnt;
int                                  errors;
logic     [12:0]                     addr_row;
logic     [8:0]                      addr_collumn;
logic     [15:0]                     mem_doubler [3:0][8192:0][8:0];

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
wire       [12:0]                    adr_out; 
wire       [1:0]                     bdr_out;  
wire                                 we_out;  
wire                                 cke;       
wire                                 cs;        
wire                                 ras;       
wire                                 cas;       
wire      [15:0]                     dq;  


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
 
assign #20 ADR_OUT = adr_out; 
assign #20 BDR_OUT = bdr_out;  
assign #20 WE_OUT  = we_out;  
assign #20 CKE     = cke;       
assign #20 CS      = cs;        
assign #20 RAS     = ras;       
assign #20 CAS     = cas;       
assign #20 DQ      = dq;    

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

task automatic mem_ACTIVE_select_row (output logic [12:0] ADR_IN);
        #10;
        ADR_IN = addr_row;
endtask

task automatic mem_WRITE_collumn (output logic [12:0] ADR_IN);
        #10;
        ADR_IN = addr_collumn;
endtask

task automatic mem_WRITE (ref logic CLK, inout logic [12:0] addr_row, inout logic [8:0] addr_collumn, input logic RDY, inout logic [12:0] ADR_IN, inout logic [1:0] BDR_IN, output logic RE_IN, output logic WE_IN, output logic [15:0] DIN);

                //@(posedge CLK);
                if (RDY) begin
                        if (addr_collumn < 512) begin
                                ADR_IN = addr_row;
                                WE_IN = 1;
                                RE_IN = 0;
                                DIN = $urandom();
                                mem_doubler [BDR_IN][addr_row][addr_collumn] = DIN;
                                repeat (2) @(posedge CLK);
                                ADR_IN = addr_collumn;
                                addr_collumn += 1;
                                
                                //wait for write command and tDPL
                                repeat (3) @(posedge CLK);

                        end
                        else begin
                                if (&addr_row && (addr_collumn >= 512))
                                        BDR_IN = BDR_IN + 1;
                                
                                addr_row += 1;
                                addr_collumn += 1;
                                mem_ACTIVE_select_row (ADR_IN);
                                WE_IN = 1;
                                RE_IN = 0;
                                DIN = $urandom();
                                repeat (2) @(posedge CLK);
                                mem_WRITE_collumn (ADR_IN);
                                addr_collumn += 1;
                                //wait for write command and tDPL
                                repeat (3) @(posedge CLK);
                        end
                end

endtask

task automatic mem_READ (ref logic CLK, inout logic [12:0] addr_row, inout logic [8:0] addr_collumn, input logic RDY, input logic [15:0] DQ, inout logic [12:0] ADR_IN, inout logic [1:0] BDR_IN, output logic RE_IN, output logic WE_IN);

                @(posedge CLK);
                if (RDY) begin
                        if (addr_collumn < 512) begin
                                mem_ACTIVE_select_row (ADR_IN);
                                WE_IN = 0;
                                RE_IN = 1;
                                repeat (2) @(posedge CLK);
                                mem_WRITE_collumn (ADR_IN);
                                //wait for write command and tDPL
                                repeat (3) @(posedge CLK);
                                if ( DQ != mem_doubler [BDR_IN][addr_row][addr_collumn]) begin
                                        $error ("Found error in cell [%d][%d][%d]", BDR_IN, addr_row, addr_collumn);
                                        errors += 1;
                                end
                                addr_collumn += 1;

                        end
                        else begin
                                if (&addr_row && (addr_collumn >= 512))
                                        BDR_IN = BDR_IN + 1;
                                
                                addr_row += 1;
                                addr_collumn += 1;
                                mem_ACTIVE_select_row (ADR_IN);
                                WE_IN = 0;
                                RE_IN = 1;
                                repeat (2) @(posedge CLK);
                                mem_WRITE_collumn (ADR_IN);
                                addr_collumn += 1;
                                //wait for write command and tDPL
                                repeat (3) @(posedge CLK);
                                if ( DQ != mem_doubler [BDR_IN][addr_row][addr_collumn]) begin
                                        $error ("Found error in cell [%d][%d][%d]", BDR_IN, addr_row, addr_collumn);
                                        errors += 1;
                                end
                                addr_collumn += 1;

                        end
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

        WE_IN =  0;
        RE_IN =  0;
        DIN   = '0;
        BDR_IN = 0;
        addr_row = 0;
        addr_collumn = 0;

        repeat (14400)
                @(posedge CLK);

        //16777216 - full size
        repeat (200) begin
                mem_WRITE (CLK, addr_row, addr_collumn, RDY, ADR_IN, BDR_IN, RE_IN, WE_IN, DIN);
        end

        BDR_IN = 0;
        addr_row = 0;
        addr_collumn = 0;

        repeat(200) begin
                mem_READ (CLK, addr_row, addr_collumn, RDY, DQ, ADR_IN, BDR_IN, RE_IN, WE_IN);
        end

        RE_IN = 0;
        WE_IN = 0;

        $display ("Sim ended with %d errors", errors );
end
endmodule