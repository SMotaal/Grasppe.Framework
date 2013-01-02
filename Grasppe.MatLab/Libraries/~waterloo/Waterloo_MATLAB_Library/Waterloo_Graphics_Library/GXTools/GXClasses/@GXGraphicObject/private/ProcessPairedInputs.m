function [target, varargout]= ProcessPairedInputs(varargin)


TF=cellfun(@strcmpi, varargin, repmat({'parent'}, size(varargin)));
idx=find(TF);
target=varargin{idx+1};
varargin(idx:idx+1)=[];
varargout{1}=varargin;

end

