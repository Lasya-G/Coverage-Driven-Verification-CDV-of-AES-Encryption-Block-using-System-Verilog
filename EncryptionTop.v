
/*
Project        : AES
Standard doc.  : FIPS 197
Module name    : Top_AES_PipelinedCipher 
Dependancy     :
Design doc.    : 
References     : 
Description    : this is the top module of the design which forms
                 rounds and connects KeyExpantion using pipelined
				 architecture
Owner          : SouShu
*/


`timescale 1 ns/1 ps

module S_BOX               
(
input clk,               //system clock
input reset,             //asynch active low reset
input valid_in,          //valid input signal
input [7:0] addr,        //SBox input byte
output reg [7:0] dout    //SBox output
);

always @ ( posedge clk or negedge reset) 
  if (!reset) begin
    dout <= 8'h00;
  end  else begin
      
    if(valid_in) begin
     case (addr)          //substitution table
       8'h00              : dout <= 8'h63;
       8'h01              : dout <= 8'h7c;
       8'h02              : dout <= 8'h77;
       8'h03              : dout <= 8'h7b;
       8'h04              : dout <= 8'hf2;
       8'h05              : dout <= 8'h6b;
       8'h06              : dout <= 8'h6f;
       8'h07              : dout <= 8'hc5;
       8'h08              : dout <= 8'h30;
       8'h09              : dout <= 8'h01;
       8'h0a              : dout <= 8'h67;
       8'h0b              : dout <= 8'h2b;
       8'h0c              : dout <= 8'hfe;
       8'h0d              : dout <= 8'hd7;
       8'h0e              : dout <= 8'hab;
       8'h0f              : dout <= 8'h76;
    /****************************************/
       8'h10              : dout <= 8'hca;
       8'h11              : dout <= 8'h82;
       8'h12              : dout <= 8'hc9;
       8'h13              : dout <= 8'h7d;
       8'h14              : dout <= 8'hfa;
       8'h15              : dout <= 8'h59;
       8'h16              : dout <= 8'h47;
       8'h17              : dout <= 8'hf0;
       8'h18              : dout <= 8'had;
       8'h19              : dout <= 8'hd4;
       8'h1a              : dout <= 8'ha2;
       8'h1b              : dout <= 8'haf;
       8'h1c              : dout <= 8'h9c;
       8'h1d              : dout <= 8'ha4;
       8'h1e              : dout <= 8'h72;
       8'h1f              : dout <= 8'hc0;
    /**********************************************/
       8'h20              : dout <= 8'hb7;
       8'h21              : dout <= 8'hfd;
       8'h22              : dout <= 8'h93;
       8'h23              : dout <= 8'h26;
       8'h24              : dout <= 8'h36;
       8'h25              : dout <= 8'h3f;
       8'h26              : dout <= 8'hf7;
       8'h27              : dout <= 8'hcc;
       8'h28              : dout <= 8'h34;
       8'h29              : dout <= 8'ha5;
       8'h2a              : dout <= 8'he5;
       8'h2b              : dout <= 8'hf1;
       8'h2c              : dout <= 8'h71;
       8'h2d              : dout <= 8'hd8;
       8'h2e              : dout <= 8'h31;
       8'h2f              : dout <= 8'h15;
    /*****************************************/
       8'h30              : dout <= 8'h04;
       8'h31              : dout <= 8'hc7;
       8'h32              : dout <= 8'h23;
       8'h33              : dout <= 8'hc3;
       8'h34              : dout <= 8'h18;
       8'h35              : dout <= 8'h96;
       8'h36              : dout <= 8'h05;
       8'h37              : dout <= 8'h9a;
       8'h38              : dout <= 8'h07;
       8'h39              : dout <= 8'h12;
       8'h3a              : dout <= 8'h80;
       8'h3b              : dout <= 8'he2;
       8'h3c              : dout <= 8'heb;
       8'h3d              : dout <= 8'h27;
       8'h3e              : dout <= 8'hb2;
       8'h3f              : dout <= 8'h75;
    /*******************************************/
       8'h40              : dout <= 8'h09;
       8'h41              : dout <= 8'h83;
       8'h42              : dout <= 8'h2c;
       8'h43              : dout <= 8'h1a;
       8'h44              : dout <= 8'h1b;
       8'h45              : dout <= 8'h6e;
       8'h46              : dout <= 8'h5a;
       8'h47              : dout <= 8'ha0;
       8'h48              : dout <= 8'h52;
       8'h49              : dout <= 8'h3b;
       8'h4a              : dout <= 8'hd6;
       8'h4b              : dout <= 8'hb3;
       8'h4c              : dout <= 8'h29;
       8'h4d              : dout <= 8'he3;
       8'h4e              : dout <= 8'h2f;
       8'h4f              : dout <= 8'h84;
    /**********************************************/
       8'h50              : dout <= 8'h53;
       8'h51              : dout <= 8'hd1;
       8'h52              : dout <= 8'h00;
       8'h53              : dout <= 8'hed;
       8'h54              : dout <= 8'h20;
       8'h55              : dout <= 8'hfc;
       8'h56              : dout <= 8'hb1;
       8'h57              : dout <= 8'h5b;
       8'h58              : dout <= 8'h6a;
       8'h59              : dout <= 8'hcb;
       8'h5a              : dout <= 8'hbe;
       8'h5b              : dout <= 8'h39;
       8'h5c              : dout <= 8'h4a;
       8'h5d              : dout <= 8'h4c;
       8'h5e              : dout <= 8'h58;
       8'h5f              : dout <= 8'hcf;
       /****************************************/
       8'h60              : dout <= 8'hd0;
       8'h61              : dout <= 8'hef;
       8'h62              : dout <= 8'haa;
       8'h63              : dout <= 8'hfb;
       8'h64              : dout <= 8'h43;
       8'h65              : dout <= 8'h4d;
       8'h66              : dout <= 8'h33;
       8'h67              : dout <= 8'h85;
       8'h68              : dout <= 8'h45;
       8'h69              : dout <= 8'hf9;
       8'h6a              : dout <= 8'h02;
       8'h6b              : dout <= 8'h7f;
       8'h6c              : dout <= 8'h50;
       8'h6d              : dout <= 8'h3c;
       8'h6e              : dout <= 8'h9f;
       8'h6f              : dout <= 8'ha8;
    /*********************************************/
       8'h70              : dout <= 8'h51;
       8'h71              : dout <= 8'ha3;
       8'h72              : dout <= 8'h40;
       8'h73              : dout <= 8'h8f;
       8'h74              : dout <= 8'h92;
       8'h75              : dout <= 8'h9d;
       8'h76              : dout <= 8'h38;
       8'h77              : dout <= 8'hf5;
       8'h78              : dout <= 8'hbc;
       8'h79              : dout <= 8'hb6;
       8'h7a              : dout <= 8'hda;
       8'h7b              : dout <= 8'h21;
       8'h7c              : dout <= 8'h10;
       8'h7d              : dout <= 8'hff;
       8'h7e              : dout <= 8'hf3;
       8'h7f              : dout <= 8'hd2;
    /********************************************/
       8'h80              : dout <= 8'hcd;
       8'h81              : dout <= 8'h0c;
       8'h82              : dout <= 8'h13;
       8'h83              : dout <= 8'hec;
       8'h84              : dout <= 8'h5f;
       8'h85              : dout <= 8'h97;
       8'h86              : dout <= 8'h44;
       8'h87              : dout <= 8'h17;
       8'h88              : dout <= 8'hc4;
       8'h89              : dout <= 8'ha7;
       8'h8a              : dout <= 8'h7e;
       8'h8b              : dout <= 8'h3d;
       8'h8c              : dout <= 8'h64;
       8'h8d              : dout <= 8'h5d;
       8'h8e              : dout <= 8'h19;
       8'h8f              : dout <= 8'h73;
 /***********************************************/
       8'h90              : dout <= 8'h60;
       8'h91              : dout <= 8'h81;
       8'h92              : dout <= 8'h4f;
       8'h93              : dout <= 8'hdc;
       8'h94              : dout <= 8'h22;
       8'h95              : dout <= 8'h2a;
       8'h96              : dout <= 8'h90;
       8'h97              : dout <= 8'h88;
       8'h98              : dout <= 8'h46;
       8'h99              : dout <= 8'hee;
       8'h9a              : dout <= 8'hb8;
       8'h9b              : dout <= 8'h14;
       8'h9c              : dout <= 8'hde;
       8'h9d              : dout <= 8'h5e;
       8'h9e              : dout <= 8'h0b;
       8'h9f              : dout <= 8'hdb;
      /******************************************/
       8'ha0              : dout <= 8'he0;
       8'ha1              : dout <= 8'h32;
       8'ha2              : dout <= 8'h3a;
       8'ha3              : dout <= 8'h0a;
       8'ha4              : dout <= 8'h49;
       8'ha5              : dout <= 8'h06;
       8'ha6              : dout <= 8'h24;
       8'ha7              : dout <= 8'h5c;
       8'ha8              : dout <= 8'hc2;
       8'ha9              : dout <= 8'hd3;
       8'haa              : dout <= 8'hac;
       8'hab              : dout <= 8'h62;
       8'hac              : dout <= 8'h91;
       8'had              : dout <= 8'h95;
       8'hae              : dout <= 8'he4;
       8'haf              : dout <= 8'h79;
    /******************************************/
       8'hb0              : dout <= 8'he7;
       8'hb1              : dout <= 8'hc8;
       8'hb2              : dout <= 8'h37;
       8'hb3              : dout <= 8'h6d;
       8'hb4              : dout <= 8'h8d;
       8'hb5              : dout <= 8'hd5;
       8'hb6              : dout <= 8'h4e;
       8'hb7              : dout <= 8'ha9;
       8'hb8              : dout <= 8'h6c;
       8'hb9              : dout <= 8'h56;
       8'hba              : dout <= 8'hf4;
       8'hbb              : dout <= 8'hea;
       8'hbc              : dout <= 8'h65;
       8'hbd              : dout <= 8'h7a;
       8'hbe              : dout <= 8'hae;
       8'hbf              : dout <= 8'h08;
    /****************************************/
       8'hc0              : dout <= 8'hba;
       8'hc1              : dout <= 8'h78;
       8'hc2              : dout <= 8'h25;
       8'hc3              : dout <= 8'h2e;
       8'hc4              : dout <= 8'h1c;
       8'hc5              : dout <= 8'ha6;
       8'hc6              : dout <= 8'hb4;
       8'hc7              : dout <= 8'hc6;
       8'hc8              : dout <= 8'he8;
       8'hc9              : dout <= 8'hdd;
       8'hca              : dout <= 8'h74;
       8'hcb              : dout <= 8'h1f;
       8'hcc              : dout <= 8'h4b;
       8'hcd              : dout <= 8'hbd;
       8'hce              : dout <= 8'h8b;
       8'hcf              : dout <= 8'h8a;
    /****************************************/
       8'hd0              : dout <= 8'h70;
       8'hd1              : dout <= 8'h3e;
       8'hd2              : dout <= 8'hb5;
       8'hd3              : dout <= 8'h66;
       8'hd4              : dout <= 8'h48;
       8'hd5              : dout <= 8'h03;
       8'hd6              : dout <= 8'hf6;
       8'hd7              : dout <= 8'h0e;
       8'hd8              : dout <= 8'h61;
       8'hd9              : dout <= 8'h35;
       8'hda              : dout <= 8'h57;
       8'hdb              : dout <= 8'hb9;
       8'hdc              : dout <= 8'h86;
       8'hdd              : dout <= 8'hc1;
       8'hde              : dout <= 8'h1d;
       8'hdf              : dout <= 8'h9e;
    /*******************************************/
       8'he0              : dout <= 8'he1;
       8'he1              : dout <= 8'hf8;
       8'he2              : dout <= 8'h98;
       8'he3              : dout <= 8'h11;
       8'he4              : dout <= 8'h69;
       8'he5              : dout <= 8'hd9;
       8'he6              : dout <= 8'h8e;
       8'he7              : dout <= 8'h94;
       8'he8              : dout <= 8'h9b;
       8'he9              : dout <= 8'h1e;
       8'hea              : dout <= 8'h87;
       8'heb              : dout <= 8'he9;
       8'hec              : dout <= 8'hce;
       8'hed              : dout <= 8'h55;
       8'hee              : dout <= 8'h28;
       8'hef              : dout <= 8'hdf;
    /****************************************/
       8'hf0              : dout <= 8'h8c;
       8'hf1              : dout <= 8'ha1;
       8'hf2              : dout <= 8'h89;
       8'hf3              : dout <= 8'h0d;
       8'hf4              : dout <= 8'hbf;
       8'hf5              : dout <= 8'he6;
       8'hf6              : dout <= 8'h42;
       8'hf7              : dout <= 8'h68;
       8'hf8              : dout <= 8'h41;
       8'hf9              : dout <= 8'h99;
       8'hfa              : dout <= 8'h2d;
       8'hfb              : dout <= 8'h0f;
       8'hfc              : dout <= 8'hb0;
       8'hfd              : dout <= 8'h54;
       8'hfe              : dout <= 8'hbb;
       8'hff              : dout <= 8'h16;
       default            : dout <= 8'h00;
       
    endcase
  end
end

endmodule 



module SubBytes
#
(
 parameter DATA_W = 128,       //data width
 parameter NO_BYTES = DATA_W >> 3  //no of bytes = data width / 8
)
(
input clk,                     //system clock
input reset,                   //asynch active low reset
input valid_in,                //input valid signal  
input [DATA_W-1:0] data_in,    //input data
output reg valid_out,          //output valid signal
output [DATA_W-1:0] data_out   //output data
)
;

genvar i;
generate                      //generating sbox roms 
for (i=0; i< NO_BYTES ; i=i+1) begin : ROM
  S_BOX ROM(clk,reset,valid_in,data_in[(i*8)+7:(i*8)],data_out[(i*8)+7:(i*8)]);   
end
endgenerate

always@(posedge clk or negedge reset)   //valid out register
if(!reset)begin
    valid_out <= 1'b0;
end else begin 
    valid_out <= valid_in;
  end
endmodule



module ShiftRows
#
(
parameter DATA_W = 128       //data width
)
(
input clk,                  //system clock
input reset,                //asynch active low reset
input valid_in,             //input valid signal   
input [DATA_W-1:0] data_in,  //input data
output reg valid_out,         //output valid signal
output reg [DATA_W-1:0] data_out //output data
)
;

wire [7:0] State [0:15];   //array of wires to form state array     

genvar i ;                                
generate 
// filling state array as each row represents one byte ex: state[0] means first byte and so on
for(i=0;i<=15;i=i+1) begin :STATE 
 assign State[i]= data_in[(((15-i)*8)+7):((15-i)*8)];  
end   
endgenerate  
                   
always @(posedge clk or negedge reset)

if(!reset)begin
    valid_out <= 1'b0;
    data_out <= 'b0;
end else begin  

 if(valid_in)begin   //shifting state rows as delared in fips197 standard document
    data_out[(15*8)+7:(12*8)] <= {State[0],State[5],State[10],State[15]}; 
    data_out[(11*8)+7:(8*8)] <= {State[4],State[9],State[14],State[3]};                            
    data_out[(7*8)+7:(4*8)]  <= {State[8],State[13],State[2],State[7]};                         
    data_out[(3*8)+7:(0*8)]  <=  {State[12],State[1],State[6],State[11]}; 
 end 
    valid_out <= valid_in;                               
end
    
endmodule
    

module MixColumns
#
(
parameter DATA_W = 128             //data width
)
(
input clk,                         //system clock
input reset,                       //asynch active low reset
input valid_in,                    //input valid signal   
input [DATA_W-1:0] data_in,        //input data
output reg valid_out,              //output valid signal
output reg [DATA_W-1:0] data_out   //output data
)
;

wire [7:0] State [0:15];        //array of wires to form state array
wire [7:0] State_Mulx2 [0:15];  //array of wires to perform multiplication by 02
wire [7:0] State_Mulx3 [0:15];  //array of wires to perform multiplication by 03

genvar i ;                                   
generate 
for(i=0;i<=15;i=i+1) begin :MUL
 assign State[i]= data_in[(((15-i)*8)+7):((15-i)*8)];   // filling state array as each row represents one byte ex: state[0] means first byte and so on
 assign State_Mulx2[i]= (State[i][7])?((State[i]<<1) ^ 8'h1b):(State[i]<<1);  //Multiplication by {02} in finite field is done shifting 1 bit lift                                                                               //and xoring with 1b if the most bit =1
 assign State_Mulx3[i]= (State_Mulx2[i])^State[i];  // Multiply by {03} in finite field can be done as multiplication by {02 xor 01}
end   
endgenerate 


always@(posedge clk or negedge reset)
if(!reset)begin
    valid_out <= 1'b0;
    data_out <= 'b0;
end else begin 
   if(valid_in) begin               //mul by 2 and mul by 3 are used to perform matrix multiplication  for each column
    data_out[(15*8)+7:(15*8)]<=  State_Mulx2[0] ^ State_Mulx3[1] ^ State[2] ^ State[3];   //first column
    data_out[(14*8)+7:(14*8)]<= State[0] ^ State_Mulx2[1] ^ State_Mulx3[2] ^ State[3]; 
    data_out[(13*8)+7:(13*8)]<= State[0] ^ State[1] ^ State_Mulx2[2] ^ State_Mulx3[3]; 
    data_out[(12*8)+7:(12*8)]<= State_Mulx3[0] ^ State[1] ^ State[2] ^ State_Mulx2[3];
    /*********************************************************************************/
    data_out[(11*8)+7:(11*8)]<= State_Mulx2[4] ^ State_Mulx3[5] ^ State[6] ^ State[7];   //second column
    data_out[(10*8)+7:(10*8)]<= State[4] ^ State_Mulx2[5] ^ State_Mulx3[6] ^ State[7]; 
    data_out[(9*8)+7:(9*8)] <=  State[4] ^ State[5] ^ State_Mulx2[6] ^ State_Mulx3[7]; 
    data_out[(8*8)+7:(8*8)]<= State_Mulx3[4] ^ State[5] ^ State[6] ^ State_Mulx2[7];
    /**********************************************************************************/
    data_out[(7*8)+7:(7*8)]<= State_Mulx2[8] ^ State_Mulx3[9] ^ State[10] ^ State[11];   //third column
    data_out[(6*8)+7:(6*8)]<= State[8] ^ State_Mulx2[9] ^ State_Mulx3[10] ^ State[11]; 
    data_out[(5*8)+7:(5*8)]<= State[8] ^ State[9] ^ State_Mulx2[10] ^ State_Mulx3[11]; 
    data_out[(4*8)+7:(4*8)]<= State_Mulx3[8] ^ State[9] ^ State[10] ^ State_Mulx2[11];
    /***********************************************************************************/ 
    data_out[(3*8)+7:(3*8)]<= State_Mulx2[12] ^ State_Mulx3[13] ^ State[14] ^ State[15];  //fourth column
    data_out[(2*8)+7:(2*8)]<= State[12] ^ State_Mulx2[13] ^ State_Mulx3[14] ^ State[15]; 
    data_out[(1*8)+7:(1*8)]<= State[12] ^ State[13] ^ State_Mulx2[14] ^ State_Mulx3[15]; 
    data_out[(0*8)+7:(0*8)]<= State_Mulx3[12] ^ State[13] ^ State[14] ^ State_Mulx2[15];
   end
   valid_out <= valid_in;                          
end
endmodule

module RoundKeyGen
#
(
parameter KEY_L = 128,     //key length
parameter WORD = 32        //a parameter to represent WORD  = 4 bytes = 32 bit
)
(
input clk,                           //system clk
input reset,                         //asynch active low reset
input [WORD-1:0] RCON_Word,          //round constant word       
input valid_in,                      //input valid signal
input [KEY_L-1:0] key,               //input key
output reg [KEY_L-1:0]round_key,     //round key
output reg valid_out                 //output valid signal
);

wire [WORD-1:0] Key_RotWord;              
reg [KEY_L-1:0] Key_FirstStage;      
reg [KEY_L-1:0] Key_SecondStage;     
reg [KEY_L-1:0] round_key_delayed;
reg  valid_FirstStage;
reg  valid_round_key;
wire [WORD-1:0] Key_SubBytes;
wire  subbytes_valid_out;
wire [KEY_L-1:0] temp_round_key;

//The keygeneration stages should be balanced with the 4 round stages(SubBytes-ShiftRows-MixColumns-AddRoundKey)
//in order to let the round key and the data meet at the same time in the AddRoundKey module

/******************************************First Stage Register***********************************************************/
always @(posedge clk or negedge reset)
if(!reset)begin
    valid_FirstStage <= 1'b0;
    Key_FirstStage <= 'b0;
end else begin
 if(valid_in)begin
    Key_FirstStage <= key;
 end
    valid_FirstStage <= valid_in;
end
/***********************************************Second Stage Register*******************************************************/
always @(posedge clk or negedge reset)
if(!reset)begin
    Key_SecondStage <= 'b0;
end else begin
 if(valid_FirstStage)begin 
   Key_SecondStage <= Key_FirstStage;
 end
end      
/*******************************************************RotWord****************************************************************/
assign Key_RotWord = {Key_FirstStage[WORD-9:0],Key_FirstStage[WORD-1:WORD-8]}; //rotation of the least word in key

/**************************************************SubBytes (Parallel to second stage register)*******************************/
//perform subbytes operation on the result word of rotword step
SubBytes #(WORD) SUB_U (clk,reset,valid_FirstStage,Key_RotWord,subbytes_valid_out,Key_SubBytes);

/***************************************************Round Key calculations ***********************************************/
assign temp_round_key[4*WORD-1:3*WORD] =  Key_SecondStage[4*WORD-1:3*WORD]  ^ Key_SubBytes ^ RCON_Word;
assign temp_round_key[3*WORD-1:2*WORD] = Key_SecondStage[3*WORD-1:2*WORD] ^ temp_round_key[4*WORD-1:3*WORD] ;
assign temp_round_key[2*WORD-1:WORD] =  Key_SecondStage[2*WORD-1:WORD] ^   temp_round_key[3*WORD-1:2*WORD];
assign temp_round_key[WORD-1:0] = Key_SecondStage[WORD-1:0] ^ temp_round_key[2*WORD-1:WORD];

/***************************************************Roundkey Register (Third Stage)******************************************/
always @(posedge clk or negedge reset)
if(!reset)begin
    round_key_delayed <= 'b0;
    valid_round_key <= 1'b0;
end else begin
 if(subbytes_valid_out)begin
    round_key_delayed <= temp_round_key;
 end
    valid_round_key <= subbytes_valid_out;
end
/****************************************Out Put Register (Fourth Stage)*********************************************/
always @(posedge clk or negedge reset)
if(!reset)begin
   valid_out <= 1'b0;
   round_key <= 'b0;
end else begin
 if(valid_round_key)begin
   round_key <= round_key_delayed;
 end
   valid_out <= valid_round_key;
end

endmodule


module KeyExpantion
#
(
parameter DATA_W = 128,               //data width
parameter KEY_L = 128,                //key length
parameter NO_ROUNDS = 10              //number of rounds
)
(
input clk,                            //system clock
input reset,                          //async reset               
input valid_in,                       //input valid in
input [KEY_L-1:0] cipher_key,         //cipher key
output [(NO_ROUNDS*DATA_W)-1:0] W,    //contains all generated round keys
output [NO_ROUNDS-1:0] valid_out      //output valid signal
);

wire [31:0] RCON [0:9];                       //round constant array of words
wire [NO_ROUNDS-1:0] keygen_valid_out;        //every bit represens output valid signal for every RoundKeyGen module 
wire [DATA_W-1:0] W_array  [0:NO_ROUNDS-1];   //array of round keys to form W output 

//round connstant values
assign RCON[0] = 32'h01000000;
assign RCON[1] = 32'h02000000;
assign RCON[2] = 32'h04000000;
assign RCON[3] = 32'h08000000;
assign RCON[4] = 32'h10000000;
assign RCON[5] = 32'h20000000;
assign RCON[6] = 32'h40000000;
assign RCON[7] = 32'h80000000;
assign RCON[8] = 32'h1b000000;
assign RCON[9] = 32'h36000000;

//instantiate number RounkeyGen modules = number of rounds to get number of roundkeys = number of  rounds
RoundKeyGen #(KEY_L)RKGEN_U0(clk,reset,RCON[0],valid_in,cipher_key,W_array[0],keygen_valid_out[0]);

genvar i;
generate
for (i=1 ;i<NO_ROUNDS;i=i+1) begin : ROUND_KEY_GEN
RoundKeyGen #(KEY_L)RKGEN_U(clk,reset,RCON[i],keygen_valid_out[i-1],W_array[i-1],W_array[i],keygen_valid_out[i]);
end
endgenerate

                         //assigning all the round keys to one output
assign W = {  W_array[0],
              W_array[1],
              W_array[2],
              W_array[3],
              W_array[4],
              W_array[5],
              W_array[6],
              W_array[7],
              W_array[8],
              W_array[9] };
              
assign valid_out = keygen_valid_out; 
              
                        
endmodule

module AddRoundKey
#
(
parameter DATA_W = 128            //data width
)
(
input clk,                        //system clock
input reset,                      //asynch active low reset
input data_valid_in,              //data valid signal
input key_valid_in,               //key valid signal  
input [DATA_W-1:0] data_in,       //input data
input [DATA_W-1:0] round_key,     //input round key
output reg valid_out,             //output valid signal
output reg [DATA_W-1:0] data_out  //output data
)
;

always@(posedge clk or negedge reset)
if(!reset)begin
    data_out <= 'b0;
    valid_out <= 1'b0;
end
else begin
    if(data_valid_in && key_valid_in) begin
    data_out <=  data_in ^ round_key;      //xoring data and round key       
    end   
    valid_out <=  data_valid_in & key_valid_in;
end
endmodule

module Round
#
(
parameter DATA_W = 128            //data width
)
(
input clk,                        //system clock
input reset,                      //asynch active low reset
input data_valid_in,              //data valid signal
input key_valid_in,               //key valid signal
input [DATA_W-1:0] data_in,       //input data
input [DATA_W-1:0] round_key,     //round  key
output  valid_out,                //output valid signal
output  [DATA_W-1:0] data_out     //output data
);
                                 //wires for connection 
wire [DATA_W-1:0] data_sub2shift;  
wire [DATA_W-1:0] data_shift2mix; 
wire [DATA_W-1:0] data_mix2key;

wire valid_sub2shift;
wire valid_shift2mix;
wire valid_mix2key;

///////////////////////////////SubBytes///////////////////////////////////////////////////
SubBytes #(DATA_W) U_SUB (clk,reset,data_valid_in,data_in,valid_sub2shift,data_sub2shift);

//////////////////////////////ShiftRows///////////////////////////////////////////////////////////
ShiftRows #(DATA_W) U_SH (clk,reset,valid_sub2shift,data_sub2shift,valid_shift2mix,data_shift2mix);

//////////////////////////////MixColumns//////////////////////////////////////////////////////////
MixColumns #(DATA_W) U_MIX (clk,reset,valid_shift2mix,data_shift2mix,valid_mix2key,data_mix2key);

/////////////////////////////AddRoundKey/////////////////////////////////////////////////////////////////////
AddRoundKey #(DATA_W) U_KEY (clk,reset,valid_mix2key,key_valid_in,data_mix2key,round_key,valid_out,data_out);

endmodule


module Encryption_Top
#
(
parameter DATA_W = 128,      //data width
parameter KEY_L = 128,       //key length
parameter NO_ROUNDS = 10     //number of rounds
)

(
input clk,                       //system clock
input reset,                     //asynch reset
input data_valid_in,             //data valid signal
input cipherkey_valid_in,        //cipher key valid signal
input [KEY_L-1:0] cipher_key,    //cipher key
input [DATA_W-1:0] plain_text,   //plain text
output valid_out,                //output valid signal
output [DATA_W-1:0] cipher_text, // cipher text
output [DATA_W-1:0] cipher_key_out //cipher key last word  , each word in a key has 32 bits so a key has 4 words

);

wire [NO_ROUNDS-1:0] valid_round_key;            //all round keys valid signals KeyExpantion output
wire [NO_ROUNDS-1:0] valid_round_data;           //all rounds ouput data valid signals
wire [DATA_W-1:0] data_round [0:NO_ROUNDS-1];    //all rounds data
wire valid_sub2shift;                            //for final round connection
wire valid_shift2key;                            //
wire [DATA_W-1:0]data_sub2shift;                 //
wire [DATA_W-1:0]data_shift2key;                 //
wire [(NO_ROUNDS*DATA_W)-1:0] W;                 //all round keys

reg[DATA_W-1:0] data_shift2key_delayed;           //for delay register
reg valid_shift2key_delayed;

//instantiate Key Expantion which will feed every round with round key
KeyExpantion #(DATA_W,KEY_L,NO_ROUNDS) U_KEYEXP(clk,reset,cipherkey_valid_in,cipher_key,W,valid_round_key);

//due to algorithm,first cipher key will be xored witht plain text
AddRoundKey #(DATA_W)U0_ARK(clk,reset,data_valid_in,cipherkey_valid_in,plain_text,cipher_key,valid_round_data[0],data_round[0]);

//instantiate all rounds , connect them with key expantion
genvar i;
generate
for(i=0;i<NO_ROUNDS-1;i=i+1) begin : ROUND
 Round #(DATA_W)U_ROUND(clk,reset,valid_round_data[i],valid_round_key[i],data_round[i],W[(NO_ROUNDS-i)*DATA_W-1:(NO_ROUNDS-i-1)*DATA_W],valid_round_data[i+1],data_round[i+1]);
end
endgenerate

//this is the final round it doesn't contain mixcolumns as declared in fips197 standard document
SubBytes #(DATA_W) U_SUB (clk,reset,valid_round_data[NO_ROUNDS-1],data_round[NO_ROUNDS-1],valid_sub2shift,data_sub2shift);
ShiftRows #(DATA_W) U_SH (clk,reset,valid_sub2shift,data_sub2shift,valid_shift2key,data_shift2key);
AddRoundKey #(DATA_W) U_KEY (clk,reset,valid_shift2key_delayed,valid_round_key[NO_ROUNDS-1],data_shift2key_delayed,W[DATA_W-1:0],valid_out,cipher_text);

/*as the final round has only three stages a delay register should be introduced 
  to be balanced with key  expansion*/
always @(posedge clk or negedge reset)

if(!reset)begin
    valid_shift2key_delayed <= 1'b0;
    data_shift2key_delayed <= 'b0;
end else begin

 if(valid_shift2key)begin
   data_shift2key_delayed <= data_shift2key;
 end
   valid_shift2key_delayed <= valid_shift2key;
end
assign cipher_key_out = W[127:0];
endmodule


