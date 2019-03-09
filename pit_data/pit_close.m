function [] = pit_close( ashareeodprices, start_dt, end_dt, out_path )

    % ��wind���ȡ�ý�����
    w  = windmatlab;

    [~,~,~,calender,~,~] = w.tdays(start_dt,end_dt);
    calender = datestr(calender,'yyyymmdd');
    
    calender = cellstr(calender);
    
    % ȥ��nan
    data = ashareeodprices(~isnan(ashareeodprices.trade_dt),:);   
    
    % ѭ����ÿ�������ս���ɸѡ, ����
    for i=1:size(calender,1)
       
        st = calender{i};
        t = round(str2double(st),0);
        
        up2date = data(data.trade_dt==t,:);
        
        price = up2date(:,{'s_info_windcode','trade_dt','s_dq_close','s_dq_adjclose','s_dq_tradestatus'});
        
        price = sortrows(price,{'s_info_windcode','trade_dt'},{'ascend','descend'}); %#ok<NASGU>
        
        save([out_path,'/pit_',st,'.mat'],'price');
        
        disp(st);
        
    end


end

