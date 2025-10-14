module memory_controller( ADR_IN, ADR_OUT, BDR_IN, BDR_OUT, DIN, DOUT, RE_IN,  WE_IN, WE_OUT, NRST, CLK, RDY, CKE, CS, RAS, CAS, DQ );

//parameterized charactheristics of SDRAM
parameter BANK_NUM = 4;
parameter ROW_DEPTH = 8192;
parameter COLUMN_DEPTH = 512;
parameter COLUMN_WIDTH = 16;
parameter BANK_ADRESS = $clog2(BANK_NUM);
parameter ROW_ADRESS = $clog2(ROW_DEPTH);
parameter COLUMN_ADRESS = $clog2(COLUMN_DEPTH);

//delays and timings
parameter CAS_LATENCY = 7;   //ns,             (CAS_LATENCY = 3)
parameter REFR_TIME = 8182; //cycles (< 64 ms), TIME_TO_REFRESH, 10 cycles is in stock
parameter RP_TIME = 3;     //cycles (15 ns), REQUIRED_PRECHARGE_TIME
parameter RC_TIME = 9;    //cycles (60 ns), REQUIRED_REFRESH_TIME
parameter DPL_TIME = 2;  //cycles (14 ns), REQUIRED_WRITE_TO_PRECHARGE_TIME
localparam init_delay  =  ((( 100 * 10^(-6) ) + CAS_LATENCY - 1) / CAS_LATENCY);  // INIT_DELAY
parametr REFR_count_width = ($clog2(REFR_TIME));          //counter width due to refresh time


input  wire  [ROW_ADRESS - 1:0]    ADR_IN;
input  wire  [BANK_ADRESS - 1:0]   BDR_IN;
input  wire  [COLUMN_WIDTH - 1:0]  DIN;
input  wire                        RE_IN;
input  wire                        WE_IN;
input  wire                        NRST;
input  wire                        CLK;
output reg   [ROW_ADRESS - 1:0]    ADR_OUT;
output reg   [BANK_ADRESS - 1:0]   BDR_OUT;
output reg   [COLUMN_WIDTH - 1:0]  DOUT;
output reg                         RDY;
output reg                         CKE;
output reg                         CS;          //active low
output reg                         RAS;         //active low
output reg                         CAS;         //active low
output reg                         WE_OUT;      //active low
inout  wire  [COLUMN_WIDTH - 1:0]  DQ;


localparam [3:0] INIT_HOLD      =  4'b0000;
localparam [3:0] PRECHARGE      =  4'b0001;
localparam [3:0] PRECHARGE_ALL  =  4'b0010;
localparam [3:0] IDLE           =  4'b0011;
localparam [3:0] AUTO_REFR      =  4'b0100;
localparam [3:0] MRS            =  4'b0101;            //mode register setup
localparam [3:0] ACTIVE         =  4'b0110;
localparam [3:0] READ           =  4'b0111;
localparam [3:0] WRITE          =  4'b1000;

/*localparam [3:0] POWER_ON = 5'b ;
localparam [3:0] PRECHARGE = 5'b ;
localparam [3:0] WRITE = 5'b ;
localparam [3:0] WRTIE_SUSP = 5'b ;
localparam [3:0] WRITEA = 5'b ;
localparam [3:0] WRITEA_SUSP = 5'b ;
localparam [3:0] READ = 5'b ;
localparam [3:0] READ_SUSP = 5'b ;
localparam [3:0] READA = 5'b ;
localparam [3:0] READA_SUSP = 5'b ;
localparam [3:0] ROW_ACTIVE = 5'b ;
localparam [3:0] ACTIVE_PWR_DWN = 5'b ;
localparam [3:0] IDLE = 5'b ;
localparam [3:0] PWR_DWN = 5'b ;
localparam [3:0] AUTO_REFR = 5'b ;
localparam [3:0] SELF_REFR = 5'b ;
localparam [3:0] MRS = 5'b ;*/

reg [3:0] state, next_state;
reg [REFR_count_width - 1: 0] counter, counter_db;
reg init_flag;
reg MRS_flag;
reg ACTIVE_flag;
reg direction;

assign DQ = (RDY && WE_IN) ? DIN : 16'bz;

always @(posedge CLK or negedge NRST) 
    begin
        if (!NRST) begin
            state <= INIT_HOLD;
            init_flag = 1;
            end
        else  begin
            state <= next_state;
            counter <= counter + 1;                                         //encount every clock to calculate refresh time and etc

        // a bunch of demands that save clock value to a doubler
        if  ((next_state == PRECHARGE_ALL && state != PRECHARGE_ALL) 
             || 
             (next_state == AUTO_REFR && state != AUTO_REFR)
             ||
             (next_state == PRECHARGE && state != PRECHARGE)
             ||
             (next_state == WRITE && state != WRITE)) 
            counter_db <= counter;

        if (state == IDLE && (init_flag && !MRS_flag))
            MRS_flag <= 1;
        if (state == IDLE && (init_flag && MRS_flag))
            MRS_flag <= 0;
        if (state == MRS)
            init_flag <= 0;
            
        if (state == ACTIVE)
            ACTIVE_flag <= 1;
            
        if (state == IDLE)
            ACTIVE_flag <= 0;
        //мб надо будет добавить условие с ? и приравнивать к x or z
        if ( RDY && RE_IN ) 
             DOUT <= DQ;

        //if ( (state == AUTO_REFR) && (init_flag) )
        //    counter_db <= counter;
        end

    end


