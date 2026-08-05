module uart_rx (
    input logic clk,
    input logic arst_n,

    input logic cpb_i,
    input logic stp_i,
    input logic rx_i,

    output logic rx_data_o,
    output logic rx_done_o,
    output logic rx_busy_o
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
logic           rx_bit_idx;
logic   [32:0]  casted_cpb;
logic   [32:0]  stop_cycles;

assign casted_cpb = {1'b0,cpb_i};

always_comb begin
    case(stp_i)
        2'b00: stop_cycles = casted_cpb;
        2'b01: stop_cycles = casted_cpb + (casted_cpb >> 1);
        2'b10: stop_cycles = (1 << casted_cpb);
        default: stop_cycles = (1 << casted_cpb);
    endcase    
end

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
        
    end
end


endmodule