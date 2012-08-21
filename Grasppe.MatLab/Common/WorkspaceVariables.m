function [ s ] = WorkspaceVariables(Clear)
  %WORKSPACEVARIABLES structure containing workspace variables
  
  
  vars  = evalin('caller', 'who');
  
  assignin('caller', 'WorkspaceVariableNames', vars);
  s     = evalin('caller', 'varStruct(WorkspaceVariableNames{:})');
  
  
%   mpath = fileparts(mfilename);
%   tempfile = fullfile(mpath,'~workspace.mat');
%   
%   evalin('caller', ['save(''' tempfile ''')']);
%   
    if isVerified('Clear',true)
      evalin('caller', 'clear');
    end
%   
%   VariableStructure = load(tempfile);
%   
%   recycleStat = recycle('off');
%   delete(tempfile);
%   recycle(recycleStat);
  
end

