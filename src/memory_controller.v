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
parameter REFR_TIME = 9142000; //cycles (< 64 ms), TIME_TO_REFRESH, 857 cycles is in stock
parameter RP_TIME = 3;     //cycles (15 ns), REQUIRED_PRECHARGE_TIME
parameter RC_TIME = 9;    //cycles (60 ns), REQUIRED_REFRESH_TIME
parameter DPL_TIME = 2;  //cycles (14 ns), REQUIRED_WRITE_TO_PRECHARGE_TIME
localparam init_delay  =  14290;  // INIT_DELAY, пока без формул
localparam REFR_TIME_width = $clog2(REFR_TIME);          //counter width due to refresh time


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


reg [3:0] state, next_state;
reg [REFR_TIME_width - 1: 0] counter, counter_db;
reg init_flag;
reg MRS_flag;
reg ACTIVE_flag;

assign DQ = (RDY && WE_IN) ? DIN : 16'bz;

always @(posedge CLK or negedge NRST) 
    begin
        if (!NRST) begin
            state       <= INIT_HOLD;
            init_flag   <= 1;
            MRS_flag    <= 0;
            ACTIVE_flag <= 0;
            counter     <= 0;
            counter_db  <= 0;
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
                            
                            //init task
                            CKE = 1;
                            RAS = 1;
                            CS = 0;
                            CAS = 1;
                            WE_OUT = 1;
                            RDY = 0;
                            ADR_OUT  = 13'bz;
                            BDR_OUT = 2'bz;
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

                            //NOP command //in IDLE state operating NOP command
                            ADR_OUT  = 13'bz;
                            BDR_OUT = 2'bz;
                            CKE = 1;
                            CS = 0;
                            RAS = 1;
                            CAS = 1;
                            WE_OUT = 1;
                            RDY = 1;
            end
            
            PRECHARGE:      begin
                            if ( (counter - counter_db) >= RP_TIME ) 
                                    next_state = IDLE;
                            
                            //PRECHARGE command
                            ADR_OUT [9:0] = 10'bz;
                            ADR_OUT [12:11] = 2'bz;
                            ADR_OUT [10] = 0;
                            BDR_OUT = BDR_IN;
                            CKE = 1;
                            CS = 0;
                            RAS = 0;
                            CAS = 1;
                            WE_OUT = 0;
                            RDY = 1;

            end

            PRECHARGE_ALL:  begin
                            if ( (counter - counter_db) >= RP_TIME ) begin
                                if ( init_flag )
                                    next_state = AUTO_REFR;
                                else
                                    next_state = IDLE;
                            end
                            
                            //PRECHRGE_ALL command
                            ADR_OUT [9:0] = 10'bz;
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


            AUTO_REFR:      begin
                            if ( (counter - counter_db) >= RC_TIME ) begin
                                next_state = IDLE;
                            end
                            
                            //AUTO_REFR command
                            ADR_OUT  = 13'bz;
                            BDR_OUT = 2'bz;
                            CKE = 1;
                            CS = 0;
                            RAS = 0;
                            CAS = 1;
                            WE_OUT = 0;
                            RDY = 0;
            end

            MRS:            begin
                            next_state = IDLE;

                            //register configuration
                            if   ( init_flag ) begin
                                BDR_OUT = 2'b00;
                                ADR_OUT = 13'b000_0_00_011_0_111;
                            end
                            else begin
                                BDR_OUT = 2'b00;
                                ADR_OUT = 13'b000_0_00_011_0_111;
                            end    

                            //MRS command
                            CKE = 1;
                            CS = 0;
                            RAS = 0;
                            CAS = 0;
                            WE_OUT = 0;
                            RDY = 0;
            end

            //in case of developing a device that can operate in burst and random-access modes need to make READ and READA
            ACTIVE:         begin
                            next_state = IDLE;
                            
                            //ACTIVE command
                            BDR_OUT = BDR_IN;
                            ADR_OUT [12:0] = ADR_IN [12:0]; 
                            CKE = 1;
                            CS = 0;
                            RAS = 0;
                            CAS = 1;
                            WE_OUT = 1;
                            RDY = 0;
            end
            
            READ:           begin
                            next_state = PRECHARGE;
                            
                            //READ command
                            BDR_OUT = BDR_IN;
                            ADR_OUT [9:0] = ADR_IN [9:0];
                            ADR_OUT [10] = 0;
                            ADR_OUT [12:11] = 2'bz;
                            CKE = 1;
                            CS = 0;
                            RAS = 1;
                            CAS = 0;
                            WE_OUT = 1;
                            RDY = 0;
            end 

            WRITE:          begin
                            if ( (counter - counter_db) >= DPL_TIME )
                                next_state = PRECHARGE;
                            
                            //WRITE command
                            BDR_OUT = BDR_IN;
                            ADR_OUT [9:0] = ADR_IN [9:0];
                            ADR_OUT [10] = 0;
                            ADR_OUT [12:11] = 2'bz;
                            CKE = 1;
                            CS = 0;
                            RAS = 1;
                            CAS = 0;
                            WE_OUT = 0;
                            RDY = 0;
            end
            
            default:        begin
                            next_state = IDLE;
                            
                            //NOP command
                            ADR_OUT  = 13'bz;
                            BDR_OUT = 2'bz;
                            CKE = 1;
                            CS = 0;
                            RAS = 1;
                            CAS = 1;
                            WE_OUT = 1;
                            RDY = 0;
                            
            end
        endcase
    end

endmodule
