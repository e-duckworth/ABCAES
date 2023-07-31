# ABCAES
MATLAB code to perform and verify ABC AES, an alphabetic letter based simplified AES cipher.

The code here uses MATLAB to verify examples for the article ABCAES: ABC Advanced Encryption Standard, by W. Ethan Duckworth, Scott Clifford, and Bolden Blades.  In particular, every example in the article is calculated with the code here, and also the assertion that the Sbox used in the paper has no fixed-point is verified with calculations here.

The main file is "Article_examples" and is provided in .mlx, .m and .pdf formats.  The .mlx format is ideal for seeing the input and output of the functions in the same file but is MATLAB's custom document format; the .m format is plain text (obtained by having MATLAB export the .mlx file), which can be run in MATLAB and also viewed with any text editor; the .pdf file is the result of MATLAB's export feature, which shows the code input and and outputs of the .mlx file but is not interactive.  The file contains a table of contents, and descriptions of what each calculation shows, and other helpful information.

In addition to the main file there are various helper functions that need to be placed somewher where MATLAB can find them:  
ABCinv.m  
ABCstream_extraMC.m  
ABCstream_r3.m  
ABCstream.m  
addkey.m  
decode.m  
encode.m  
keyexpand_r3.m  
keyexpand.m  
MC.m  
MCinv.m  
pmod.m  
sbox.m  
sboxinv.m  
SR.m  
SRinv.m  
WS.m  
WSinv.m  
Each of these has a brief description in comments at the beginning of the file.  
