INTERFACE 
interface fifo_if; 
 
  logic wr_clk; 
  logic rd_clk; 
  logic rst; 
 
  logic wr_en; 
  logic [7:0] wr_data; 
  logic full; 
 
  logic rd_en; 
  logic [7:0] rd_data; 
  logic empty; 
 
endinterface 