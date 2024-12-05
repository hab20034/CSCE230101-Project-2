module synchronizer (
    input Clk,
    input SIG,
    output SIG1
);
reg meta;
reg sig1_reg;

always @(posedge Clk) begin
    meta <= SIG;
    sig1_reg <= meta;
end

assign SIG1 = sig1_reg;
endmodule
