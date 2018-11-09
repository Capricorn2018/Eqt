function  cal_stk_turnratio(p,a,D1,D2,if_mix)
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
   tgt_tag  = 'turnratio';  
   tgt_file = [a.output_data_path,'\','turnratio_',num2str(D2),'-',num2str(if_mix),'.h5'];

   [S,turnratio] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
   [r1,r2] = deal(zeros(size(turnratio)));
   
   
   if S>0      
       if if_mix
          [v1,v2] = sector_turnratio(a,D1,D2,S,T,turnratio);
       end
       
       trading_volume   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/trading_volume')'; 
       free_shares      = h5read([a.input_data_path,'\fdata\base_data\free_shares.h5'],'/free_shares')'; 
    
       trading_volume(isnan(trading_volume)) = 0;
       free_shares(isnan(free_shares)) = 0;
       

       stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
       is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
       ipo_dates    = datenum_h5(h5read([a.input_data_path,'\fdata\base_data\securites_terms.h5'],'/ipo_date')); 

       is_suspended(isnan(stk_status)) = NaN;
       is_suspended(is_suspended==1) = NaN;
       is_suspended(isnan(is_suspended)) =1;

       for  i  = S  : T
           for j = 1: N
              if p.all_trading_dates(i)>ipo_dates(j)
               %
                     T     = trading_volume(i-D2+1:i,j);
                     F     = free_shares(i-D2+1:i,j);
                     sus   = is_suspended(i-D2+1:i,j);
                     t     = T(sus==0);  
                     f     = F(sus==0);
                     tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
                     if tao~=1
                         if if_mix
                             r2(i,j) = (1-tao*tao*tao)*sum(t)/mean(f) + tao*tao*tao*v1(i,j);
                         else
                             r2(i,j) = sum(t)/mean(f);
                         end  
                     else
                         if if_mix
                             r2(i,j) = v1(i,j);
                         else
                             r2(i,j) = NaN;
                         end   
                     end
                 
                 %
                     T     = trading_volume(i-D1+1:i,j);
                     F     = free_shares(i-D1+1:i,j);
                     sus   = is_suspended(i-D1+1:i,j);
                     t     = T(sus==0);  
                     f     = F(sus==0);
                     tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
                     if tao~=1
                         if if_mix
                             r1(i,j) = (1-tao*tao*tao)*sum(t)/mean(f) + tao*tao*tao*v2(i,j);
                         else
                             r1(i,j) = sum(t)/mean(f);
                         end  
                     else
                         if if_mix
                             r1(i,j) = v2(i,j);
                         else
                             r1(i,j) = NaN;
                         end   
                     end
  
              end  %end  p.all_trading_dates(i)>ipo_dates(j)
           end
       end
       turnratio = r1./r2;
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
   end
     
end