always @(*)
    begin

        next_state = state;

        //вот тут условие if-else, которое стопроцентно делает refresh если счётчик досчитает до 64 мс, а потом уже свитч кейс

        case (state)

            INIT_HOLD:      begin
                            if ( counter >= init_delay )
                                next_state = PRECHARGE_ALL;
                            init_hold;
            end

            IDLE:           begin
                            //refreshing containments after <64 ms
                            if ( counter >= REFR_TIME )
                                next_state = AUTO_REFR;
                            
                            //first transition after refresh - AUTO_REFR
                            if ( init_flag && !MRS_flag ) 
                                next_state = AUTO_REFR;
                            
                            //second transition after refresh - MRS
                            if ( init_flag && MRS_flag ) 
                                next_state = MRS;

                            //preapring row access
                            if ( (RE_IN || WE_IN) && !ACTIVE_flag ) begin
                                next_state = ACTIVE;
                            end
                            //leap to READ comand after activation and holding nop
                            if ( RE_IN && ACTIVE_flag)
                                next_state = READ;

                            //leap to WRITE comand after activation and holding nop
                            if ( WE_IN && ACTIVE_flag)
                                next_state = WRITE;
                                
                            nop;  //in IDLE state operating NOP command
            end
            
            PRECHARGE:      begin
                            if ( (counter - counter_db) >= RP_TIME ) 
                                    next_state = IDLE;
                                    // RDY setup leaved here, beacuse state switch coincides with valid data out
                                    RDY = 1;
                            prechrage;

            end

            PRECHARGE_ALL:  begin
                            if ( (counter - counter_db) >= RP_TIME ) begin
                                if ( init_flag )
                                    next_state = AUTO_REFR;
                                else
                                    next_state = IDLE;
                            end
                            prechrage_all;
            end


            AUTO_REFR:      begin
                            if ( (counter - counter_db) >= RC_TIME ) begin
                                next_state = IDLE;
                            end
                            auto_refr;
            end

            MRS:            begin
                            next_state = IDLE;
                            mrs;
            end

            //in case of developing a device that can operate in burst and random-access modes need to make READ and READA
            ACTIVE:         begin
                            next_state = IDLE;
                            active;
            end
            
            READ:           begin
                            next_state = PRECHARGE;
                            read;
            end 

            WRITE:          begin
                            if ( (counter - counter_db) >= DPL_TIME )
                                next_state = PRECHARGE;
                            write;
            end
            
            default:        begin
                            next_state = IDLE;
                            
            end
        endcase
    end

task init_hold;
    begin

        CKE = 1;
        CS = 0;
        RAS = 1;
        CAS = 1;
        WE_OUT = 1;
        RDY = 0;
        ADR_OUT  = 13'bz;
        BDR_OUT = 2'bz;
    end
endtask

task prechrage;
    begin
        ADR_OUT [9:0] = 9'bz;
        ADR_OUT [12:11] = 2'bz;
        ADR_OUT [10] = 0;
        BDR_OUT = BDR_IN;
        CKE = 1;
        CS = 0;
        RAS = 0;
        CAS = 1;
        WE_OUT = 0;

    end
endtask

task prechrage_all;
    begin
        
        ADR_OUT [9:0] = 9'bz;
        ADR_OUT [12:11] = 2'bz;
        ADR_OUT [10] = 1;
        BDR_OUT = 2'bz;
        CKE = 1;
        CS =  0;
        RAS = 0;
        CAS = 1;
        WE_OUT = 0;
        RDY = 0;

    end
endtask

task auto_refr;
    begin
        
        ADR_OUT  = 13'bz;
        BDR_OUT = 2'bz;
        CKE = 1;
        CS = 0;
        RAS = 0;
        CAS = 1;
        WE_OUT = 0;
        RDY = 0;
        
    end
endtask

task nop;
    begin
        
        ADR_OUT  = 13'bz;
        BDR_OUT = 2'bz;
        CKE = 1;
        CS = 0;
        RAS = 1;
        CAS = 1;
        WE_OUT = 1;
        RDY = 0;

    end 
endtask

task mrs;
    begin
        
        if   ( init_flag ) begin
            BDR_OUT = 2'b00;
            ADR_OUT = 13'b000_0_00_011_0_111;
        end
        else begin
            BDR_OUT = 2'b00;
            ADR_OUT = 13'b000_0_00_011_0_111;
        end    

        CKE = 1;
        CS = 0;
        RAS = 0;
        CAS = 0;
        WE_OUT = 0;
        RDY = 0;

    end
endtask

task active;
    begin

        CKE = 1;
        CS = 0;
        RAS = 0;
        CAS = 1;
        WE_OUT = 1;
        RDY = 0;
        BDR_OUT = BDR_IN;
        ADR_OUT [12:0] = ADR_IN [12:0]; 

    end
endtask

task read;
    begin

        CKE = 1;
        CS = 0;
        RAS = 1;
        CAS = 0;
        WE_OUT = 1;
        RDY = 0;
        BDR_OUT = BDR_IN;
        ADR_OUT [9:0] = ADR_IN [9:0];
        ADR_OUT [10] = 0;
        ADR_OUT [12:11] = 2'bz;

    end
endtask

task write;
    begin

        CKE = 1;
        CS = 0;
        RAS = 1;
        CAS = 0;
        WE_OUT = 0;
        RDY = 0;
        BDR_OUT = BDR_IN;
        ADR_OUT [9:0] = ADR_IN [9:0];
        ADR_OUT [10] = 0;
        ADR_OUT [12:11] = 2'bz;

    end
endtask

endmodule
