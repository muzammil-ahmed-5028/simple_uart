module uart_rx (
    input logic         clk,
    input logic         arst_n,

    input logic  [31:0] cpb_i,
    input logic         rx_i,

    output logic [7:0]  rx_data_o,
    output logic        rx_done_o,
    output logic        rx_busy_o
);

typedef enum {
    IDLE,
    CHECK_START,
    RECIEVE_DATA,
    CHECK_STOP,
    DONE
} rx_state_t;

rx_state_t      rx_state;

logic           rx_sync;
logic           rx_sync_d;
logic           falling_edge;
logic   [2:0]   rx_bit_idx;
logic   [7:0]   rx_shift;
logic   [32:0]  casted_cpb;
logic   [32:0]  stop_cycles;
logic   [32:0]  baud_counter;
assign casted_cpb = {1'b0,cpb_i};

sync uart_rx_sync(
    .dst_clk(clk),
    .arst_n(arst_n),
    .src_data(rx_i),
    .dst_data(rx_sync)
);

always_ff@(posedge clk or negedge arst_n) begin
    if (!arst_n) rx_sync_d <= '0;
    else rx_sync_d  <= rx_sync;
end

assign falling_edge = rx_sync_d && (!rx_sync);

always_ff@(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        rx_done_o       <= '0;
        rx_busy_o       <= '0;
        rx_data_o       <= '0;
        rx_bit_idx      <= '0;
        baud_counter    <= '0;
        rx_shift        <= '0;
    end
    else begin
        case (rx_state)
            IDLE        : begin
                rx_state <= (falling_edge) ? CHECK_START : IDLE;
                baud_counter <= '0;
            end
            CHECK_START : begin
                if(baud_counter == ((casted_cpb >> 1)-1)) begin
                    rx_state        <= (!rx_sync) ? RECIEVE_DATA : IDLE;
                    baud_counter    <= '0;
                    rx_busy_o       <= '1;
                end
                else baud_counter <=  baud_counter + 1'b1;
            end
            RECIEVE_DATA: begin
                rx_busy_o   <= '1;
                if (baud_counter == (casted_cpb -1)) begin
                    rx_bit_idx  <= (rx_bit_idx == 3'b111) ? '0          : rx_bit_idx + 1;
                    rx_state    <= (rx_bit_idx == 3'b111) ? CHECK_STOP  : RECIEVE_DATA;
                    rx_shift[rx_bit_idx] <= rx_sync;
                    baud_counter <= '0;
                end
                else baud_counter <=  baud_counter + 1'b1;
            end
            CHECK_STOP: begin
                rx_busy_o <= '1;
                if (baud_counter == (casted_cpb -1)) begin
                    if(rx_sync == 1'b1) begin
                        rx_data_o <= rx_shift;
                        rx_state <= DONE;
                    end 
                    else rx_state <= IDLE;
                end
                else baud_counter <=  baud_counter + 1'b1;
            end

            DONE: begin
                rx_state <= IDLE;
                rx_busy_o <= '0;
                rx_done_o <= '1;
            end
        endcase
    end
end


endmodule