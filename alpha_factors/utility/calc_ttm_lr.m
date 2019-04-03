% 注意！所有的code都默认传进来的报告记录是按照
% s_info_windcode, report_period desc, actual_ann_dt desc 排序过的

function calc_ttm_lr(input_folder, db_names, output_folder, rpt_type)
% 最新报表数据LR, SQ, LYR, TTM, YOY, LTG等
% 从每天的pit_data中截取需用字段，存在单独的文件中
% db_names是数据库字段名, 比如AShareIncome里面的net_profit_excl_min_int_inc
% input_folder = 'D:/Projects/pit_data/mat/income'; 是存放pit_data的位置
% stk_codes就是wind表里面的s_info_windcode
% output_folder = 'D:/Projects_pit_data/mat/alpha_factors'; 是用来存放结果的地址
% rpt_type = 'LYR' 最新年报数据
% rpt_type = 'SQ' 最新报表单季数据
% rpt_type = 'LR' 最新季(年)报数据

    % input_folder是存放pit_data的位置
    files = dir(input_folder); % 取得文件列表    
    
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
    
    % dt是用来从文件名中截取日期字符串的容器
    dt = cell(length(filename),1);
    ndt = nan(length(filename),1);
    for i=1:T
        dt{i} = file2dt(filename{i}); % 从文件名截取日期字符串
        ndt(i) = datenum(dt{i},'yyyymmdd');
    end
    
    % 记录每个字段需要更新的起始日
    S = zeros(length(db_names),1);
    
    % 初始化结果
    % result = nan(length(filename),length(stk_codes));
    tgt_file = cell(length(db_names),1);
    for i=1:length(db_names)
%         eval([db_names{i},' = nan(length(filename),length(stk_codes));']);
%         eval([db_names{i},' = array2table(',db_names{i},',''VariableNames'',colnames);']);
        tgt_file{i} = [output_folder,'/',rpt_type,'_',db_names{i},'.mat'];
