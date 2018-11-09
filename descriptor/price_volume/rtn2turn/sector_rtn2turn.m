function vi = sector_rtn2turn(a,D,S,T,X)

           sector_index = h5read([a.input_data_path,'\fdata\base_data\citics_sectors_mkt_all.h5'],'/citics_sectors_mkt_all');    
           sector_turn  = h5read([a.input_data_path,'\fdata\base_data\index_turn.h5'],'/turn');    
           sector_code  = h5read([a.input_data_path,'\fdata\base_data\index_turn.h5'],'/index_code');    
           sector_table = h5read([a.input_data_path,'\fdata\base_data\citics_stk_sectors_all.h5'],'/citics_stk_sectors_3')';


            sc = zeros(length(sector_code),1);
            for i = 1 : length(sector_code)
                sc(i,1) = str2double(sector_code{i}(5:8)); 
            end

            f = unique(sector_table);
            f = f(~isnan(f));

            [~,loc] = ismember(f,sc);
            sector_code = sector_code(loc);
            sector_turn = sector_turn(:,loc);
            sector_index = sector_index(loc,:)';
            sector_index  = adj_table(sector_index);
            sector_turn(isnan(sector_turn)) = 0;


            vi = NaN(size(X));
            for i  = S : T
                 for j = 1:length(sector_code)
                     idx_stks = f(j) == sector_table(i,:);  
                     if ~isempty(idx_stks)
                        P   = sector_index(i-D:i,j);
                        R    = P(2:end)./P(1:end-1)-1;
                        T   = sector_turn(i-D+1:i,j);
                        vi(i,idx_stks) = mean(R./T); 
                     end
                 end
            end
    
    
end