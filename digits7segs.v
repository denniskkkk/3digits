/*
Copyright 2016 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
/*
Device ALTERA MAX10 FPGA 10M02SCU169
board test, a simple 3 digits 7 segments display module
up counter
By Dennis Ho.

*/
module digits7segs(
	input sys_clk,
	input sys_rst_n,
	output [7:0] seg_full,
	output seg_1,
	output seg_2,
	output seg_3
	);

// 7seg, 3digit
reg [35:0]count;
wire [2:0]cm;
assign seg_1 = cm[0];
assign seg_2 = cm[1];
assign seg_3 = cm[2];

always@(posedge sys_clk or negedge sys_rst_n)
begin
	if(!sys_rst_n)
		begin
			count <= 36'd0;
		end
	else if(count == 36'hfffffffff)
		begin
			count <= 36'd0;
		end
	else
		begin
			count <= count + 36'd1;
		end
end

seg_dec seg_dec_i (.dclk (sys_clk),.data(count[35:23]) , .seg(seg_full), .digitn(cm));
endmodule

module seg_dec ( dclk, 
              data, 
              seg,  
				  digitn	 
				);
				
input dclk;
input [11:0]data;
output [7:0]seg;
output [2:0]digitn;
reg [7:0] regseg;
reg [15:0]r_cnt;
reg [2:0] r_dg;
assign seg = regseg;
assign digitn = r_dg;

always @(posedge dclk) 
begin
if (r_cnt == 16'hc000) begin
	r_cnt <= 16'b0;
end
else 
   r_cnt <= r_cnt + 16'b1;
end

always @(*) begin
case (r_cnt[15:14]) 
    2'b00: r_dg = 3'b100; // h0000-h0fff
	 2'b01: r_dg = 3'b010; // h4000-h7fff
	 2'b10: r_dg = 3'b001; // h8000-hbfff
endcase
end

reg [3:0]segdata;
always @(*) begin
case (r_cnt[15:14]) 
    2'b00: segdata = data[3:0]; 
	 2'b01: segdata = data[7:4]; 
	 2'b10: segdata = data[11:8]; 
endcase
end

// bit7-0, dp, g, f, e, d, c, b, a
//--a--
//f   b
//--g--
//e   c
//--d--(dp)
always @(*)begin
case(segdata)
    4'h0: regseg = 8'b11000000;
    4'h1: regseg = 8'b11111001;
    4'h2: regseg = 8'b10100100;
    4'h3: regseg = 8'b10110000;
    4'h4: regseg = 8'b10011001;
    4'h5: regseg = 8'b10010010;
    4'h6: regseg = 8'b10000010;
    4'h7: regseg = 8'b11111000;
    4'h8: regseg = 8'b10000000;
    4'h9: regseg = 8'b10010000;
    4'ha: regseg = 8'b10001000;
    4'hb: regseg = 8'b10000011;
    4'hc: regseg = 8'b10100111;
    4'hd: regseg = 8'b10100001;
    4'he: regseg = 8'b10000110;
    4'hf: regseg = 8'b10001110;	 
    default: regseg = 8'b01111111;
endcase
end
endmodule