function  cal_stk_beta(p,a,D,HL,if_mix,index_names)
   
   %index_names = {'windA','csi300','csi500','csi1000'};
   %index_names = {'windA'};

   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
   tgt_tag  = 'ebeta';  
    
   for index = 1: length(index_names)               
       tgt_file = [a.output_data_path,'\','ebeta_',index_names{index},'_',num2str(D),'-',num2str(if_mix),'.h5'];
       [S,ebeta] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);

       if S>0                 
           if if_mix
               [vi ,index_level] = sector_beta(a,p,D,HL,S,index_names{index},ebeta);
           else
                index_file = [a.input_data_path,'\fdata\base_data\',index_names{index} ,'.h5'];
                bm    = h5read(index_file,'/close');
                bm_d = datenum_h5(h5read(index_file,'/date'));
                bm_ = zeros(T,1);
                [~,ia,ib] = intersect(p.all_trading_dates,bm_d);
                bm_(ia,:) = bm(ib,:); 
                index_level = bm_;
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
            % tic;
               disp(i)
               for j = 1: N
                  if p.all_trading_dates(i)>ipo_dates(j)
                     Y     = adj_prices(i-D:i,j);
                     sus   = is_suspended(i-D+1:i,j);
                     y     =Y(2:end)./Y(1:end-1)-1;  
     
                     [~,~,w] = cal_vol_ewma_single(y,D,HL);  
                     
                     ind_lev  = index_level(i-D:i);
                     ind   = ind_lev(2:end)./ind_lev(1:end-1)-1;  % Ö¸Êý 

                     y(sus==1) = [];    ind(sus==1) = [];     w(sus==1) = [];
                     w_ = w.*w;
                     w_ = w_/sum(w_);  
                     w = sqrt(w_);
                     tao = sum(sus)/length(sus);%  Í£ÅÆÂÊ
         
                     if  tao~=1   
                         mdl = fitlm(array2table([w.*y,w.*ones(size(ind,1),1),w.*ind],  'VariableNames',{'y','intercept','x'}), 'ResponseVar','y','Intercept',false);
                         b_ = mdl.Coefficients.Estimate(end);    
                         if if_mix
                             ebeta(i,j) = (1-tao*tao*tao)*b_ + tao*tao*tao*vi(i,j);
                         else
                             ebeta(i,j) = b_;
                         end   
                     else
                         if if_mix
                             ebeta(i,j) = vi(i,j);
                         else
                             ebeta(i,j) = NaN;
                         end   
                     end    % end  if  tao~=1                 
                  end % end if p.all_trading_dates(i)>ipo_dates(j)
               end  % end for j = 1: N
          % toc
           end
           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end   % end  if S>0    

   end % end index = 1: length(index_names)    
     
end % end function 