function [all_stk_codes]=ttm(input_folder, stk_codes, db_names, output_folder)
% trailing twelve month数据
% 从每天的pit_data中截取需用字段，存在单独的文件中
% db_names是数据库字段名, 比如AShareIncome里面的net_profit_excl_min_int_inc
% input_folder = 'D:/Projects/pit_data/mat/income/'; 是存放pit_data的位置
% stk_codes就是wind表里面的s_info_windcode
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors/'; 是用来存放结果的地址

    % input_folder是存放pit_data的位置
    files = dir(input_folder); % 取得文件列表    
    
    % 防止忘了加文件夹地址符
    if(output_folder(end)~='/' && output_folder(end)~='\') 
        output_folder = [output_folder,'/']; 
    end
    
    % 循环取得文件名以及是否是文件夹的标志isdir
    filename = cell(length(files),1);
    isdir = zeros(length(files),1);
    for i=1:length(files)
        filename{i} = files(i).name;
        isdir(i) = files(i).isdir;
    end
    
    % 去除所有的文件夹
    filename = filename(isdir==0);
    T = length(filename);  % 文件个数    
    N = length(stk_codes);
    
    % dt是用来从文件名中截取日期字符串的容器
    dt = cell(length(filename),1);
    ndt = nan(length(filename),1);
    for i=1:T
        dt{i} = file2dt(filename{i}); % 从文件名截取日期字符串
        ndt(i) = str2double(dt{i});
    end
    
    % 记录每个字段需要更新的起始日
    S = zeros(length(db_names),1);
    p.all_trading_dates_ = dt;
    p.all_trading_dates = ndt;
    p.stk_codes = stk_codes; %#ok<STRNU>
    
    % 初始化结果
    % result = nan(length(filename),length(stk_codes));
    tgt_file = cell(length(db_names),1);
    for i=1:length(db_names)
%         eval([db_names{i},' = nan(length(filename),length(stk_codes));']);
%         eval([db_names{i},' = array2table(',db_names{i},',''VariableNames'',colnames);']);
        tgt_file{i} = [output_folder,'TTM_',db_names{i},'.h5'];
        eval(['[S(',int2str(i),'),',db_names{i},'] = check_exist(''',tgt_file{i},''',''/',db_names{i},''',p,T,N);']);
    end
    
    Smax = max([S;1]);
    
    % 循环从pit数据中截取最新的年报数据中需要的字段
    for i = Smax:T
        
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
        [Lia,Locb] = ismember(code,s1.s_info_windcode);
        result(Lia,db_names) = s1(Locb(Locb>0),db_names);
        season1 = nan(size(result,1),1);
        season1(Lia) = s1.report_period(Locb(Locb>0));
        
        [Lia2,Locb2] = ismember(code,s2.s_info_windcode);
        add = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
        add(Lia2,db_names) = s2(Locb2(Locb2>0),db_names);
        result(:,db_names) = array2table(table2array(result(:,db_names)) + table2array(add(:,db_names)));
        
        [Lia3,Locb3] = ismember(code,s3.s_info_windcode);
        add = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
        add(Lia3,db_names) = s3(Locb3(Locb3>0),db_names);
        result(:,db_names) = array2table(table2array(result(:,db_names)) + table2array(add(:,db_names)));
        
        [Lia4,Locb4] = ismember(code,s4.s_info_windcode);
        add = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
        add(Lia4,db_names) = s4(Locb4(Locb4>0),db_names);
        result(:,db_names) = array2table(table2array(result(:,db_names)) + table2array(add(:,db_names)));
        season4 = nan(size(result,1),1);
        season4(Lia4) = s4.report_period(Locb4(Locb4>0));
        
        % 辨别s4对应的season是不是一年以前
        l4s = nan(size(result,1),1);
        l4s(Lia) = last4season(season1(Lia));
        result(season4~=l4s,:) = array2table(nan(size(result(season4~=l4s,:))));
        
        % test
        union_codes = union(code,stk_codes);
        
        % 找到result里面对应的列
        [~,cols] = ismember(code,union_codes); %#ok<*ASGLU>
        if(length(stk_codes)<length(union_codes))
            [~,h5_cols] = ismember(stk_codes,union_codes);
        else
            h5_cols = 1:length(stk_codes); %#ok<*NASGU>
        end
        
        % 把得到的结果储存在以字段名命名的变量中的一行
        for k=1:length(db_names)            
            eval(['tmp = result.',db_names{k},';']);
            if(length(stk_codes)<length(union_codes))
                eval(['tmp_tbl = nan(size(',db_names{k},',1),length(union_codes);']);
                eval(['tmp_tbl(:,h5_cols) = ',db_names{k},';']);
                eval([db_names{k},' = tmp_tbl;']);
            end
            eval([db_names{k},'(i,cols) = tmp'';']);
        end
        
        % 扩展stk_codes
        stk_codes = union_codes;
                
        disp(i);
        
    end
    
    % 存储结果
    for k=1:length(db_names)
%         eval([db_names{k},'.DATEN = DATEN;']);        
%         eval(['save(''',output_folder,'TTM_',db_names{k},'.mat'',''',db_names{k},''');']);
        eval(['hdf5write(tgt_file{',int2str(k),'},''date'',dt, ''stk_code'',stk_codes,' '''',db_names{k}, ''',','' db_names{k}, ');']); 
    end
    
    all_stk_codes = stk_codes;
    
end

% 从pit_20190201.mat格式的文件名中取得日期字符串
function dt = file2dt(filename)
    dt = filename(5:12);
end

% 找最新季报对应季度的三个季度之前对应的report_period
function last_4s = last4season(season)

    last_4s = zeros(size(season));
    
    for i=1:length(season)
        last_4s(i) = last_season(last_season(last_season(season(i))));
    end
    
end