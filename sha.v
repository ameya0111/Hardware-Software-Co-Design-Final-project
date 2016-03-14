/*
 The MIT License (MIT)

 Copyright (c) 2014 Ameya Shashikant Khandekar

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


module sha(
clk, 
reset, 

clk_en,
start, 
done,

dataa,
datab, 
result 
);

//INPUTS
input clk;
input reset;
input clk_en;
input start;
input [31:0] dataa;
input [31:0] datab;
//OUTPUTS
output done;
output [31:0] result;

//states 
reg [3:0] state;  //might need to add states if need be
parameter init0 = 4'd0, get1 = 4'd1, shbegin = 4'd2, shsend = 4'd3, shwait = 4'd4, shgot = 4'd5, shcmp = 4'd6, shfin = 4'd7, found = 4'd8;

//wires and registers
reg [31:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15;  // receive 64 byte data from nios2.
//w0 stores currentcount

reg done;
reg [31:0] result;
reg [31:0] target,target1; //save target

//these will be used to find which core hit collision. cmpr is reference, cmp0 is for sha0.
reg [31:0] cmpr,cmp0,cmp1 ;

//common core connections input
reg [2:0] cmdi; //cmdi and cmdwi will be same for all cores.
reg cmdwi ; 
reg [31:0] regtextin; // regin is common input to sha cores
reg addenable;    // addenable will enable if cores get common input or aptly incremented input
 

//sha0 input connections
wire [31:0] wtextin0;  

//sha0 outputs
wire [255:0] textout0 ;
wire [3:0] cmdout0; 
reg [255:0] rtextout0;


//sha1 input connections
wire [31:0] wtextin1;  

//sha1 output
wire [255:0] textout1 ;
wire [3:0] cmdout1; 
reg [255:0] rtextout1;

reg colfound;
reg [31:0] collision;





reg [3:0] shcnt; // keeps count of data sent to sha
reg [1:0] coreflag; //maintains flag related to cores

//core instantiations
sha256 hash0 ( .clk_i (clk), 
             .rst_i (reset), 
              .text_i (wtextin0),
              .text_o (textout0),
              .cmd_i (cmdi), 
              .cmd_w_i (cmdwi),
              .cmd_o (cmdout0));
			  
sha256 hash1 ( .clk_i (clk), 
             .rst_i (reset), 
              .text_i (wtextin1),
              .text_o (textout1),
              .cmd_i (cmdi), 
              .cmd_w_i (cmdwi),
              .cmd_o (cmdout1));
			  
//assign inputs to the cores			 
assign wtextin0 = regtextin ;
assign wtextin1 = (addenable == 1) ? (regtextin + 1) : regtextin ;

// custom instruction logic 
always @(posedge clk or posedge reset)
  if (reset) begin
    state <= init0; 
    target1 <= 32'd0; //q <= 1'b0;
    cmpr <= 32'hFFFFFFFF;
  end
  else begin
    case (state)
      init0: begin
            done <= 1'b0;  
            shcnt <= 4'd0;
            coreflag <= 2'b00;  
            colfound <= 0;           
            if (start == 1'b1 && clk_en == 1) begin    //initial state of coprocessor
               state <= get1;  
            end else begin
               state <= init0;   
            end
          end
      get1: begin     // in test stage also sending data via same..
          case (dataa)
            32'd0: begin
                  w0 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd1: begin
                  w1 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd2: begin
                  w2 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd3: begin
                  w3 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd4: begin
                  w4 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd5: begin
                   w5 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd6: begin
                  w6 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd7: begin
                  w7 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd8: begin
                  w8 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd9: begin
                  w9 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd10: begin
                  w10 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd11: begin
                  w11 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd12: begin 
                  w12 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd13: begin
                  w13 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd14: begin
                  w14 <= datab;
                  done <= 1'b1;
                  state <= init0; 
                end
            32'd15: begin
                   w15 <= datab;
                   done <= 1'b1;
                   state <= init0; 
                 end
            32'd16: begin
                   target <= datab;
                   state <= shbegin;
                   done <= 1'b1;   // not doing done = 1 as beginning computation for SHA
                 end
            
          endcase
        end
      //sha computation states :-    
      shbegin: begin
              if(start == 1'b1 && clk_en == 1) begin
               case (dataa)
                 32'd100 : result <= colfound;
                 32'd101 : result <= w0;
               endcase
			         done <= 1'b1;
              end
             if(done == 1) begin
                 done <= 1'b0;
               end
               cmdi <= 3'b010;
               cmdwi <= 1'b1;
					     coreflag <= 2'b00;  
               state <= shsend;
             end
      shsend : begin    //start sending data.
              if(start == 1'b1 && clk_en == 1) begin
              case (dataa)
                 32'd100 : result <= colfound;
                 32'd101 : result <= w0;
               endcase
			         done <= 1'b1;
              end
            if(done == 1) begin
                 done <= 1'b0;
               end
      
      
              cmdwi <= 1'b0;
              shcnt <= shcnt + 1; // counter keeps track of data being sent to sha computer
              case (shcnt)
            4'd0: begin
                  regtextin <= w0;   //currentcount send via w0
				  addenable <= 1;
                  state <= shsend;
                end
            4'd1: begin
                  regtextin <= w1;
				  addenable <= 0;
                  state <= shsend;
                end
            4'd2: begin
                  regtextin <= w2;
				  addenable <= 0; 
                  state <= shsend; 
                end
            4'd3: begin
                  regtextin <= w3;
				  addenable <= 0; 
                  state <= shsend; 
                end
            4'd4: begin
                  regtextin <= w4;
				  addenable <= 0;
                  state <= shsend; 
                end
            4'd5: begin
                  regtextin <= w5;
				  addenable <= 0;
                  state <= shsend; 
                end
            4'd6: begin
                  regtextin <= w6;
				  addenable <= 0;
                  state <= shsend; 
                end
            4'd7: begin
                  regtextin <= w7;
				  addenable <= 0;
                  state <= shsend;
                end
            4'd8: begin
                  regtextin <= w8;
				  addenable <= 0;
                  state <= shsend;
                end
            4'd9: begin
                  regtextin <= w9;
				  addenable <= 0; 
                  state <= shsend;
                end
            4'd10: begin
                  regtextin <= w10;
				  addenable <= 0;
                  state <= shsend;
                end
            4'd11: begin
                  regtextin <= w11;
				  addenable <= 0;
                  state <= shsend;
                end
            4'd12: begin 
                  regtextin <= w12;
				  addenable <= 0; 
                  state <= shsend;
                end
            4'd13: begin
                  regtextin <= w13;
				  addenable <= 0;
                  state <= shsend;
                end
            4'd14: begin
                  regtextin <= w14;
				  addenable <= 0; 
                  state <= shsend;
                end
            4'd15: begin
                   regtextin <= w15;
				   addenable <= 0; 
                   state <= shwait;  
                 end
          endcase
        end
        shwait : begin
           if(start == 1'b1 && clk_en == 1) begin
              case (dataa)
                 32'd100 : result <= colfound;
                 32'd101 : result <= w0;
               endcase
			         done <= 1'b1;
              end
               if(done == 1) begin
                 done <= 1'b0;
               end
          
          
          
               if (cmdout0[3] == 1'b0) begin    //initial state of coprocessor
               
               rtextout0 <= textout0;
			   coreflag[0] = 1;
            end 
			 if (cmdout1[3] == 1'b0) begin    //initial state of coprocessor
                
               rtextout1 <= textout1;
			   coreflag[1] = 1;
            end 
			   
			if(coreflag == 2'b11 ) begin
				state <= shgot;
			end
			else begin
               state <= shwait;   
            end
       end
       // shgot : begin //start sending data.  
          
        shgot : begin 
               if(start == 1'b1 && clk_en == 1) begin
              case (dataa)
                 32'd100 : result <= colfound;
                 32'd101 : result <= w0;
               endcase
			         done <= 1'b1;
              end
            if(done == 1) begin
                 done <= 1'b0;
               end
          
          
              if(target != target1) begin
                target1 <= target;
                cmpr <= cmpr >> 1; 
              end
              state <= shcmp;
            end
       shcmp: begin
          if(start == 1'b1 && clk_en == 1) begin
              case (dataa)
                 32'd100 : result <= colfound;
                 32'd101 : result <= w0;
               endcase
			         done <= 1'b1;
              end
           if(done == 1) begin
                 done <= 1'b0;
               end
         
         
         cmp0 <= cmpr | rtextout0[255:224];
		     cmp1 <= cmpr | rtextout1[255:224];
         state <=shfin;
       end
       shfin: begin
          if(start == 1'b1 && clk_en == 1) begin
              case (dataa)
                 32'd100 : result <= colfound;
                 32'd101 : result <= w0;
               endcase
			         done <= 1'b1;
              end
          if(done == 1) begin
                 done <= 1'b0;
               end
         
          if(cmp0 == cmpr) begin
           collision <= w0;
			  state <= found; 
			  colfound <= 1;
           //done <= 1'b1;
        end else if(cmp1 == cmpr) begin
           collision <= w0 + 1;
			  state <= found;
			  colfound <= 1;
          // done <= 1'b1;
        end
		else begin
		   w0 <= w0 + 2;
		   state <= shbegin;
      end
		 
		end
		found: begin
		  
		  if(start == 1'b1 && clk_en == 1) begin
              case (dataa)
                  32'd100 : begin 
                  result <= colfound;
                  state <= found;
                  end
                  32'd101 : begin
                  result <= w0;
                  state <= found;
                  end
                  32'd102 : begin
                  result <= collision;
                  state <= init0;
                  end
               endcase
			         done <= 1'b1;
      end
     
      else begin
              state <= found;
      end
		
		if(done == 1) begin
                 done <= 1'b0;
               end
              
		 
		  end
		
		
    endcase
    end
endmodule
