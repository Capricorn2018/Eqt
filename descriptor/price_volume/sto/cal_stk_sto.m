function  cal_stk_sto(p,a,D,if_mix)
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
   tgt_tag  = 'sto';  
   tgt_file = [a.output_data_path,'\','sto_',num2str(D),'-',num2str(if_mix),'.h5'];

   [S,sto] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
  
   if S>0      
       if if_mix
          vi = sector_sto(a,D,S,T,sto);
       end
       
       trading_volume   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/trading_volume')'; 
       free_shares      = h5read([a.input_data_path,'\fdata\base_data\free_shares.h5'],'/free_shares')'; 
       turn = trading_volume./free_shares/100;
       turn(isnan(turn)) = 0;

       stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
       is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
       ipo_dates    = datenum_h5(h5read([a.input_data_path,'\fdata\base_data\securites_terms.h5'],'/ipo_date')); 

       is_suspended(isnan(stk_status)) = NaN;
       is_suspended(is_suspended==1) = NaN;
       is_suspended(isnan(is_suspended)) =1;

       for  i  = S  : T
           for j = 1: N
              if p.all_trading_dates(i)>ipo_dates(j)
                 T     = turn(i-D+1:i,j);
                 sus   = is_suspended(i-D+1:i,j);
                 t     = T(sus==0);  
                 tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
                 if tao~=1
                     if if_mix
                         sto(i,j) = (1-tao*tao*tao)*mean(t) + tao*tao*tao*vi(i,j);
                     else
                         sto(i,j) = mean(t);
                     end  
                 else
                     if if_mix
                         sto(i,j) = vi(i,j);
                     else
                         sto(i,j) = NaN;
                     end   
                 end
              end
           end
       end

       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
   end
     
end