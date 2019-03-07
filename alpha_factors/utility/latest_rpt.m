% 注意！所有的code都默认传进来的报告记录是按照
% s_info_windcode, report_period desc, actual_ann_dt desc 排序过的

function [all_stk_codes]=latest_rpt(input_folder, stk_codes, db_names, output_folder, rpt_type)
% 最新报表数据
% 从每天的pit_data中截取需用字段，存在单独的文件中
% db_names是数据库字段名, 比如AShareIncome里面的net_profit_excl_min_int_inc
% input_folder = 'D:/Projects/pit_data/mat/income/'; 是存放pit_data的位置
% stk_codes就是wind表里面的s_info_windcode
% output_folder = 'D:/Projects_pit_data/mat/alpha_factors/'; 是用来存放结果的地址
% rpt_type = 'LYR' 最新年报数据
% rpt_type = 'SQ' 最新报表单季数据
% rpt_type = 'LR' 最新季(年)报数据

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
        ndt(i) = datenum(dt{i},'yyyymmdd');
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
        tgt_file{i} = [output_folder,rpt_type,'_',db_names{i},'.h5'];
        eval(['[S(',int2str(i),'),',db_names{i},'] = check_exist(''',tgt_file{i},''',''/',db_names{i},''',p,T,N);']);
    end
    
    Smin = min(S);
    
    if(max(S)==0)
        all_stk_codes = stk_codes;
        return;
    end
    
    % 循环从pit数据中截取最新的年报数据中需要的字段
    for i = Smin:T
        
        dt{i} = file2dt(filename{i}); % 从文件名截取日期字符串
        load([input_folder,filename{i}]); % 读取当日的pit_data
        
        if(strcmp(rpt_type,'LYR'))
            % 筛选所有年报
            data = data_last(data_last.season==4,:);  %#ok<NODEF>

            % 所有的代码
            code = data.s_info_windcode;
            code = unique(code);

            % 为防止data里面出现同一股票代码有两条记录的状况
            % 每个股票只选最靠上那条记录
            [~,Locb] = ismember(code,data.s_info_windcode);
            data = data(Locb,:);
            
        else
            if(strcmp(rpt_type,'SQ'))
                % 筛选最新的单季数据
                data = single(single.rank_rpt==1,:);  %#ok<NODEF>

                % 所有的代码
                code = data.s_info_windcode;
                code = unique(code);
                
                % 为防止data里面出现同一股票代码有两条记录的状况
                % 每个股票只选最靠上那条记录
                [~,Locb] = ismember(code,data.s_info_windcode);
                data = data(Locb,:);
                
            else
                if(strcmp(rpt_type,'LR'))
                    % 筛选最新的季报数据
                    data = data_last(data_last.rank_rpt==1,:);  %#ok<NODEF>

                    % 所有的代码
                    code = data.s_info_windcode;
                    code = unique(code);
                    
                    % 为防止data里面出现同一股票代码有两条记录的状况
                    % 每个股票只选最靠上那条记录
                    [~,Locb] = ismember(code,data.s_info_windcode);
                    data = data(Locb,:);
                    
                else
                    disp('Error: rpt_type is not in {''LR'',''SQ'',''LYR''}');
                end
            end
        end
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
            eval(['tmp = data.',db_names{k},';']);
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

