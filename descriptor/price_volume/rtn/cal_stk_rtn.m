function  cal_stk_rtn(p,a,D1,D2,if_mix)
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
   tgt_tag  = 'rtn';  
   tgt_file = [a.output_data_path,'\','rtn_',num2str(D1),'_',num2str(D2),'-',num2str(if_mix),'.h5'];

   [S,rtn] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
  
   if S>0      
       if if_mix
          vi = sector_rtn(a,D1,D2,S,T,rtn);
       end
       
       adj_prices   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')'; 
       stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
       is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
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
                 Y     = adj_prices(i-D2:i,j);
                 sus   = is_suspended(i-D2+1:i,j);
                 y     = Y(2:end)./Y(1:end-1)-1;  
                % y(isnan(y))= 0;
                 z = cumprod(1 + y);
                 tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
                 if tao==1
                     if if_mix
                         rtn(i,j) = (1-tao*tao*tao)*(z(D2-D1)-1) + tao*tao*tao*vi(i,j);
                     else
                         rtn(i,j) = z(D2-D1)-1;
                     end      
                 else
                     if if_mix
                         rtn(i,j) = vi(i,j);
                     else
                         rtn(i,j) = NaN;
                     end      
                 end
              end
           end
       end
       
  
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
   end
     
end