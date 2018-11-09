function  cal_stk_rtncorrturn(p,a,D,if_mix)
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
   tgt_tag  = 'rtncorrturn';  
   tgt_file = [a.output_data_path,'\','rtncorrturn_',num2str(D),'-',num2str(if_mix),'.h5'];

   [S,rtncorrturn] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
  
   if S>0      
       if if_mix
          vi = sector_rtncorrturn(a,D,S,T,rtncorrturn);
       end
       
       trading_volume   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/trading_volume')'; 
       free_shares      = h5read([a.input_data_path,'\fdata\base_data\free_shares.h5'],'/free_shares')'; 
       turn = trading_volume./free_shares/100;
       turn(isnan(turn)) = 0;

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
                 T     = turn(i-D+1:i,j);
                 sus   = is_suspended(i-D+1:i,j);
                 t     = T(sus==0);  
                 r     = R(sus==0);
                 if  ~isempty(t)&&~isempty(r)
                     c     = corr(t,r);
                 else
                     c   = 0;
                 end
                 tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
                 if sum(sus)>length(sus)-2
                     if if_mix
                         rtncorrturn(i,j) = (1-tao*tao*tao)*c + tao*tao*tao*vi(i,j);
                     else
                         rtncorrturn(i,j) = c;
                     end  
                 else
                     if if_mix
                         rtncorrturn(i,j) = vi(i,j);
                     else
                         rtncorrturn(i,j) = NaN;
                     end   
                 end
              end
           end
       end

       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
   end
     
end