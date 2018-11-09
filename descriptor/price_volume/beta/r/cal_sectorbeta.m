function cal_sectorbeta(p,a,T,N,D,HL,tgt_file,index_file)
 
       [idx_stk,loc_stk,idx_dt,loc_dt,exist_flag] = check_exist_h5(tgt_file,p);

       if all(idx_stk)&&all(idx_dt)  %不需要更新
           return;
       end

       sector_index = h5read([a.input_data_path,'\fdata\base_data\citics_sectors_mkt_all.h5'],'/citics_sectors_mkt_all');    
       sector_code  = h5read([a.input_data_path,'\fdata\base_data\citics_sectors_mkt_all.h5'],'/sector_code');    
       sector_table = h5read([a.input_data_path,'\fdata\base_data\citics_stk_sectors_all.h5'],'/citics_stk_sectors_1')';

       sc = zeros(length(sector_code),1);
       for i = 1 : length(sector_code)
           sc(i,1) = str2double(sector_code{i}(5:8)); 
       end

       [~,loc] = ismember((5001:5029)',sc);
       sector_code = sector_code(loc);
       sector_index = sector_index(loc,:)';

       % 补上数
       idx = find(isnan(sector_index(:,1)));
       idx(idx==1)=[];
       sector_index(idx,:) = sector_index(idx-1,:);

       bm    = h5read(index_file,'/close');
       bm_d = datenum_h5(h5read(index_file,'/date'));
       bm_ = zeros(T,1);
       [~,ia,ib] = intersect(p.all_trading_dates,bm_d);
       bm_(ia,:) = bm(ib,:);

       [b,se,tvol,tskew,tvol_ewma,tskew_ewma,...
             ivol,iskew,ivol_ewma,iskew_ewma,...
             rng,rmin6,rmax6,t120,t240] = deal( NaN(T,N));

       if exist_flag==0      
           S = find(sector_index(:,1)>0,1,'first')+ D+1;
       elseif exist_flag==1
           b(idx_dt,idx_stk)  =  h5read(tgt_file, '/b');
           se(idx_dt,idx_stk) =  h5read(tgt_file, '/se');  
           
           tvol(idx_dt,idx_stk) =  h5read(tgt_file, '/tvol');  
           tskew(idx_dt,idx_stk) =  h5read(tgt_file, '/tskew');  
           tvol_ewma(idx_dt,idx_stk) =  h5read(tgt_file, '/tvol_ewma');  
           tskew_ewma(idx_dt,idx_stk) =  h5read(tgt_file, '/tskew_ewma');  
           
           ivol(idx_dt,idx_stk) =  h5read(tgt_file, '/ivol');  
           iskew(idx_dt,idx_stk) =  h5read(tgt_file, '/iskew');  
           ivol_ewma(idx_dt,idx_stk) =  h5read(tgt_file, '/ivol_ewma');  
           iskew_ewma(idx_dt,idx_stk) =  h5read(tgt_file, '/iskew_ewma');  
           
           rng(idx_dt,idx_stk) =  h5read(tgt_file, '/rng'); 
           
           rmin6(idx_dt,idx_stk) =  h5read(tgt_file, '/rmin6'); 
           rmax6(idx_dt,idx_stk) =  h5read(tgt_file, '/rmax6'); 
             
           t120(idx_dt,idx_stk) =  h5read(tgt_file, '/t120'); 
           t240(idx_dt,idx_stk) =  h5read(tgt_file, '/t240'); 
           
           S = find(loc_dt==0,1,'first');
       end

       s= (5001:5029)';
       for  i  = S : T
           for j = 1:length(sector_code)
               idx_stks = s(j) == sector_table(i,:);
               ind   = sector_index(i-D+1:i,j)./sector_index(i-D:i-1,j)-1;
               y     = bm_(i-D+1:i)./bm_(i-D:i-1)-1;
               
               
               [x1,x2,w] = cal_vol_ewma_single(ind,D,HL);
               tvol_ewma(i,idx_stks) = x1;
               tskew_ewma(i,idx_stks) = x2;
               
               
                tvol(i,idx_stks)  = std(ind)*sqrt(250); 
                tskew(i,idx_stks) = skewness(ind); 
               
               mdl     = fitlm(array2table([w.*ind,w.*y],    'VariableNames',{'y','x'}), 'ResponseVar','y','Intercept',true);
               b(i,idx_stks) = mdl.Coefficients.Estimate(end);    
               se(i,idx_stks) = mdl.Coefficients.SE(end);      
               
               mdl     = fitlm(array2table([ind,y],    'VariableNames',{'y','x'}), 'ResponseVar','y','Intercept',true);
               ivol(i,idx_stks) = std(mdl.Residuals.Raw)*sqrt(250);
               iskew(i,idx_stks) = skewness(mdl.Residuals.Raw);              
               [x1,x2,~]= cal_vol_ewma_single(mdl.Residuals.Raw,D,HL);
               ivol_ewma(i,idx_stks) = x1;
               iskew_ewma(i,idx_stks) = x2;
               
             
               
               ind1 = sort(ind);
               rmin6(i,idx_stks) = mean(ind1(1:6));
               rmax6(i,idx_stks) = mean(ind1(end-5:end));
               
               cum = cumprod(1+ind);
               rng(i,idx_stks) = max(cum)/min(cum) - 1;
               t120(i,idx_stks) = mean(cum(end-4:end))/mean(cum(end-119:end));
               t240(i,idx_stks) = mean(cum(end-4:end))/mean(cum(end-239:end));
               
             %   
           end
       end

       if exist_flag==1
          delete(tgt_file);
       end

       hdf5write(tgt_file,  '/b', b,  '/s', se, ...
                 '/tvol', tvol, '/tskew',tskew, '/tvol_ewma', tvol_ewma, '/tskew_ewma',tskew_ewma,...
                 '/ivol', ivol, '/iskew',iskew, '/ivol_ewma', ivol_ewma, '/iskew_ewma',iskew_ewma,...
                 '/rng', rng, '/rmin6',rmin6, '/rmax6', rmax6, '/t120',t120,'/t240',t240,...
                 '/date',p.all_trading_dates_, '/stk_code',p.stk_codes_);  

end