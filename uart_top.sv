module top; 
import fifo_pkg::*; 
fifo_if vif(); 
// DUT 
async_fifo dut ( 
.wr_clk(vif.wr_clk), 
.rd_clk(vif.rd_clk), 
.rst(vif.rst), 
.wr_en(vif.wr_en), 
.wr_data(vif.wr_data), 
.full(vif.full), 
.rd_en(vif.rd_en), 
.rd_data(vif.rd_data), 
.empty(vif.empty) 
); 
// Write Clock 
initial begin 
vif.wr_clk = 0; 
forever #5 vif.wr_clk = ~vif.wr_clk; 
end 
// Read Clock (different freq) 
initial begin 
vif.rd_clk = 0; 
forever #7 vif.rd_clk = ~vif.rd_clk; 
end 
// Reset 
initial begin 
vif.rst = 1; 
vif.wr_en = 0; 
vif.rd_en = 0; 
#20 vif.rst = 0; 
end 
// Test 
test t(vif); 
endmodule