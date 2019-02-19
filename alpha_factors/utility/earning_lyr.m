function [ output_args ] = earning_lyr(folder)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
% folder = 'D:/Projects/pit_data/mat/income/';

    files = dir(folder);
    N = length(files);
    name = cell(N,1);
    isdir = zeros(N,1);
    
    for i=1:N
        name{i} = files(i).name;
        isdir(i) = files(i).isdir;
    end

    name = name(isdir==0);
    
    for i = 1:length(name)
        
        dt = file2dt(name);
        load([folder,name]);
        
        data = data_last(data_last.season==4,:);  %#ok<NODEF>
        
        bool = ones(size(data,1),1);
        code = data.s_info_windcode;
        
        for j = 2:size(data,1)
            if(strcmp(code(j),code(j-1)))
                bool(j) = 0;
            end
        end
        
        code = code(bool==1);
        earn = data.net_profit_excl_min_int_inc(bool==1); 
        
    end
    
end


function dt = file2dt(filename)

    dt = filename(5:12);

end

