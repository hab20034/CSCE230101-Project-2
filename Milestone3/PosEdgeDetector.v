module PosEdgeDetector(
    input clk, reset, x,
    output z
);
   
reg [1:0] state, nextState;
parameter [1:0] A = 2'b00, B = 2'b01, C = 2'b10;

always @(*) begin 
    case (state) 
        A: nextState = (x == 0) ? A : B;
        B: nextState = (x == 0) ? A : C;
        C: nextState = (x == 0) ? A : C;
        default: nextState = A;
    endcase
end

always @(posedge clk or posedge reset) begin
    if (reset)
        state <= A;
    else
        state <= nextState;
end

assign z = (state == C);
 
endmodule
