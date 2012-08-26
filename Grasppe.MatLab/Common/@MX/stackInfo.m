function [ inf ] = stackInfo(N)
  %MFILEINFO stack function file information
  %   Returns the dir output for dbstack frame N where N_caller=1 (default)
  
  if nargin<1, N = 1; end;
  [ST,I] = dbstack('-completenames');
  
  % if numel(ST)>1
  %   error('Grasppe:Stack:TooShallow', 'Cannot get stack information at this depth.');
  % end
  st = ST(N+1);
  
  [pth bs ext] = fileparts(st.file);
  
  inf = dir(st.file);
  
  inf.file      = st.file;
  inf.path      = pth;
  inf.base      = bs;
  inf.ext       = ext;
  inf.function  = st.name;
  inf.line      = st.line;
  
end

