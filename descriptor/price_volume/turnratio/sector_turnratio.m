function [v1,v2]  = sector_turnratio(a,D1,D2,S,T,X)

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

            v1 = NaN(size(X));
            v2 = NaN(size(X));
            
            for i  = S : T
                 for j = 1:length(sector_code)
                     idx_stks = f(j) == sector_table(i,:);  
                     if ~isempty(idx_stks)
                        T1   = sector_turn(i-D1+1:i,j);
                        T2   = sector_turn(i-D2+1:i,j);
                        v1(i,idx_stks) = sum(T1);
                        v2(i,idx_stks) = sum(T2); 
                     end
                 end
            end
    
    
end