%         eval(['[S(',int2str(i),'),',db_names{i},'] = check_exist(''',tgt_file{i},''',''/',db_names{i},''',p,T,N);']);
        if ~exist(tgt_file{i},'file')==2
            x = load(tgt_file{i}); %#ok<NASGU>
            x_date = eval(['x.',db_names{i},'.date;']);
            x_date = yyyy2datenum(x_date);
            S(i) = find(ndt>max(x_date),1);
            if isempty(S(i)) 
                S(i)=0;
            end
            eval([db_names{i},'=x.',db_names{i},';']);
        else
            S(i) = 1;
            eval([db_names{i},'=table();']);
        end
    end
    
    Smin = min(S(S>0));
    
    if(max(S)==0)
        disp('cal_ttm_lr.m: no need to update.');
        return;
    end
    
    % 循环从pit数据中截取最新的年报数据中需要的字段
    for i = Smin:T
        
        x = load([input_folder,'/',filename{i}]); % 读取当日的pit_data
        fn = fieldnames(x);
        if ~isempty(find(strcmp(fn,'data_last'),1))
            data_last = x.data_last(:,[db_names,'rank_rpt','s_info_windcode']);
            data_last.date = cellstr(repmat(dt{i},height(data_last),1));
        else
            if ~isempty(find(strcmp(fn,'cap'),1))
                data_last = x.cap(:,[db_names,'rank_rpt','s_info_windcode']);
                data_last.date = cellstr(repmat(dt{i},height(data_last),1));
            end
            if ~isempty(find(strcmp(fn,'price'),1))
                data_last = x.price(:,[db_names,'rank_rpt','s_info_windcode']);
                data_last.date = cellstr(repmat(dt{i},height(data_last),1));
            end
        end
        if ~isempty(find(strcmp(fn,'single'),1))
            single = x.single(:,[db_names,'rank_rpt','s_info_windcode']);
            single.date = cellstr(repmat(dt{i},height(single),1));
        end
        
        
        switch rpt_type
            case 'LYR'
                
                % 筛选所有年报
                result = data_last(data_last.season==4,:); 

                % 所有的代码
                code = result.s_info_windcode;
                code = unique(code);

                % 为防止data里面出现同一股票代码有两条记录的状况
                % 每个股票只选最靠上那条记录
                [~,Locb] = ismember(code,result.s_info_windcode);
                result = result(Locb,:); %#ok<NASGU>
            
            case 'SQ'
                
                % 筛选最新的单季数据
                result = single(single.rank_rpt==1,:);  

                % 所有的代码
                code = result.s_info_windcode;
                code = unique(code);
                
                % 为防止data里面出现同一股票代码有两条记录的状况
                % 每个股票只选最靠上那条记录
                [~,Locb] = ismember(code,result.s_info_windcode);
                result = result(Locb,:); %#ok<NASGU>
                
             case 'LR'
                 
                % 筛选最新的季报数据
                result = data_last(data_last.rank_rpt==1,:);

                % 所有的代码
                code = result.s_info_windcode;
                code = unique(code);

                % 为防止data里面出现同一股票代码有两条记录的状况
                % 每个股票只选最靠上那条记录
                [~,Locb] = ismember(code,result.s_info_windcode);
                result = result(Locb,:); %#ok<NASGU>
                
            case 'TTM'
                
                 % 选最新的4期单季数据
                data = single(single.rank_rpt<=4,:); 

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

                % 辨别s4对应的season是不是三个季度以前
                l4s = nan(size(result,1),1);
                l4s(Lia) = lastNseason(season1(Lia),3);
                result(season4~=l4s,:) = array2table(nan(size(result(season4~=l4s,:)))); %#ok<NASGU>
                
            case 'YOY'
                                
                % 选最新的4期单季数据
                data = single(single.rank_rpt==1 | single.rank_rpt==5,:);

                % 所有的代码
                code = data.s_info_windcode;
                code = unique(code);

                % 最近的四个季度对应的单季数据
                s1 = data(data.rank_rpt==1,:);
                s5 = data(data.rank_rpt==5,:);
                                
                % 初始化结果
                result = nan(size(code,1),size(data,2));
                result = array2table(result,'VariableNames',data.Properties.VariableNames);

                % 把最新的四个季度对应的字段相加计算ttm
                % 这里如有同一季(年)报在同一actual_ann_dt有多条记录的情况，则只用的最上面那条
                [Lia,Locb] = ismember(code,s1.s_info_windcode);
                result(Lia,db_names) = s1(Locb(Locb>0),db_names);
                season1 = nan(size(result,1),1);
                season1(Lia) = s1.report_period(Locb(Locb>0));

                [Lia5,Locb5] = ismember(code,s5.s_info_windcode);
                div = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
                tmp_s5 = table2array(s5(Locb5(Locb5>0),db_names));
                tmp_s5(tmp_s5<0) = NaN; % 分母为负的值都需要改为NaN以避免错误的YoY增速
                div(Lia5,db_names) = array2table(tmp_s5);
                result(:,db_names) = array2table(table2array(result(:,db_names)) ./ table2array(div(:,db_names)) - 1);
                season5 = nan(size(result,1),1);
                season5(Lia5) = s5.report_period(Locb5(Locb5>0));

                % 辨别s5对应的season是不是一年以前
                l5s = nan(size(result,1),1);
                l5s(Lia) = lastNseason(season1(Lia),4); % 4个季度之前就是去年相同季度
                result(season5~=l5s,:) = array2table(nan(size(result(season5~=l5s,:)))); %#ok<NASGU>
                
            case 'LTG'                  
                                
                % 选最新的12期单季数据
                data = single(single.rank_rpt<=12,:);                 
                
                % 若data没有排序过, 先排序
                if(~issorted(data.s_info_windcode))
                    data = sortrows(data,{'s_info_windcode','rank_rpt','rank_ann'},{'ascend','ascend','ascend'});                                        
                end
                
                % 所有的代码
                code = data.s_info_windcode;
                [code,ia,~] = unique(code);
                
                % 初始化结果
                result = nan(size(code,1),length(db_names));
                
                ia(length(ia)+1) = length(data.s_info_windcode)+1;
                
                for j=1:length(code)
                    
                   data_j = data(ia(j):(ia(j+1)-1),:);
                                      
                   [~,ir,~] = unique(data_j.rank_rpt);

                   if(length(ir)<12)
                       
                       result(j,:) = nan(1,length(db_names));
                       continue;
                   end

                   data_j = data_j(ir,:);
                   x = data_j.rank_rpt;
                   x = x - mean(x);
                   
                   for k = 1:length(db_names)
                       eval(['y = data_j.',db_names{k},';']);                       
                       ym = mean(y);
                       y = y - ym;
                       if(ym<0)
                          continue;                      
                       end
                       result(j,k) = -regress(y,x)/ym;
                   end
                   
                end
               
                result = array2table(result,'VariableNames',db_names); %#ok<NASGU>
                
            case 'MEAN'
                
                % 计算现值与一年前值的平均, 在计算周转率等因子时需要
                
                % 选最新的4期单季数据
                data = data_last(data_last.rank_rpt==1 | data_last.rank_rpt==5,:);

                % 所有的代码
                code = data.s_info_windcode;
                code = unique(code);

                % 最近的四个季度对应的单季数据
                s1 = data(data.rank_rpt==1,:);
                s5 = data(data.rank_rpt==5,:);
                                
                % 初始化结果
                result = nan(size(code,1),size(data,2));
                result = array2table(result,'VariableNames',data.Properties.VariableNames);

                % 把最新的四个季度对应的字段相加计算ttm
                % 这里如有同一季(年)报在同一actual_ann_dt有多条记录的情况，则只用的最上面那条
                [Lia,Locb] = ismember(code,s1.s_info_windcode);
                result(Lia,db_names) = s1(Locb(Locb>0),db_names);
                season1 = nan(size(result,1),1);
                season1(Lia) = s1.report_period(Locb(Locb>0));

                [Lia5,Locb5] = ismember(code,s5.s_info_windcode);
                add = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
                add(Lia5,db_names) = s5(Locb5(Locb5>0),db_names);
                result(:,db_names) = array2table((table2array(result(:,db_names)) + table2array(add(:,db_names)))/2);
                season5 = nan(size(result,1),1);
                season5(Lia5) = s5.report_period(Locb5(Locb5>0));

                % 辨别s5对应的season是不是一年以前
                l5s = nan(size(result,1),1);
                l5s(Lia) = lastNseason(season1(Lia),4); % 4个季度之前就是去年相同季度
                result(season5~=l5s,:) = array2table(nan(size(result(season5~=l5s,:)))); %#ok<NASGU>
                
            otherwise
                warning('Error: rpt_type is not in {''LR'',''SQ'',''LYR'',''TTM'',''YOY'',''LTG'',''MEAN''}');
        end
        
        % 合并传入的stk_codes和当日pit数据中的code
        % 以便后续处理stk_codes扩充
%         union_codes = union(code,stk_codes);
        
        % 找到result里面对应的列
%         [~,cols] = ismember(code,union_codes); %#ok<*ASGLU>
        
        % 若stk_codes不全则需要记录缺失的列以便在h5文件中补全
%         if(length(stk_codes)<length(union_codes))
%             [~,h5_cols] = ismember(stk_codes,union_codes);
%         else
%             h5_cols = 1:length(stk_codes); %#ok<*NASGU>
%         end
        
        % 把得到的结果储存在以字段名命名的变量中的一行
        for k=1:length(db_names)
            eval(['tmp = result(:,{''s_info_windcode'',''date'',''',db_names{k},'''});']);
            eval([db_names{k},'=[',db_names{k},';tmp];']);
%             eval(['tmp = result.',db_names{k},';']);
%             if(length(stk_codes) < length(union_codes))
%                 eval(['tmp_tbl = nan(size(',db_names{k},',1),length(union_codes));']);
%                 eval(['tmp_tbl(:,h5_cols) = ',db_names{k},';']);
%                 eval([db_names{k},' = tmp_tbl;']);
%             end
%             eval([db_names{k},'(i,cols) = tmp'';']);
        end
        
        % 扩展stk_codes
%         stk_codes = union_codes;
        
        disp(i);
        
    end 
    
%     tot_height = zeros(length(db_names),1);
%     
%     for k = 1:length(db_names)
%         
%         for i = Smin:T
%             eval(['tot_height(k) = tot_height(k) + height(',db_names{k},'_',dt{i},');'])
%         end
%         
%         tot_height(k) = tot_height(k) + eval(['height(',db_names{k},');']);
%         
%     end
%     
%     for k = 1:length(db_names)
%         
%         h = eval(['height(',db_names{k},')']);
%         w = 3; %#ok<NASGU>
%         tmp = table(cell(tot_height(k),1),cell(tot_height(k),1),nan(tot_height(k),1),'VariableNames',eval(['{''s_info_windcode'',''date'',''',db_names{k},'''}'])); %#ok<NASGU>
%         if h>0
%             eval(['tmp(1:h,:) = ',db_names{k},';']);
%         end
%         eval([db_names{k},'= tmp;']);
%         
%         for i=Smin:T
%             hi = eval(['height(',db_names{k},'_',dt{i},')']);
%             eval([db_names{k},'((h+1):(h+hi),:) = ',db_names{k},'_',dt{i},';']);
%             h = h+hi;
%         end
%         
%     end
    
    
    % 存储结果
    for k=1:length(db_names)
%         eval(['hdf5write(tgt_file{',int2str(k),'},''date'',dt, ''stk_code'',stk_codes,' '''', ...
%                 db_names{k}, ''',','' db_names{k}, ');']); 
        eval(['save(''',tgt_file{k},''',''',db_names{k},''');']);
    end
    
%     all_stk_codes = stk_codes;
    
end

% 从pit_20190201.mat格式的文件名中取得日期字符串
function dt = file2dt(filename)

    dt = filename(5:12);

end

% 寻找season之前n个季度的对应日期
function lastNs = lastNseason(season,n)

    lastNs = zeros(size(season));
    
    for i=1:length(season)
        tmp_s = season(i);
        for j=1:n
            tmp_s = last_season(tmp_s);
        end
        lastNs(i) = tmp_s;
    end
    
end

