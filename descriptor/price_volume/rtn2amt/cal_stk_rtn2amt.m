function  cal_stk_rtn2amt(p,a,D,if_mix)
% return over volumn
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
   tgt_tag  = 'rtn2amt';  
   tgt_file = [a.output_data_path,'\','rtn2amt_',num2str(D),'-',num2str(if_mix),'.h5'];

   [S,rtn2amt] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
  
   if S>0      
       if if_mix
          vi = sector_rtn2amt(a,D,S,T,rtn2amt);
       end
       
       trading_amount   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/trading_amount')'; 
       trading_amount(isnan(trading_amount)) = 0;

       stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
       is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
       
       adj_prices   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')'; 
       ipo_dates    = datenum_h5(h5read([a.input_data_path,'\fdata\base_data\securites_terms.h5'],'/ipo_date')); 

       is_suspended(isnan(stk_status)) = NaN;
       is_suspended(is_suspended==1) = NaN;
       is_suspended(isnan(is_suspended)) =1;

       for i = 1 : N
           idx = find(p.all_trading_dates>=ipo_dates(i),1,'first');
           adj_prices(idx:idx + 21,i)  = NaN; % first 1 month set to NaN
       end
       
       adj_prices = adj_prices(1:T,:);  
       adj_prices  = adj_table(adj_prices);
      
       for  i  = S  : T
           for j = 1: N
              if p.all_trading_dates(i)>ipo_dates(j)
                 P     = adj_prices(i-D:i,j);
                 R     = P(2:end)./P(1:end-1)-1;
                 M     = trading_amount(i-D+1:i,j);
                 sus   = is_suspended(i-D+1:i,j);
                 m     = M(sus==0);  
                 r     = R(sus==0);
                 c     = mean(r./m);
                 tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
                 if tao~=1
                     if if_mix
                         rtn2amt(i,j) = (1-tao*tao*tao)*c + tao*tao*tao*vi(i,j);
                     else
                         rtn2amt(i,j) = c;
                     end  
                 else
                     if if_mix
                         rtn2amt(i,j) = vi(i,j);
                     else
                         rtn2amt(i,j) = NaN;
                     end   
                 end
              end
           end
       end

       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
   end
     
end