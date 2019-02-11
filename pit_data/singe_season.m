function tbl = singe_season(data)

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
    
    char_cols = ['object_id','s_info_windcode','report_period','wind_code', ...
                    'actual_ann_dt','ann_dt','statement_type','crncy_code', ...
                    'comp_type_code','s_info_compcode','monetary_cap'];
    
    cols = ~ismember(names,char_cols);
    
    ary_data = table2array(data(:,cols));
    
    tmp_data = nan(size(ary_data));
    
    lvl_code = ones(size(data,1),1);
    for i=2:size(data,1)
        if(~strcmp(code(i),code(i-1)))
            lvl_code(i) = lvl_code(i-1)+1;
        else
            lvl_code(i) = lvl_code(i-1);
        end
    end
    
    for i=1:(size(data,1)-1)
        
        if(dt(i)==331)
            tmp_data(i,:) = ary_data(i,:);
        else
             for j=(i+1):size(data,1)
                 if(lvl_code(j)~=lvl_code(i))%~strcmp(code(j),code(i)))
                     tmp_data(i,:) = nan(1,size(tmp_data,2));
                     disp([code(i),', ',rpt(i)]);
                     break;
                 else
                     if(rpt(j)==last_season(rpt(j)))
                         tmp_data(i,:) = (ary_data(i,:) - ary_data(j,:));
                     end
                 end
             end
        end
    end
    
    tbl = data;

    tbl(:,cols) = array2table(tmp_data);
    tbl(:,~cols) = data(:,~cols);
    
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

