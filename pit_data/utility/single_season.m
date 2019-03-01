function tbl = single_season(data)
% ��income��cashflow���в����������
% ע�������data�Ǹ���s_info_windcode, report_period, actual_ann_dt�������

    code = data.s_info_windcode;
    rpt = data.report_period;
    dt = mod(rpt,10000); % ����
    
    % ȥ��������char����Щ����, ���������ݶ��Ǳ������ݿ������
    names = data.Properties.VariableNames;
    char_cols = {'object_id','s_info_windcode','report_period','wind_code', ...
                    'actual_ann_dt','ann_dt','statement_type','crncy_code', ...
                    'comp_type_code','s_info_compcode','monetary_cap','opdate', ...
                    'rank_rpt','rank_ann','season','statement_type_int'};
    cols = ~ismember(names,char_cols);
    
    % �������ͳ�ʼ��
    ary_data = table2array(data(:,cols));
    ary_data(isnan(ary_data)) = 0; % û���nanȫ����0�Ƿ���ʣ�����    
    tmp_data = nan(size(ary_data));
    
    % û���ҵ��ϸ�����ƥ�����ݵ����
    no_single = zeros(size(data,1),1);
    no_single(end) = 1;
    
    for i=1:(size(data,1)-1)
        
        if(dt(i)==331) % һ���ȵı�����𵥼���
            tmp_data(i,:) = ary_data(i,:);
        else
             for j=(i+1):size(data,1)
                 if(~strcmp(code(j),code(i))) 
                     % ����һ����������һ����Ʊ������������
                     tmp_data(i,:) = nan(1,size(tmp_data,2));
                     no_single(i) = 1;
                     break;
                 else
                     if(rpt(j)==last_season(rpt(i)))
                         % ���ҵ���ƥ����ϼ�������������������
                         tmp_data(i,:) = (ary_data(i,:) - ary_data(j,:));
                         break;
                     end
                 end
             end
        end
    end
    
    tbl = data;

    % ��char���͵��������
    tbl(:,cols) = array2table(tmp_data);
    tbl(:,~cols) = data(:,~cols);
    
    % ɸ��û���ҵ��ϼ������ݽ����������
    tbl = tbl(no_single==0,:);
    
end


function s=last_season(t)
% ����һ��yyyymmdd��ʽ��������ʽ����, ���ϸ���������

    yr = floor(t/10000);
    dt = mod(t,10000);
    
    if(dt==331)
        s = round((yr-1)*10000+1231,0);
    else
        if (dt==630)
            s = round(yr*10000+331,0);
        else
            if(dt==930)
                s = round(yr*10000+630,0);
            else
                if(dt==1231)
                    s = round(yr*10000+930,0);
                else
                    s = nan;
                end
            end
        end
    end

end

