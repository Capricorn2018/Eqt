function [vi,ve] = sector_vol(a,D,HL,S,T,X)

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
                        ind_rtn   = sector_index(i-D+1:i,j)./sector_index(i-D:i-1,j)-1;
                        [c,~,~] = cal_vol_ewma_single(ind_rtn,D,HL);  
                        vi(i,idx_stks) = std(ind_rtn)*sqrt(250); 
                        ve(i,idx_stks) = c; 
                     end
                 end
            end
    
    
end