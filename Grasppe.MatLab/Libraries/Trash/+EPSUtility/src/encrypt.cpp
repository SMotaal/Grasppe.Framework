/*
%ENCRYPT   Decrypt EEXEC encrypted text
%   ENCRYPT(DATA,KEY) takes uint8 TEXT array and uint16 KEY and returns the encrypted 
%   uint8 array

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-15-2012) original release
*/

#include <mex.h>

// TEXT = ENCRYPT(DATA,KEY)
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) 
{
   const unsigned short c1 = 52845, c2 = 22719;

   size_t N, n; // number of byte
   unsigned short key; // uint16 key
   unsigned char *text; // uint8 unencrypted array
   unsigned char *data; // uint8 encrypted array
   unsigned char cipher;
  
   N = mxGetNumberOfElements(prhs[0]);
   text = (unsigned char*)mxGetData(prhs[0]);
   key = *(unsigned short*)mxGetData(prhs[1]);
   
   plhs[0] = mxCreateNumericMatrix(1,N,mxUINT8_CLASS,mxREAL);
   data = (unsigned char*)mxGetData(plhs[0]);
   
   for (n = 0; n < N; n++) // for each byte
   {
      cipher = (unsigned char)(text[n] ^ (key>>8)) ;
      key = (((unsigned short)cipher + key) * c1 + c2);
      data[n] = cipher;
   }
}
