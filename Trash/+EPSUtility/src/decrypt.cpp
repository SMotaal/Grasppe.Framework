/*
%DECRYPT   Decrypt EEXEC encrypted text
%   DECRYPT(DATA,KEY) takes uint8 DATA array with encryption KEY and returns the decrypted
%   text

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-04-2012) original release
% rev. 1 : (03-15-2012) header update
*/

#include <mex.h>

// TEXT = DECRYPT(DATA,KEY)
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) 
{
   const unsigned short c1 = 52845, c2 = 22719;

   size_t N, n; // number of byte
   unsigned char *data; // uint8 input array
   unsigned short R_DEFAULT; // uint8 input array
   char *plain; // char output array
     
   unsigned short int R;
   
   data = (unsigned char*)mxGetData(prhs[0]);
   N = mxGetNumberOfElements(prhs[0]);
   
   R_DEFAULT = *(unsigned short*)mxGetData(prhs[1]);
   
   plhs[0] = mxCreateNumericMatrix(1,N,mxUINT8_CLASS,mxREAL);
   plain = (char*)mxGetData(plhs[0]);
   
   int state = 0; // decoder state
   unsigned char cipher;

   // eexec initialization
   R = R_DEFAULT;
   
   // ignore the first 4 bytes
   for (n = 0; n < N; n++)
   {
      cipher = data[n];
      plain[n] = (char)(cipher ^ (R>>8));
      R = (((unsigned short)cipher + R) * c1 + c2);
   }
}
