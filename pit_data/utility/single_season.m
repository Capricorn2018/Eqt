function tbl = single_season(data)
% 从income或cashflow表中拆出单季数据
% 注意这里的data是根据s_info_windcode, report_period, actual_ann_dt排序过的

    code = data.s_info_windcode;
    rpt = data.report_period;
    dt = mod(rpt,10000); % 日期
    
    % 去掉本身是char的那些数据, 其他的数据都是报表数据可以相减
    names = data.Properties.VariableNames;
    char_cols = {'object_id','s_info_windcode','report_period','wind_code', ...
                    'actual_ann_dt','ann_dt','statement_type','crncy_code', ...
                    'comp_type_code','s_info_compcode','monetary_cap','opdate', ...
                    'rank_rpt','rank_ann','season','statement_type_int'};
    cols = ~ismember(names,char_cols);
    
    % 向量化和初始化
    ary_data = table2array(data(:,cols));
    ary_data(isnan(ary_data)) = 0; % 没想好nan全都变0是否合适？？？    
    tmp_data = nan(size(ary_data));
    
    % 没有找到上个季度匹配数据的情况
    no_single = zeros(size(data,1),1);
    no_single(end) = 1;
    
    for i=1:(size(data,1)-1)
        
        if(dt(i)==331) % 一季度的报表不需拆单季度
            tmp_data(i,:) = ary_data(i,:);
        else
             for j=(i+1):size(data,1)
                 if(~strcmp(code(j),code(i))) 
                     % 若下一条数据是另一个股票的数据则跳出
                     tmp_data(i,:) = nan(1,size(tmp_data,2));
                     no_single(i) = 1;
                     break;
                 else
                     if(rpt(j)==last_season(rpt(i)))
                         % 若找到了匹配的上季度数据则进行两两相减
                         tmp_data(i,:) = (ary_data(i,:) - ary_data(j,:));
                         break;
                     end
                 end
             end
        end
    end
    
    tbl = data;

    % 把char类型的列填回来
    tbl(:,cols) = array2table(tmp_data);
    tbl(:,~cols) = data(:,~cols);
    
    % 筛掉没有找到上季度数据进行相减的行
    tbl = tbl(no_single==0,:);
    
end


function s=last_season(t)
% 给定一个yyyymmdd格式的整数格式日期, 算上个季度日期

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

