function  cal_stk_maxmin(p,a,D1,D2,if_mix)
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
  
   tgt_tag1  = 'rmax';  
   tgt_file1 = [a.output_data_path,'\','rmax_',num2str(D1),'_',num2str(D2),'-',num2str(if_mix),'.h5'];

   tgt_tag2  = 'rmin';  
   tgt_file2 = [a.output_data_path,'\','rmin_',num2str(D1),'_',num2str(D2),'-',num2str(if_mix),'.h5'];
   
   [S,rmax] =  check_exist(tgt_file1,['/',tgt_tag1],p,T,N);
   [~,rmin] =  check_exist(tgt_file2,['/',tgt_tag2],p,T,N);
   
   if S>0      
       if if_mix
          [vi,ve] = sector_maxmin(a,D1,D2,S,T,rmax);
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
                 y     =  Y(2:end)./Y(1:end-1)-1;  
                % k = isnan(y);
                % y(k)= 0;   
              
                 y = sort(y);
                 tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
                 if tao~=1
                     if if_mix
                         rmin(i,j) = (1-tao*tao*tao)*mean(y(1:D1)) + tao*tao*tao*vi(i,j);
                         rmax(i,j) = (1-tao*tao*tao)*mean(y(end-D1+1:end)) + tao*tao*tao*ve(i,j);
                     else
                         rmin(i,j) = mean(y(1:D1));
                         rmax(i,j) = mean(y(end-D1+1:end));
                     end   
                 else
                     if if_mix
                         rmin(i,j) = vi(i,j);
                         rmax(i,j) = ve(i,j);
                     else
                         rmin(i,j) = NaN;
                         rmax(i,j) = NaN;
                     end   
                 end
              end
           end
       end    
       eval(['hdf5write(tgt_file1, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag1, ''',','' tgt_tag1, ');']);  
       eval(['hdf5write(tgt_file2, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag2, ''',','' tgt_tag2, ');']);  
   end
     
end