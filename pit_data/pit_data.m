function [] = pit_data( data,start_dt,end_dt,n_rpt)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
    %data = proprecessing(data_file,sample_file);
    
    w  =windmatlab;

    [~,~,~,calender,~,~] = w.tdays(start_dt,end_dt);
    calender = datestr(calender,'yyyymmdd');
    
    calender = cellstr(calender);
    
    st = calender{1};
    t = round(str2double(st),0);
    
    data = data(~isnan(data.actual_ann_dt) & ~isnan(data.report_period),:);
    data = data(data.statement_type==408001000 | data.statement_type==408004000 | ...
                data.statement_type==408005000 | data.statement_type==408050000,:);
    
    data.rank_rpt = zeros(size(data,1),1);
    data.rank_ann = data.rank_rpt;
    
    data_last = data(data.actual_ann_dt<= t,:);
    
    data_last = get_ranks(data_last);
    
    data_last = data_last(data_last.rank_rpt<=n_rpt & data_last.rank_ann==1,:);
    
    save(['D:/Projects/pit_data/mat/pit_balance_',st,'.mat'],'data_last');
    
    for i=2:size(calender,1)
       
        st = calender{i};
        t = round(str2double(st),0);
        
        update = data(data.actual_ann_dt==t,:);
        
        if(size(update,1)>0)
        %    update_tickers
        
        
            tmp_data = [data_last;update];

            data_last = get_ranks(tmp_data);

            data_last = data_last(data_last.rank_rpt<=n_rpt & data_last.rank_ann==1,:);
        
        end
        
        save(['D:/Projects/pit_data/mat/pit_balance_',st,'.mat'],'data_last');
        
        disp(st);
        
    end
    

end

