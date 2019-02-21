function result = earning_lyr(folder,stk_codes)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
% folder = 'D:/Projects/pit_data/mat/income/';

    files = dir(folder);
    N = length(files);
    filename = cell(N,1);
    isdir = zeros(N,1);
    
    for i=1:N
        filename{i} = files(i).name;
        isdir(i) = files(i).isdir;
    end
    
    filename = filename(isdir==0);
    
    dt = cell(length(filename),1);
    result = nan(length(filename),length(stk_codes));
    
    colnames = cell(length(stk_codes),1);
    for i = 1:length(stk_codes)
        colnames{i} = ['ST',stk_codes{i}(1:6)];
    end
    
    result = array2table(result,'VariableNames',colnames);
    
    for i = 1:length(filename)
        
        dt{i} = file2dt(filename{i});
        load([folder,filename{i}]);
        
        data = data_last(data_last.season==4,:);  %#ok<NODEF>
        
        bool = ones(size(data,1),1);
        code = data.s_info_windcode;
        
        for j = 2:size(data,1)
            if(strcmp(code(j),code(j-1)))
                bool(j) = 0;
            end
        end
        
        code = code(bool==1);
        [~,cols] = ismember(code,stk_codes);
        earn = data.net_profit_excl_min_int_inc(bool==1);
        result(i,cols) = array2table(earn');
        
        disp(i);
        
    end    
    
    result.DATEN = datenum_h5(dt);
    
end


function dt = file2dt(filename)

    dt = filename(5:12);

end

