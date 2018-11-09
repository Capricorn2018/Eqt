function vi = sector_sto(a,D,S,T,X)

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
            sector_turn(isnan(sector_turn)) = 0;
            
            vi = NaN(size(X));
            for i  = S : T
                 for j = 1:length(sector_code)
                     idx_stks = f(j) == sector_table(i,:);  
                     if ~isempty(idx_stks)
                        ind_turn   = sector_turn(i-D+1:i,j);
                        vi(i,idx_stks) = mean(ind_turn); 
                     end
                 end
            end
    
    
end