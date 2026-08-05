module baud_counter(
    input logic clk,
    input logic arst_n,

    input logic [32:0]  cpb_i,
    output logic [32:0] baud_counter,
    output logic baud_tick
);

always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        baud_counter <= '0;
        baud_tick <= '0;
    end
    else begin
        if (baud_counter == (cpb_i -1)) begin
            baud_counter    <= '0;
            baud_tick       <= '1;
        end
        else begin
            baud_counter++;
        end
    end 
end

endmodule