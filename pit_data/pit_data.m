function [] = pit_data(data, start_dt, end_dt, n_rpt, ...
                        out_path, do_single)

    %data = proprecessing(data_file,sample_file);
    
    % ��wind���ȡ�ý�����
    w  = windmatlab;

    [~,~,~,calender,~,~] = w.tdays(start_dt,end_dt);
    calender = datestr(calender,'yyyymmdd');
    
    calender = cellstr(calender);
    
    st = calender{1};
    t = round(str2double(st),0);
    
    % ȥ��nan
    data = data(~isnan(data.actual_ann_dt) & ~isnan(data.report_period),:);
    % ֻѡ�ϲ�����
    data = data(data.statement_type==408001000 | data.statement_type==408004000 | ...
                data.statement_type==408005000 | data.statement_type==408050000,:);
    
    % �ȳ�ʼ��rank�б���data���汾������Щ��
    data.rank_rpt = zeros(size(data,1),1);
    data.rank_ann = data.rank_rpt;
    
    % ѡ�񹫲����ڵ�һ��������֮ǰ������
    data_last = data(data.actual_ann_dt<= t,:);
    
    % ��get_ranks�������ں͹���������
    data_last = get_ranks(data_last);
    
    % ɸѡǰn_rpt�������ڵ����¹�����
    data_last = data_last(data_last.rank_rpt<=n_rpt & data_last.rank_ann==1,:);
    
    %save(['D:/Projects/pit_data/mat/pit_balance_',st,'.mat'],'data_last');
    save([out_path,'pit_',st,'.mat'],'data_last');
    
    if(do_single)
        single = single_season(data_last); %#ok<NASGU>
        save([out_path,'single_season/pit_',st,'.mat'],'single');
    end
        
    % ѭ����ÿ�������ս���ɸѡ, ����
    for i=2:size(calender,1)
       
        st = calender{i};        
        lt = t; % ��һ������
        t = round(str2double(st),0);
        
        update = data(data.actual_ann_dt<=t & data.actual_ann_dt>lt,:);
        
        if(size(update,1)>0)
        
            tmp_data = [data_last;update]; % �Ѹ��µ����ݼ�����һ���������� ��

            data_last = get_ranks(tmp_data); % ��ÿ����Ʊ�ı��������򡢶�ÿ�������ڵ�ann_dt����

            % ɸѡǰn_rpt�������ڵ���������
            data_last = data_last(data_last.rank_rpt<=n_rpt & data_last.rank_ann==1,:);
        
        end
        
        save([out_path,'pit_',st,'.mat'],'data_last');
        
        % ����Ҫ�𵥼�����
        if(do_single)
            single = single_season(data_last); %#ok<NASGU>
            save([out_path,'pit_',st,'.mat'],'single','-append');
        end
        
        disp(st);
        
    end
    
end

