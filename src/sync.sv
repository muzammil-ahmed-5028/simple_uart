module sync(
    input logic dst_clk,
    input logic arst_n,
    input logic src_data,
    output logic dst_data
);

logic sync_stage;

always_ff @(posedge clk or negedge arst_n) begin
    if(!arst_n) begin
        dst_data        <= '0;
        sync_stage      <= '0;
    end
    else begin
        sync_stage      <= src_data;
        dst_data        <= sync_stage;
    end
end

endmodule