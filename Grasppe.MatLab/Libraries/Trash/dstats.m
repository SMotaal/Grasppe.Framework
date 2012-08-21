function [output] = dstat(data)
data = reshape(data,1,[]);
output = struct;
output.mean = mean(data);
output.std = std(data);
output.prc90 = prctile(data,90);
output.max = max(data);
output.min = min(data);
fprintf(['Mean=%4.2f \t Std=%4.2f \t 90%%=%4.2f\n' ...
    'Max=%4.2f \t Min=%4.2f\n'], cell2mat(struct2cell(output)));

end
