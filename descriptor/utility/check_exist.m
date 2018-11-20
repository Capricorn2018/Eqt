function [S,X] =  check_exist(tgt_file,tgt_tag,p,T,N)
       S = 0;
       X = [];

       
       [idx_stk,loc_stk,idx_dt,loc_dt,exist_flag] = check_exist_h5(tgt_file,p);
       if all(idx_stk)&&all(idx_dt)  %不需要更新
           return;
       end
       
       X = NaN(T,N);
       
       if exist_flag==0      
           S = find(p.all_trading_dates>=datenum(2005,1,1),1,'first');
       elseif exist_flag==1
           X(idx_dt,idx_stk) = h5read(tgt_file,tgt_tag);
           S = find(loc_dt==0,1,'first');
       end
       
end