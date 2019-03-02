function [] = pit_capital(asharecapitalization, start_dt, end_dt, out_path)
    
    % ��wind���ȡ�ý�����
    w  = windmatlab;

    [~,~,~,calender,~,~] = w.tdays(start_dt,end_dt);
    calender = datestr(calender,'yyyymmdd');
    
    calender = cellstr(calender);
    
    % ȥ��nan
    data = asharecapitalization(~isnan(asharecapitalization.change_dt1),:);   
    
    % ѭ����ÿ�������ս���ɸѡ, ����
    for i=1:size(calender,1)
       
        st = calender{i};
        t = round(str2double(st),0);
        
        up2date = data(data.change_dt1<=t,:);
        
        [~,ia,~] = unique(up2date.s_info_windcode);
        
        cap = up2date(ia,{'s_info_windcode','tot_shr','float_a_shr'}); %#ok<NASGU>
        
        save([out_path,'pit_',st,'.mat'],'cap');
        
        disp(st);
        
    end

end

