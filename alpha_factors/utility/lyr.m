function []=lyr(input_folder, stk_codes, db_names, output_folder)
% 最新年报数据
% 从每天的pit_data中截取需用字段，存在单独的文件中
% db_names是数据库字段名, 比如AShareIncome里面的net_profit_excl_min_int_inc
% input_folder = 'D:/Projects/pit_data/mat/income/'; 是存放pit_data的位置
% stk_codes就是wind表里面的s_info_windcode
% output_folder = 'D:/Projects_pit_data/mat/alpha_factors/'; 是用来存放结果的地址

    % input_folder是存放pit_data的位置
    files = dir(input_folder); % 取得文件列表
    N = length(files);  % 文件个数
    
    % 循环取得文件名以及是否是文件夹的标志isdir
    filename = cell(N,1);
    isdir = zeros(N,1);
    for i=1:N
        filename{i} = files(i).name;
        isdir(i) = files(i).isdir;
    end
    
    % 去除所有的文件夹
    filename = filename(isdir==0);
    
    % dt是用来从文件名中截取日期字符串的容器
    dt = cell(length(filename),1);
    
     % 从stk_codes截取数字代码并在前面加上'ST'以便用于table的列名
    colnames = cell(length(stk_codes),1);
    for i = 1:length(stk_codes)
        colnames{i} = ['ST',stk_codes{i}(1:6)];
    end
    
    % 初始化结果
    %result = nan(length(filename),length(stk_codes));
    for i=1:length(db_names)
        eval([db_names{i},' = nan(length(filename),length(stk_codes));']);
        eval([db_names{i},' = array2table(',db_names{i},',''VariableNames'',colnames);']);
    end
    % table的列名如上
    % result = array2table(result,'VariableNames',colnames);
    
    % 循环从pit数据中截取最新的年报数据中需要的字段
    for i = 1:length(filename)
        
        dt{i} = file2dt(filename{i}); % 从文件名截取日期字符串
        load([folder,filename{i}]); % 读取当日的pit_data
        
        % 筛选所有年报
        data = data_last(data_last.season==4,:);  %#ok<NODEF>
        
        % bool用来辨别是否是该股票的最新一条年报
        code = data.s_info_windcode;
        bool = ones(size(data,1),1);        
        for j = 2:size(data,1)
            if(strcmp(code(j),code(j-1))) 
                bool(j) = 0;    % 若与上一条记录的code不相同则说明是最新的
            end
        end
        
        % 筛选所有最新报告
        code = code(bool==1);
        
        % 找到result里面对应的列
        [~,cols] = ismember(code,stk_codes); 
        cols = cols(cols>0); % 去掉股票代码表stk_code里面没有的票
        data = data(cols>0,:); %#ok<NASGU> % 去掉股票代码表stk_code里面没有的票
        
        for k=1:length(db_names)            
            eval(['tmp = data.',db_names{k},'(bool==1);']);
            eval([db_names{k},'(i,cols) = array2table(tmp'');']);
        end
        % result(i,cols) = array2table(earn');
        
        disp(i);
        
    end    
    
    % 日期列
    % result.DATEN = datenum_h5(dt);
    DATEN = datenum_h5(dt); %#ok<NASGU>
    
    % 防止忘了加文件夹地址符
    if(output_folder~='/' && output_folder(end)~='\') 
        output_folder = [output_folder,'/']; 
    end
    
    for k=1:length(db_names)
        eval([db_names{k},'.DATEN = DATEN;']);        
        eval(['save(',output_folder,db_names{k},'.mat'',''',db_names{k},''');']);
    end
    
    
end

% 从pit_20190201.mat格式的文件名中取得日期字符串
function dt = file2dt(filename)

    dt = filename(5:12);

end

