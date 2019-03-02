function []=ttm(input_folder, stk_codes, db_names, output_folder)
% trailing twelve month数据
% 从每天的pit_data中截取需用字段，存在单独的文件中
% db_names是数据库字段名, 比如AShareIncome里面的net_profit_excl_min_int_inc
% input_folder = 'D:/Projects/pit_data/mat/income/single_season/'; 是存放pit_data的位置
% stk_codes就是wind表里面的s_info_windcode
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors/'; 是用来存放结果的地址

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
    % result = nan(length(filename),length(stk_codes));
    for i=1:length(db_names)
        eval([db_names{i},' = nan(length(filename),length(stk_codes));']);
        eval([db_names{i},' = array2table(',db_names{i},',''VariableNames'',colnames);']);
    end
    % table的列名如上
    % result = array2table(result,'VariableNames',colnames);
    
    % 循环从pit数据中截取最新的年报数据中需要的字段
    for i = 1:length(filename)
        
        dt{i} = file2dt(filename{i}); % 从文件名截取日期字符串
        load([input_folder,filename{i}]); % 读取当日的pit_data
        
        % 选最新的4期单季数据
        data = single(single.rank_rpt<=4,:);  %#ok<NODEF>
        
        % 所有的代码
        code = data.s_info_windcode;
        code = unique(code);
        
        % 最近的四个季度对应的单季数据
        s1 = data(data.rank_rpt==1,:);
        s2 = data(data.rank_rpt==2,:);
        s3 = data(data.rank_rpt==3,:);
        s4 = data(data.rank_rpt==4,:);
        
        % 初始化结果
        result = nan(size(code,1),size(data,2));
        result = array2table(result,'VariableNames',data.Properties.VariableNames);
        
        % 把最新的四个季度对应的字段相加计算ttm
        % 这里如有同一季(年)报在同一actual_ann_dt有多条记录的情况，则只用的最上面那条
        [~,Locb] = ismember(code,s1.s_info_windcode);
        result(:,db_names) = s1(Locb(Locb>0),db_names);
        [~,Locb2] = ismember(code,s2.s_info_windcode);
        result(:,db_names) = array2table(table2array(result(:,db_names)) + table2array(s2(Locb2(Locb2>0),db_names)));
        [~,Locb3] = ismember(code,s3.s_info_windcode);
        result(:,db_names) = array2table(table2array(result(:,db_names)) + table2array(s3(Locb3(Locb3>0),db_names)));
        [~,Locb4] = ismember(code,s4.s_info_windcode);
        result(:,db_names) = array2table(table2array(result(:,db_names)) + table2array(s4(Locb4(Locb4>0),db_names)));
        
        
        % 找到result里面对应的列
        [~,cols] = ismember(code,stk_codes); 
        cols = cols(cols>0); % 去掉股票代码表stk_code里面没有的票
        result = result(cols>0,:); %#ok<NASGU> % 去掉股票代码表stk_code里面没有的票
        
        % 把得到的结果储存在以字段名命名的变量中的一行
        for k=1:length(db_names)            
            eval(['tmp = result.',db_names{k},';']);
            eval([db_names{k},'(i,cols) = array2table(tmp'');']);
        end
        % result(i,cols) = array2table(earn');
        
        disp(i);
        
    end    
    
    % 日期列
    % result.DATEN = datenum_h5(dt);
    DATEN = datenum_h5(dt); %#ok<NASGU>
    
    % 防止忘了加文件夹地址符
    if(output_folder(end)~='/' && output_folder(end)~='\') 
        output_folder = [output_folder,'/']; 
    end
    
    % 存储结果
    for k=1:length(db_names)
        eval([db_names{k},'.DATEN = DATEN;']);        
        eval(['save(''',output_folder,'TTM_',db_names{k},'.mat'',''',db_names{k},''');']);
    end
    
    
end

% 从pit_20190201.mat格式的文件名中取得日期字符串
function dt = file2dt(filename)
    dt = filename(5:12);
end