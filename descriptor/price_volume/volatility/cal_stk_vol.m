function  cal_stk_vol(p,a,D,HL,if_mix)
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
  
   tgt_tag1  = 'tvol';  
   tgt_file1 = [a.output_data_path,'\','tvol_',num2str(D),'-',num2str(if_mix),'.h5'];

   tgt_tag2  = 'evol';  
   tgt_file2 = [a.output_data_path,'\','evol_',num2str(D),'_',num2str(HL),'-',num2str(if_mix),'.h5'];
   
   [S,tvol] =  check_exist(tgt_file1,['/',tgt_tag1],p,T,N);
   [~,evol] =  check_exist(tgt_file2,['/',tgt_tag2],p,T,N);
   
   if S>0      
       if if_mix
          [vi,ve] = sector_vol(a,D,HL,S,T,tvol);
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
                 Y     = adj_prices(i-D:i,j);
                 sus   = is_suspended(i-D+1:i,j);
                 y     =  Y(2:end)./Y(1:end-1)-1;  
                % k = isnan(y);
                % y(k)= 0;   
                 [~,~,w] = cal_vol_ewma_single(y,D,HL); 
                % w(k)= 0;
                 y(sus==1) = [];    w(sus==1) = [];
                     w_ = w.*w;
                     w_ = w_/sum(w_);  
                     w = sqrt(w_);
                 [c,~] = cal_vol_ewma_single1( y,w);
                                
                 tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
                 if tao~=1
                     if if_mix
                         tvol(i,j) = (1-tao*tao*tao)*std(y)*sqrt(250) + tao*tao*tao*vi(i,j);
                         evol(i,j) = (1-tao*tao*tao)*c                + tao*tao*tao*ve(i,j);
                     else
                         tvol(i,j) = std(y)*sqrt(250);
                         evol(i,j) = c;
                     end   
                 else
                     if if_mix
                         tvol(i,j) = vi(i,j);
                         evol(i,j) = ve(i,j);
                     else
                         tvol(i,j) = NaN;
                         evol(i,j) = NaN;
                     end   
                 end
              end
           end
       end    
       eval(['hdf5write(tgt_file1, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag1, ''',','' tgt_tag1, ');']);  
       eval(['hdf5write(tgt_file2, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag2, ''',','' tgt_tag2, ');']);  
   end
     
end