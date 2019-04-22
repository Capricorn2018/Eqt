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
    
    % 读取存放结果的文件, 确认每个文件更新到的日期对应的日期下标
    tgt_file = cell(length(db_names),1);
    for i=1:length(db_names)
        
        % 目标衍生数据文件
        tgt_file{i} = [output_folder,'/',rpt_type,'_',db_names{i},'.mat'];
        
        if exist(tgt_file{i},'file')==2 % 如果该文件存在 
            
            x = load(tgt_file{i});
            x_DATEN = x.data.DATEN;
            
            % 该文件的股票代码对照表
            eval([db_names{i},'_code_map=x.code_map;']);
            
            % 找出该衍生数据文件更新到的日期对应下标
            idx = find(ndt>max(x_DATEN),1);
            
            if isempty(idx) %若该文件没有需要更新的日期
                S(i) = 0;
            else
                S(i) = idx;
            end
            eval([db_names{i},'=cell(0);']);
            % 在存放结果的变量第一个元素中存放原先文件中的数据
            eval([db_names{i},'{1}=table2array(x.data);']); 
        else
            % 若没有发现该文件则S(i)=1即需要从头来算
            S(i) = 1;
            eval([db_names{i},'=cell(0);']);
            eval([db_names{i},'_code_map=table();']);
        end
    end
    
    % 需要更新的日期中取最小值即需要开始更新的下标
    Smin = min(S(S>0));
    
    % 若不需要更新则直接返回
    if(max(S)==0)
        disp('cal_ttm_lr.m: no need to be updated.');
        return;
    end
    
    % 循环从pit数据中截取最新的年报数据中需要的字段
    for i = Smin:T
        
        x = load([input_folder,'/',filename{i}]); % 读取当日的pit_data
        fn = fieldnames(x); % 不含地址的文件名称
        
        % 这里需要区分一下数据文件中的变量名
        if ~isempty(find(strcmp(fn,'data_last'),1))
            data_last = x.data_last(:,[db_names,'rank_rpt','s_info_windcode','report_period','season']);
            data_last.DATEN = repmat(ndt(i),height(data_last),1); % 加一列数据对应日期
        else
            if ~isempty(find(strcmp(fn,'cap'),1))
                data_last = x.cap(:,[db_names,'rank_rpt','s_info_windcode']);
                data_last.DATEN = repmat(ndt(i),height(data_last),1);
            end
            if ~isempty(find(strcmp(fn,'price'),1))
                data_last = x.price(:,[db_names,'rank_rpt','s_info_windcode']);
                data_last.DATEN = repmat(ndt(i),height(data_last),1);
            end
        end
        if ~isempty(find(strcmp(fn,'single'),1))
            single = x.single(:,[db_names,'rank_rpt','s_info_windcode','report_period','season']);
            single.DATEN = repmat(ndt(i),height(single),1);
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
                [code,ia,~] = unique(code);

                % 最近的四个季度对应的单季数据
                s1 = data(data.rank_rpt==1,:);
                s2 = data(data.rank_rpt==2,:);
                s3 = data(data.rank_rpt==3,:);
                s4 = data(data.rank_rpt==4,:);

                % 初始化结果
                result = data(ia,:);
                result(:,db_names) = array2table(nan(size(code,1),length(db_names)));
                

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
                result(season4~=l4s,db_names) = array2table(nan(size(result(season4~=l4s,db_names)))); %#ok<NASGU>
                
            case 'YOY'
                                
                % 选最新的4期单季数据
                data = single(single.rank_rpt==1 | single.rank_rpt==5,:);

                % 所有的代码
                code = data.s_info_windcode;
                [code,ia,~] = unique(code);

                % 最近的四个季度对应的单季数据
                s1 = data(data.rank_rpt==1,:);
                s5 = data(data.rank_rpt==5,:);
                                
                % 初始化结果
                result = data(ia,:);
                result(:,db_names) = array2table(nan(size(code,1),length(db_names)));

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
                result(season5~=l5s,db_names) = array2table(nan(size(result(season5~=l5s,db_names)))); %#ok<NASGU>
                
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
               
                result = array2table(result,'VariableNames',db_names);
                result.s_info_windcode = code;
                result.DATEN = data.DATEN(ia(1:end-1));
                
            case 'MEAN'
                
                % 计算现值与一年前值的平均, 在计算周转率等因子时需要
                
                % 选最新的4期单季数据
                data = data_last(data_last.rank_rpt==1 | data_last.rank_rpt==5,:);

                % 所有的代码
                code = data.s_info_windcode;
                [code,ia,~] = unique(code);

                % 最近的四个季度对应的单季数据
                s1 = data(data.rank_rpt==1,:);
                s5 = data(data.rank_rpt==5,:);
                                
                % 初始化结果
                result = data(ia,:);
                result(:,db_names) = array2table(nan(size(code,1),length(db_names)));

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
                result(season5~=l5s,db_names) = array2table(nan(size(result(season5~=l5s,db_names)))); %#ok<NASGU>
                
            otherwise
                warning('Error: rpt_type is not in {''LR'',''SQ'',''LYR'',''TTM'',''YOY'',''LTG'',''MEAN''}');
        end
        
        
        % 把上面得到的当日数据按照衍生数据的名称存在cell的一格里
        for k=1:length(db_names)
            
            if i>S(k)
                
                % 在结果中截取对应的衍生数据列
                eval(['tmp = result(:,{''s_info_windcode'',''DATEN'',''',db_names{k},'''});']);
                
                % 拿到股票代码对照表
                try
                    eval(['stk_codes = ',db_names{k},'_code_map.stk_codes;']);
                    eval(['stk_num = ',db_names{k},'_code_map.stk_num;']);
                catch
                    stk_codes = cell(0);
                    stk_num = nan(0);
                end

                % 在对照表里面找是否有当日结果中的股票代码不在其中
                Lia = ismember(tmp.s_info_windcode,stk_codes);
                count = length(tmp.s_info_windcode(~Lia)); % 不在对照表中的股票个数
                % 把不在对照表中的代码加在后面
                stk_codes = [stk_codes;tmp.s_info_windcode(~Lia)]; %#ok<AGROW>
                if count>0
                    % 如果在后面加了代码, 对照表需要按照顺序扩充编号, 注意前面的编号不能动
                    stk_num = [stk_num;((max([stk_num;0])+1):(max([stk_num;0])+count))']; %#ok<AGROW>
                end

                % 在新的股票代码对照表中寻找对应的stk_num编号并填入当日结果
                [~,Locb] = ismember(tmp.s_info_windcode,stk_codes);
                tmp.stk_num = stk_num(Locb); % 将对照stk_num填入当日结果
                tmp = tmp(:,{'DATEN','stk_num',db_names{k}});

                tmp = table2array(tmp);

                % 把当日结果存在cell中的一格, 并存下新的code_map
                eval([db_names{k},'{i+1}=tmp;']);
                eval([db_names{k},'_code_map = table(stk_codes,stk_num);']);

            end
            
        end
                
        disp([rpt_type,dt(i)]);
        
    end 

    % 将所有结果存入mat文件
    for k=1:length(db_names)

        % 用cell2mat拼接cell的每个格
        eval([db_names{k},'=cell2mat(',db_names{k},''');']);
        % 然后转table, 上列名
        eval(['data =array2table(',db_names{k},',''VariableNames'',{''DATEN'',''stk_num'',''',db_names{k},'''});']);
        % 对应该衍生数据的代码对照表
        code_map = eval([db_names{k},'_code_map;']); %#ok<NASGU>
        % 存储文件
        eval(['save(''',tgt_file{k},''',''data'',''code_map'');']);
    end
    
    
end

% 从pit_20190201.mat格式的文件名中取得日期字符串
function dt = file2dt(filename)

    dt = filename(5:12);

end

% 寻找某个季末日期之前n个季度的对应日期
% 用来判断TTM或者同比指标中用的rpt_period是否正确
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

