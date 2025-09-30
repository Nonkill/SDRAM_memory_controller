module memory_controller( ADR_IN, ADR_OUT, BDR, DIN, DOUT, RE_IN,  WE_IN, WE_OUT, NRST, CLK, RDY, CKE, CS, RAS, CAS  );

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
parameter REFR_TIME = 8192; //cycles (64 ms), TIME BEFORE REFRESH
parameter RP_TIME = 3;     //cycles (15 ns), REQUIRED_PRECHARGE_TIME
parameter RC_TIME = 9;    //cycles (60 ns), REQUIRED_REFRESH_TIME
localparam init_delay  = $ceil (( 100 * 10^(-6) ) / CAS_LATENCY);  // INIT_DELAY
localparam REFR_count_width = $ceil ($clog2(REFR_TIME));          //counter width due to refresh time


input  wire  [ROW_ADRESS - 1:0]    ADR_IN;
input  wire  [BANK_ADRESS - 1:0]   BDR_IN;
input  wire  [COLUMN_WIDTH - 1:0]  DIN;
input  wire                        RE_IN;
input  wire                        WE_IN;
input  wire                        NRST;
input  wire                        CLK;
output reg  [ROW_ADRESS - 1:0]     ADR_OUT;
output reg  [BANK_ADRESS - 1:0]    BDR_OUT;
output reg  [COLUMN_WIDTH - 1:0]   DOUT;
output reg                         RDY;
output reg                         CKE;
output reg                         CS;          //active low
output reg                         RAS;         //active low
output reg                         CAS;         //active low
output reg                         WE_OUT;      //active low

//localparam [3:0] NOP        = 4'b0000;
localparam [3:0] INIT_HOLD  = 4'b0001;
localparam [3:0] PRECHARGE_ALL  = 4'b0010;
localparam [3:0] IDLE       = 4'b0011 ;
localparam [3:0] AUTO_REFR  = 4'b0100 ;
localparam [3:0] MRS        = 4'b0101 ;            //mode register setup

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

always @(posedge CLK or NRST) 
    begin
        if (!NRST)
            state <= INIT_HOLD;
        else 
            state <= next_state;
        
        counter <= counter + 1;                                         //encount every clock to calculate refresh time and etc

        if  ((next_state == PRECHARGE_ALL && state != PRECHARGE_ALL) 
             or 
             (next_state == AUTO_REFR && state != AUTO_REFR)) 
            counter_db <= counter;

        if (state == IDLE && (init_flag && !MRS_flag))
            MRS_flag <= 1;
        if (state == IDLE && (init_flag && MRS_flag))
            MRS_flag <= 0;

        if (state == MRS)
            init_flag <= 0;
        //if ( (state == AUTO_REFR) && (init_flag) )
        //    counter_db <= counter;
    end


always @(*)
    begin
        next_state = state;

        //вот тут условие if-else, которое стопроцентно делает refresh если счётчик досчитает до 64 мс, а потом уже свитч кейс

        case (state)

            IDLE:           begin
                            //first transition after refresh - AUTO_REFR
                            if (init_flag && !MRS_flag) 
                                next_state = AUTO_REFR;
                            
                            //second transition after refresh - MRS
                            if (init_flag && MRS_flag) 
                                next_state = MRS;
                            
                            nop;  //in IDLE state operating NOP command
            end

            INIT_HOLD:      begin
                            if (counter >= init_delay)
                                next_state = PRECHARGE_ALL;
                            init_hold;
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
                            if ((counter - counter_db) >= RC_TIME) begin
                                next_state = IDLE;
                            end
                            auto_refr;
            end

            //дописать
            MRS:            begin
                            next_state = IDLE;
                            mrs;
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
        init_flag = 1;
    end
endtask

task prechrage_all;
    begin
        
        ADR_OUT [10] = 1;
        CKE = 1;
        CS = 0;
        RAS = 0;
        CAS = 1;
        WE_OUT = 0;
        RDY = 0;

    end
endtask

task auto_refr;
    begin
        
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
        CKE = 1;
        CS = 0;
        RAS = 1;
        CAS = 1;
        WE = 1;
        RDY = 0;
    end 
endtask

task mrs;
    begin
        
        if (init_flag) begin
            BDR_OUT = 2'b00;
            ADR_OUT = 13'b000_0_00_011_0_111;
        end

        CKE = 1;
        CS = 0;
        RAS = 0;
        CAS = 0;
        WE_OUT = 0;
        RDY = 1;

    end
endtask

endmodule
