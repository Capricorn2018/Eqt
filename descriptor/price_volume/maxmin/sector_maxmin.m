function [vi,ve] = sector_maxmin(a,D1,D2,S,T,X)

           % D1<D2
           sector_index = h5read([a.input_data_path,'\fdata\base_data\citics_sectors_mkt_all.h5'],'/citics_sectors_mkt_all');    
           sector_code  = h5read([a.input_data_path,'\fdata\base_data\citics_sectors_mkt_all.h5'],'/sector_code');    
           sector_table = h5read([a.input_data_path,'\fdata\base_data\citics_stk_sectors_all.h5'],'/citics_stk_sectors_3')';

            sc = zeros(length(sector_code),1);
            for i = 1 : length(sector_code)
                sc(i,1) = str2double(sector_code{i}(5:8)); 
            end

            f = unique(sector_table);
            f = f(~isnan(f));

            [~,loc] = ismember(f,sc);
            sector_code = sector_code(loc);
            sector_index = sector_index(loc,:)';
            sector_index  = adj_table(sector_index);  


            vi = NaN(size(X));
            ve = NaN(size(X));
            
            for i  = S : T
                 for j = 1:length(sector_code)
                     idx_stks = f(j) == sector_table(i,:);  
                     if ~isempty(idx_stks)
                        ind_rtn   = sector_index(i-D2+1:i,j)./sector_index(i-D2:i-1,j)-1;
                        ind_rtn = sort(ind_rtn);
                        vi(i,idx_stks) = mean(ind_rtn(1:D1)); 
                        ve(i,idx_stks) = mean(ind_rtn(end-D1:end));  
                     end
                 end
            end
    
    
end