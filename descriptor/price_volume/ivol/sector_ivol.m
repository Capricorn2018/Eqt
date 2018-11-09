function [vi,ve,si,se ,index_level] = sector_ivol(a,p,D,HL,S,index_name,X)

            T = length(p.all_trading_dates);
            N = length(p.stk_codes);
            
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


            % ¿í»ùÖ¸Êý                                     

                index_file = [a.input_data_path,'\fdata\base_data\',index_name ,'.h5'];
           
                [vi,ve,si,se] = deal(NaN(size(X)));
                bm    = h5read(index_file,'/close');
                bm_d = datenum_h5(h5read(index_file,'/date'));
                bm_ = zeros(T,1);
                [~,ia,ib] = intersect(p.all_trading_dates,bm_d);
                bm_(ia,:) = bm(ib,:); 
                index_level = bm_;
                
                for i  = S : T
                     for j = 1:length(sector_code)
                         idx_stks = f(j) == sector_table(i,:);  
                         if ~isempty(idx_stks)
                            ind_rtn   = sector_index(i-D+1:i,j)./sector_index(i-D:i-1,j)-1;
                            bm_rtn    = bm_(i-D+1:i)./bm_(i-D:i-1)-1;
                            mdl     = fitlm(array2table([ind_rtn,ones(size(ind_rtn,1),1),bm_rtn],'VariableNames',{'y','intercept','x'}), 'ResponseVar','y','Intercept',false);
                            
                            vi(i,idx_stks) = std(mdl.Residuals.Raw)*sqrt(250);
                            si(i,idx_stks) = skewness(mdl.Residuals.Raw);          
                            
                           [x1,x2,~]= cal_vol_ewma_single(mdl.Residuals.Raw,D,HL);
                           ve(i,idx_stks) = x1;
                           se(i,idx_stks) = x2;
                         end
                     end
                end
                
end