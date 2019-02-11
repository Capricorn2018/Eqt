function tbl = single_season(data)

%     id = data.object_id;
     code = data.s_info_windcode;
     rpt = data.report_period;
     dt = mod(rpt,10000);
%     wind = data.wind_code;    
%     ann = data.actual_ann_dt;
%     ann2 = data.ann_dt;
%     state = data.statement_type;
%     crncy = data.crncy_code;
%     comp = data.comp_type_code;
%     comp_code = data.s_info_compcode;
    
    names = data.Properties.VariableNames;
    
    char_cols = {'object_id','s_info_windcode','report_period','wind_code', ...
                    'actual_ann_dt','ann_dt','statement_type','crncy_code', ...
                    'comp_type_code','s_info_compcode','monetary_cap','opdate'};
    
    cols = ~ismember(names,char_cols);
    
    ary_data = table2array(data(:,cols));
    ary_data(isnan(ary_data)) = 0;
    
    tmp_data = nan(size(ary_data));
    
    no_single = zeros(size(data,1),1);
    no_single(end) = 1;
    
    for i=1:(size(data,1)-1)
        
        if(dt(i)==331)
            tmp_data(i,:) = ary_data(i,:);
        else
             for j=(i+1):size(data,1)
                 if(~strcmp(code(j),code(i)))
                     tmp_data(i,:) = nan(1,size(tmp_data,2));
                     %disp([code(i),', ',rpt(i)]);
                     no_single(i) = 1;
                     break;
                 else
                     if(rpt(j)==last_season(rpt(i)))
                         tmp_data(i,:) = (ary_data(i,:) - ary_data(j,:));
                         break;
                     end
                 end
             end
        end
    end
    
    tbl = data;

    tbl(:,cols) = array2table(tmp_data);
    tbl(:,~cols) = data(:,~cols);
    
    tbl = tbl(no_single==0,:);
    
end


% function s=last_season(t)
% 
%     yr = floor(t/10000);
%     dt = mod(t,10000);
%     
%     if(dt==331)
%         s = round((yr-1)*10000+1231,0);
%     else
%         if (dt==630)
%             s = round(yr*10000+331,0);
%         else
%             if(dt==930)
%                 s = round(yr*10000+630,0);
%             else if(dt==1231)
%                     s = round(yr*10000+930,0);
%                 end
%             end
%         end
%     end
% 
% end

