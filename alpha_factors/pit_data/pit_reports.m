function [] = pit_reports(data, start_dt, end_dt, n_rpt, ...
                        out_path, do_single)
    
    % 用wind插件取得交易日
    w  = windmatlab;

    [~,~,~,calender,~,~] = w.tdays(start_dt,end_dt);
    calender = datestr(calender,'yyyymmdd');
    
    calender = cellstr(calender);
    
    st = calender{1};
    t = round(str2double(st),0);
    
    % 去掉nan
    data = data(~isnan(data.actual_ann_dt) & ~isnan(data.report_period) & ~isnan(data.ann_dt),:);
    
    % 2007年附近新老报表交替时有ann_dt > actual_ann_dt的问题？？？
    % data.actual_ann_dt = max(data.actual_ann_dt, data.ann_dt);
    
    % 只选合并报表
    data = data(data.statement_type==408001000 | data.statement_type==408004000 | ...
                data.statement_type==408005000 | data.statement_type==408050000,:);
            
   % 给报表类型排序以处理同一天发布了更正公告(或者数据错误)的情况        
   data.statement_type_int = nan(size(data,1),1);
   data.statement_type_int(data.statement_type==408005000) = 4;
   data.statement_type_int(data.statement_type==408050000) = 2;
   data.statement_type_int(data.statement_type==408001000) = 3;   
   data.statement_type_int(data.statement_type==408004000) = 1;
   
    
    % 先初始化rank列避免data里面本就有这些列
    data.rank_rpt = zeros(size(data,1),1);
    data.rank_ann = data.rank_rpt;
    
    % 选择公布日在第一个交易日之前的数据
    data_last = data(data.actual_ann_dt <= t,:);
    
    %% data_last = gen_latest_pit(data_last,update);
    % 用get_ranks给报告期和公布日排序
    data_last = get_ranks(data_last);
    
    % 筛选前n_rpt个报告期的最新公布日
    data_last = data_last(data_last.rank_rpt<=n_rpt & data_last.rank_ann==1,:);
    
    %%
    
    if(do_single)
        single = single_season(data_last); %#ok<NASGU>
        save([out_path,'/pit_',st,'.mat'],'single','data_last');
    else
        %save(['D:/Projects/pit_data/mat/pit_balance_',st,'.mat'],'data_last');
        save([out_path,'/pit_',st,'.mat'],'data_last');
    end
        
    % 循环对每个交易日进行筛选, 保存
    for i=2:size(calender,1)
       
        st = calender{i};        
        lt = t; % 上一交易日
        t = round(str2double(st),0);
        
        update = data(data.actual_ann_dt <= t & data.actual_ann_dt > lt,:);
        
        %% data_last = gen_latest_pit(data_last,update);
        if(size(update,1)>0)
        
            tmp_data = [data_last;update]; % 把更新的数据加在上一交易日数据 后

            data_last = get_ranks(tmp_data); % 对每个股票的报告期排序、对每个报告期的ann_dt排序

            % 筛选前n_rpt个报告期的最新数据
            data_last = data_last(data_last.rank_rpt<=n_rpt & data_last.rank_ann==1,:);
        
        end
        %%
        
        % 若需要拆单季数据
        if(do_single)
            single = single_season(data_last); %#ok<NASGU>
            save([out_path,'/pit_',st,'.mat'],'single','data_last');
        else
            save([out_path,'/pit_',st,'.mat'],'data_last');
        end
        
        disp(st);
        
    end
    
end

% 这个是预留在这里以备今后做实时更新时使用的
function pit = gen_latest_pit(data_last,update) %#ok<DEFNU>

    if(size(update,1)>0)        
        
        if(size(data_last,1)==0)
            tmp_data = update;
        else
            tmp_data = [data_last;update]; % 把更新的数据加在上一交易日数据后
        end

        data_last = get_ranks(tmp_data); % 对每个股票的报告期排序、对每个报告期的ann_dt排序

        % 筛选前n_rpt个报告期的最新数据
        pit = data_last(data_last.rank_rpt<=n_rpt & data_last.rank_ann==1,:);
        
    else
        pit = data_last;
    end
    
    %% [~,ia,~] = unique(pit(:,{'s_info_windcode','report_period','actual_ann_dt'}));
    %% pit = pit(ia,:);
end

