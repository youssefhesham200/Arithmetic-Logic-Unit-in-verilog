`define NUM_BITS 4 

module half_adder(output sum,output carry,input a,input b);
   xor(sum, a, b);
   and(carry, a, b);
endmodule

module full_adder(output sum,output carry,input x,input y,input z);
   wire s1, c1, c2;
   half_adder h1(s1, c1, x, y);
   half_adder h2(sum, c2, s1, z);
   or(carry, c1, c2);
endmodule

module adder(output [N+1:0]sum, input[N:0] a, input [N:0] b);
	parameter N = `NUM_BITS-1;
	wire [N:0] carry;
	full_adder f1(sum[0],carry[0],a[0],b[0],0);
	generate
	genvar i;
	for(i=1;i<=N;i=i+1)
	begin
		full_adder f2(sum[i],carry[i],a[i],b[i],carry[i-1]);
	end
	endgenerate
	buf(sum[N+1],carry[N]);
endmodule

module subtract(output [N+1:0]sum, input[N:0] a, input [N:0] b);
	parameter N = `NUM_BITS-1;
	wire [N:0] carry;
	wire[N:0]c;
	generate
	genvar i;
	for(i=0;i<=N;i=i+1)
	begin
		not(c[i],b[i]);
	end
	endgenerate
	
	full_adder f1(sum[0],carry[0],a[0],c[0],1);
	generate
	for(i=1;i<=N;i=i+1)
	begin
		full_adder f2(sum[i],carry[i],a[i],c[i],carry[i-1]);
	end
	endgenerate
	buf(sum[N+1],carry[N]);
endmodule

module adder_one(output [N+1:0]sum, input[N:0] a);
	parameter N = `NUM_BITS-1;
	wire [N:0] carry;
	full_adder f1(sum[0],carry[0],a[0],0,1);
	
	generate
	genvar i;
	for(i=1;i<=N;i=i+1)
	begin
		full_adder f2(sum[i],carry[i],a[i],0,carry[i-1]);
	end
	endgenerate
	buf(sum[N+1],carry[N]);
endmodule


module subtract_one(output [N+1:0]sum, input[N:0] a);
	parameter N = `NUM_BITS-1;
	wire [N:0] carry;
	full_adder f1(sum[0],carry[0],a[0],1,0);
	
	generate
	genvar i;
	for(i=1;i<=N;i=i+1)
	begin
		full_adder f2(sum[i],carry[i],a[i],1,carry[i-1]);
	end
	endgenerate
	buf(sum[N+1],carry[N]);
endmodule

module bitwise_and(output [N+1:0] out, input[N:0] a, input[N:0] b);
	parameter N = `NUM_BITS-1;
	generate
	genvar i;
	for(i=0;i<=N;i=i+1)
	begin
		and (out[i],a[i],b[i]);
	end
	endgenerate
	buf(out[N+1],0);
endmodule

module bitwise_or(output [N+1:0] out, input[N:0] a, input[N:0] b);
	parameter N = `NUM_BITS-1;
	generate
	genvar i;
	for(i=0;i<=N;i=i+1)
	begin
		or (out[i],a[i],b[i]);
	end
	endgenerate
	buf(out[N+1],0);
endmodule

module bitwise_xor(output [N+1:0] out, input[N:0] a, input[N:0] b);
	parameter N = `NUM_BITS-1;
	generate
	genvar i;
	for(i=0;i<=N;i=i+1)
	begin
		xor (out[i],a[i],b[i]);
	end
	endgenerate
	buf(out[N+1],0);
endmodule


module shift_right(output [N+1:0]h, input[N:0]a);
	parameter N = `NUM_BITS-1;
	generate
	genvar i;
	for(i=0;i<N;i=i+1)
	begin
		buf(h[i],a[i+1]);
	end
	endgenerate
	buf(h[N],0);
	buf(h[N+1],0);
endmodule


module mux21(output Y,input D0,input D1,input S);

wire w1, w2, swire;

and (w1, D1, S), (w2, D0, swire);
not (swire, S);
or (Y, w1, w2);

endmodule


module mux41(output out,input a,input b,input c,input d,input s0,input s1);

wire  swire, w1, w2, w3, w4;

not (s0bar, s0), (swire, s1);
and (w1, a, s0bar, swire), (w2, b, s0bar, s1),(w3, c, s0, swire), (w4, d, s0, s1);
or(out, w1, w2, w3, w4);

endmodule


module alu_logic(output [N+1:0]out, input[N:0] a, input[N:0] b, input s0,input s1);
	parameter N = `NUM_BITS-1;
    wire [N+1:0] x,y,z,v;
	bitwise_and an(x,a,b);
	bitwise_or o(y,a,b);
	bitwise_xor  bitwise(z,a,b);
	shift_right right(v,a);
	
	generate
	genvar i;
	for(i=0;i<=N+1;i=i+1)
	begin
		mux41 m1(out[i],x[i] , y[i], z[i], v[i], s0, s1);
	end
	endgenerate
endmodule

module alu_arth(output [N+1:0]out, input[N:0] a, input[N:0] b, input s0,input s1);
    parameter N = `NUM_BITS-1;
    wire [N+1:0] x,y,z,v;
	adder an(x,a,b);
	subtract o(y,a,b);
	adder_one  bitwise(z,a);
	subtract_one right(v,a);

	generate
	genvar i;
	for(i=0;i<=N+1;i=i+1)
	begin
		mux41 m1(out[i],x[i] , y[i], z[i], v[i], s0, s1);
	end
	endgenerate
endmodule

module alu(output [N+1:0]out, input[N:0] a, input[N:0] b, input s0,input s1,input s3);
	parameter N = `NUM_BITS-1;
    wire [N+1:0] x,y;
	alu_logic logic1(x,a,b,s0,s1);
	alu_arth arth(y,a,b,s0,s1);
	
	generate
	genvar i;
	for(i=0;i<=N+1;i=i+1)
	begin
		mux21 m1(out[i], y[i],x[i],s3);
	end
	endgenerate
endmodule


module test();
parameter N = `NUM_BITS-1;
wire[N+1:0]A;
wire[N:0]b,c;
buf(b[0],1); buf(c[0],1);//1
buf(b[1],1); buf(c[1],1);//0
buf(b[2],0); buf(c[2],1);//0
buf(b[3],1); buf(c[3],1);//0


alu you(A,b,c,0,0,0);

initial
   begin
      $monitor("carray / A[4] = %b, A[3]=%b, A[2]=%b, A[1]=%b, A[0]=%b ", A[4], A[3], A[2], A[1], A[0]);
   end
endmodule
