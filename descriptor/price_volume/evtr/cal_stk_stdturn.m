function  cal_stk_stdturn(p,a,D,HL,if_mix)
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
  
   tgt_tag1  = 'tturn';  
   tgt_file1 = [a.output_data_path,'\','tturn_',num2str(D),'-',num2str(if_mix),'.h5'];

   tgt_tag2  = 'eturn';  
   tgt_file2 = [a.output_data_path,'\','eturn_',num2str(D),'_',num2str(HL),'-',num2str(if_mix),'.h5'];
   
   [S,tturn] =  check_exist(tgt_file1,['/',tgt_tag1],p,T,N);
   [~,eturn] =  check_exist(tgt_file2,['/',tgt_tag2],p,T,N);
   
   if S>0      
       if if_mix
          [vi,ve] = sector_stdturn(a,D,HL,S,T,tturn);
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
                 
                 f = cal_turn_ewma_single( T,sus,D,HL);
                 g = std(T(sus==0));
                 
                 tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
                 if tao~=1
                     if if_mix
                         tturn(i,j) = (1-tao*tao*tao)*g + tao*tao*tao*vi(i,j);
                         eturn(i,j) = (1-tao*tao*tao)*f + tao*tao*tao*ve(i,j);
                     else
                         tturn(i,j) = g;
                         eturn(i,j) = f;
                     end   
                 else
                     if if_mix
                         tturn(i,j) = vi(i,j);
                         eturn(i,j) = ve(i,j);
                     else
                         tturn(i,j) = NaN;
                         eturn(i,j) = NaN;
                     end   
                 end
              end
           end
       end    
       eval(['hdf5write(tgt_file1, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag1, ''',','' tgt_tag1, ');']);  
       eval(['hdf5write(tgt_file2, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag2, ''',','' tgt_tag2, ');']);  
   end
     
end