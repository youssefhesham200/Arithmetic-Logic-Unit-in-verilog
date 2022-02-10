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


module adder(output [4:0]sum, input[3:0] a, input [3:0] b);
	wire [3:0] carry;
	full_adder f1(sum[0],carry[0],a[0],b[0],0);
	full_adder f2(sum[1],carry[1],a[1],b[1],carry[0]);
	full_adder f3(sum[2],carry[2],a[2],b[2],carry[1]);
	full_adder f4(sum[3],carry[3],a[3],b[3],carry[2]);
	buf(sum[4],carry[3]);
endmodule


module subtract(output [4:0]sum, input[3:0] a, input [3:0] b);
	wire [3:0] carry;
	wire[3:0]c;
	not(c[0],b[0]);  not(c[1],b[1]);
	not(c[2],b[2]);  not(c[3],b[3]);
	full_adder f1(sum[0],carry[0],a[0],c[0],1);
	full_adder f2(sum[1],carry[1],a[1],c[1],carry[0]);
	full_adder f3(sum[2],carry[2],a[2],c[2],carry[1]);
	full_adder f4(sum[3],carry[3],a[3],c[3],carry[2]);
	buf(sum[4],carry[3]);
endmodule


module adder_one(output [4:0]sum, input[3:0] a);
	wire [3:0] carry;
	full_adder f1(sum[0],carry[0],a[0],0,1);
	full_adder f2(sum[1],carry[1],a[1],0,carry[0]);
	full_adder f3(sum[2],carry[2],a[2],0,carry[1]);
	full_adder f4(sum[3],carry[3],a[3],0,carry[2]);
	buf(sum[4],carry[3]);
endmodule

module subtract_one(output [4:0]sum, input[3:0] a);
	wire [3:0] carry;
	full_adder f1(sum[0],carry[0],a[0],1,0);
	full_adder f2(sum[1],carry[1],a[1],1,carry[0]);
	full_adder f3(sum[2],carry[2],a[2],1,carry[1]);
	full_adder f4(sum[3],carry[3],a[3],1,carry[2]);
	buf(sum[4],carry[3]);
endmodule
	
module bitwise_and(output [4:0] out, input[3:0] a, input[3:0] b);
	and (out[0],a[0],b[0]);
	and (out[1],a[1],b[1]);
	and (out[2],a[2],b[2]);
	and (out[3],a[3],b[3]);
	buf(out[4],0);
endmodule

module bitwise_or(output [4:0] out, input[3:0] a, input[3:0] b);
	or (out[0],a[0],b[0]);
	or (out[1],a[1],b[1]);
	or (out[2],a[2],b[2]);
	or (out[3],a[3],b[3]);
	buf(out[4],0);
endmodule

module bitwise_xor(output [4:0] out, input[3:0] a, input[3:0] b);
	xor (out[0],a[0],b[0]);
	xor (out[1],a[1],b[1]);
	xor (out[2],a[2],b[2]);
	xor (out[3],a[3],b[3]);
	buf(out[4],0);
endmodule


module shift_right(output [4:0]h, input[3:0]a);
	buf(h[0],a[1]);
	buf(h[1],a[2]);
	buf(h[2],a[3]);
	buf(h[3],0);
	buf(h[4],0);
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


module alu_logic(output [4:0]out, input[3:0] a, input[3:0] b, input s0,input s1);
    wire [4:0] x,y,z,v;
	bitwise_and an(x,a,b);
	bitwise_or o(y,a,b);
	bitwise_xor  bitwise(z,a,b);
	shift_right right(v,a);
	
	mux41 m1(out[0],x[0] , y[0], z[0], v[0], s0, s1);
	mux41 m2(out[1],x[1] , y[1], z[1], v[1], s0, s1);
	mux41 m3(out[2],x[2] , y[2], z[2], v[2], s0, s1);
	mux41 m4(out[3],x[3] , y[3], z[3], v[3], s0, s1);
	mux41 m5(out[4],x[4] , y[4], z[4], v[4], s0, s1);
	
endmodule


module alu_arth(output [4:0]out, input[3:0] a, input[3:0] b, input s0,input s1);
    wire [4:0] x,y,z,v;
	adder an(x,a,b);
	subtract o(y,a,b);
	adder_one  bitwise(z,a);
	subtract_one right(v,a);
	
	mux41 m1(out[0],x[0] , y[0], z[0], v[0], s0, s1);
	mux41 m2(out[1],x[1] , y[1], z[1], v[1], s0, s1);
	mux41 m3(out[2],x[2] , y[2], z[2], v[2], s0, s1);
	mux41 m4(out[3],x[3] , y[3], z[3], v[3], s0, s1);
	mux41 m5(out[4],x[4] , y[4], z[4], v[4], s0, s1);
endmodule


module alu(output [4:0]out, input[3:0] a, input[3:0] b, input s0,input s1,input s3);
    wire [4:0] x,y;
	alu_logic logic1(x,a,b,s0,s1);
	alu_arth arth(y,a,b,s0,s1);
	
	mux21 m1(out[0], y[0],x[0],s3);
	mux21 m2(out[1], y[1],x[1],s3);
	mux21 m3(out[2], y[2],x[2],s3);
	mux21 m4(out[3], y[3],x[3],s3);
	mux21 m5(out[4], y[4],x[4],s3);
endmodule


module test();
wire[4:0]A;
wire[3:0]b,c;
buf(b[0],1); buf(c[0],1);//1
buf(b[1],1); buf(c[1],1);//0
buf(b[2],0); buf(c[2],1);//0
buf(b[3],1); buf(c[3],1);//0


alu you(A,b,c,1,1,1);

initial
   begin
      $monitor("carray / A[4] = %b, A[3]=%b, A[2]=%b, A[1]=%b, A[0]=%b ", A[4], A[3], A[2], A[1], A[0]);
   end
endmodule
