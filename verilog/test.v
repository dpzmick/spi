module test(
    input clk,
    output out
);

always @(posedge clk) begin
    out = ~out;
end

endmodule
