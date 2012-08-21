function [mfla] = floatingAlert(msg, flag)

%   persistent fla
if ~exist('flag', 'var')
  flag = 500;
end

if ischar(flag)
  flag = str2num(durtion)
end

% try
%   fla = evalin('base', 'flObj');
% %   fla.flashView();
% end

try
  if (exist('msg', 'var') && ~isempty(msg))
%     try
% %       ecmd = 'flObj.flashView();';
% %       evalin('base', ecmd);
% %       fla.flashView();
%       pause(0.05);
%     end
    if isnumeric(flag)
      ecmd = ['flObj=javaObjectEDT(''com.grasppe.lure.framework.FloatingAlert'',''' msg ''');'];
      evalin('base', ecmd);
      ecmd = ['flObj.flashView(' int2str(flag) ');'];
      evalin('base', ecmd);
%       fla = javaObjectEDT('com.grasppe.lure.framework.FloatingAlert',msg);
%       fla.flashView(flag);
    elseif islogical(flag) && flag==true
%       ecmd = ['flObj=javaObjectEDT(''com.grasppe.lure.framework.FloatingAlert'',''' msg ''', true);'];
%       evalin('base', ecmd);
      ecmd = ['flObj=javaObjectEDT(''com.grasppe.lure.framework.FloatingAlert'',''' msg ''');'];
      evalin('base', ecmd);
      ecmd = 'flObj.flashView(10000);';
      evalin('base', ecmd);      
%       return;
%       fla = javaObjectEDT('com.grasppe.lure.framework.FloatingAlert',msg,true);
      %     elseif islogical(flag) && flag==false
      %       try
      %         fla.flashView();
      %       end
    end
  end
  
  if islogical(flag) && flag==false
      ecmd = 'flObj.fadeView();';
      evalin('base', ecmd);    
  end
  
  %     fla = mfla;
catch err
  javaaddpath('/Users/daflair/Documents/Workspace/MATLAB/Common/java/')
  if (exist('msg', 'var') && ~isempty(msg) && flag~=false)
    floatingAlert(msg, flag);
  end
end

end
