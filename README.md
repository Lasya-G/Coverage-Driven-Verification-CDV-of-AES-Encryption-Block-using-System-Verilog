# Coverage-Driven-Verification-CDV-of-AES-Encryption-Block-using-System-Verilog

AES (Advanced Encryption Standard) employs a substitution-permutation network, which consists of a series of linked mathematical operations to transform plaintext into ciphertext and vice versa.

## Methodology of AES: 
### Key Expansion: 
- The AES Encryption process starts with Key Expansion where all the required round keys are generated depending on the input length (128 bits here) referred to as cipher key. So, in our case 10 round keys(one key for each round) are generated for a key length of 128 based on the formula - *No. of rounds = (Key length/32) + 6*.
### Initial Round:
- ** AddRoundKey:** 
- Each byte of the state is combined with a block of the round key using bitwise XOR. The round keys are derived from the initial cipher key through a process known as key expansion. The purpose of AddRoundKey is to mix the data with the key material in a way that is computationally infeasible to reverse without knowledge of the key.
- Main Rounds:
  - Substitution: Each byte in the state is replaced with a corresponding byte from a fixed substitution (S-box) table.    
  - ShiftRows: The bytes in each row of the state are cyclically shifted to the left.
  - MixColumns: Each column of the state is transformed using a linear transformation to provide diffusion.
  - AddRoundKey: AddRoundKey involves combining the current state of the data with a round key using the bitwise XOR operation.
- Final Round: Similar to the main rounds but without the MixColumns step.
- RoundKeyGen: First, the input key is stored in a first-stage register and the valid_in signal is passed through to the next stage. Then, the key is stored in a second-stage register, and the valid_in signal is passed through to the next stage. The least significant word of the key is rotated, and the result is stored in a register. The SubBytes operation is performed on the result of the rotation operation in parallel with the second-stage register. The round key is calculated using the second-stage key, the result of the SubBytes operation, and the round constant word and so on. Finally, the delayed round key is stored in the output register, and the valid_out signal is passed through to the output.
