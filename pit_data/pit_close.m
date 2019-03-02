function [] = pit_close( ashareeodprices, start_dt, end_dt, out_path )

    % 用wind插件取得交易日
    w  = windmatlab;

    [~,~,~,calender,~,~] = w.tdays(start_dt,end_dt);
    calender = datestr(calender,'yyyymmdd');
    
    calender = cellstr(calender);
    
    % 去掉nan
    data = ashareeodprices(~isnan(ashareeodprices.change_dt1),:);   
    
    % 循环对每个交易日进行筛选, 保存
    for i=1:size(calender,1)
       
        st = calender{i};
        t = round(str2double(st),0);
        
        up2date = data(data.change_dt1<=t,:);
        
        [~,ia,~] = unique(up2date.s_info_windcode);
        
        cap = up2date(ia,{'s_info_windcode','s_dq_close','s_dq_adjclose','s_dq_tradestatus'}); %#ok<NASGU>
        
        save([out_path,'pit_',st,'.mat'],'cap');
        
        disp(st);
        
    end


end

