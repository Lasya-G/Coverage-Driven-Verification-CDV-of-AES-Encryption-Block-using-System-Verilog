# Coverage-Driven-Verification-CDV-of-AES-Encryption-Block-using-System-Verilog

AES (Advanced Encryption Standard) employs a substitution-permutation network, which consists of a series of linked mathematical operations to transform plaintext into ciphertext and vice versa.

<img width="400" height="600" alt="image" src="https://github.com/user-attachments/assets/93f532a7-44f6-49d7-81af-5a07d6865317" />

## Methodology of AES: 
### Key Expansion: 
- The AES Encryption process starts with Key Expansion where all the required round keys are generated depending on the input length (128 bits here) referred to as cipher key. So, in our case 10 round keys(one key for each round) are generated for a key length of 128 based on the formula - *No. of rounds = (Key length/32) + 6*.
### Initial Round:
#### AddRoundKey:
- AddRoundKey involves combining the current state of the data with a round key using the bitwise XOR operation. The round keys are derived from the initial cipher key through a process known as key expansion. The purpose of AddRoundKey is to mix the data with the key material in a way that is computationally infeasible to reverse without knowledge of the key.  
### Main Rounds:
#### Substitution Bytes: 
- **S-box**: It is the substitution table. Each byte is substituted by another byte.
- **Sub-Bytes**: Inthis, depending on number of bytes in data, every byte of data is replaced with a corresponding byte from the fixed substitution (S-box) table.    
#### ShiftRows: 
- The bytes in each row of the state are cyclically shifted to the left. If the input of shift rows is considered as a state matrix with each element being the byte of the input, then the output will be the state matrix as shown in the image below:
  
<img width="230" height="183" alt="image" src="https://github.com/user-attachments/assets/77291882-d406-4645-b22a-b27124b50073" /> <img width="585" height="183" alt="image" src="https://github.com/user-attachments/assets/9d7a46e3-31dd-4cfe-8067-fc22afa25dd4" />

#### MixColumns:
- Each column of the state is transformed using a linear transformation to provide diffusion.
- Each 4-byte column is considered as a vector and multiplied by a fixed 4×4 matrix. The matrix contains constant entries. For example, we show how the first four output bytes are computed:
  <img width="368" height="136" alt="image" src="https://github.com/user-attachments/assets/d9a3e321-d16c-4c45-8e68-f29e9d338dd1" />

#### AddRoundKey:
- AddRoundKey involves combining the current state of the data with a round key using the bitwise XOR operation.

### Final Round:
- Similar to the main rounds but without the MixColumns step.
### RoundKeyGen:
- First, the input key is stored in a first-stage register and the valid_in signal is passed through to the next stage. Then, the key is stored in a second-stage register, and the valid_in signal is passed through to the next stage. The least significant word of the key is rotated, and the result is stored in a register. The SubBytes operation is performed on the result of the rotation operation in parallel with the second-stage register. The round key is calculated using the second-stage key, the result of the SubBytes operation, and the round constant word and so on. Finally, the delayed round key is stored in the output register, and the valid_out signal is passed through to the output.

## Verification Plan:

- Tools used: QuestaSim
- Verification Language: System Verilog
- Methodology: Layered TestBench
