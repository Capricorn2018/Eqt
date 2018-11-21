function  [idx_stk, loc_stk,idx_dt, loc_dt,exist_flag] = check_exist_h5(tgt_file,p)

       if  exist(tgt_file,'file')==2
           dt     = datenum_h5 (h5read(tgt_file,'/date'));      
           scodes = stk_code_h5(h5read(tgt_file,'/stk_code'));  
          
           for j = 1 : length(scodes)
              scodes{j,1} = deblank(scodes{j});   
           end

           for j = 1: length(p.stk_codes)
               p.stk_codes{j,1} = deblank(p.stk_codes{j});   
           end
           
           scodes = intersect(p.stk_codes,scodes);
           dt = intersect(p.all_trading_dates,dt);
           
           [idx_stk, loc_stk] = ismember(p.stk_codes,scodes);
           [idx_dt, loc_dt]   = ismember(p.all_trading_dates,dt);
             
           exist_flag  = 1;
                   
       else
           [idx_stk, loc_stk,idx_dt, loc_dt] = deal(0);
           exist_flag  = 0;
       end


end