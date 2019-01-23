function  cal_stk_ivol(p,a,D,HL,if_mix,index_names)
% vol，按照停牌日比例用所在板块加权
% D回溯天数，HL半衰期，if_mix是否用板块vol代替
% index_name所在板块代码，用来做停牌比例加权
  
   T = length(p.all_trading_dates);
   N = length(p.stk_codes); 
    
   for index = 1: length(index_names)               
       
          
       tgt_tag1  = 'ivol';  
       tgt_file1 = [a.output_data_path,'\','ivol_',index_names{index},'_',num2str(D),'-',num2str(if_mix),'.h5'];

       tgt_tag2  = 'ievol';  
       tgt_file2 = [a.output_data_path,'\','ievol_',index_names{index},'_',num2str(D),'_',num2str(HL),'-',num2str(if_mix),'.h5'];

       tgt_tag3  = 'iskew';  
       tgt_file3 = [a.output_data_path,'\','iskew_',index_names{index},'_',num2str(D),'-',num2str(if_mix),'.h5'];

       tgt_tag4  = 'ieskew';  
       tgt_file4 = [a.output_data_path,'\','ieskew_',index_names{index},'_',num2str(D),'_',num2str(HL),'-',num2str(if_mix),'.h5'];
   
       [S,ivol]   =  check_exist(tgt_file1,['/',tgt_tag1],p,T,N);
       [~,ievol]  =  check_exist(tgt_file2,['/',tgt_tag2],p,T,N);
       [~,iskew]  =  check_exist(tgt_file3,['/',tgt_tag3],p,T,N);
       [~,ieskew] =  check_exist(tgt_file4,['/',tgt_tag4],p,T,N);

       if S>0                 
           if if_mix
               [vi,ve,si,se ,index_level] =  sector_ivol(a,p,D,HL,S,index_names{index},NaN(size(ivol)));
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
%               tic;
%              disp(i)
               for j = 1: N
                  if p.all_trading_dates(i)>ipo_dates(j)
                     Y     = adj_prices(i-D:i,j);
                     sus   = is_suspended(i-D+1:i,j);
                     y     = Y(2:end)./Y(1:end-1)-1;  
                   %  k = isnan(y);
                   %  y(k)= 0;  
                     [~,~,w] = cal_vol_ewma_single(y,D,HL);  
                     
                     ind_lev  = index_level(i-D:i);
                     ind   = ind_lev(2:end)./ind_lev(1:end-1)-1;  % 指数 

                   %  w(k)= 0;
                     y(sus==1) = [];    ind(sus==1) = [];     w(sus==1) = [];
                     w_ = w.*w;
                     w_ = w_/sum(w_);  
                     w = sqrt(w_);
                     
                     tao = sum(sus)/length(sus);%  停牌率
         
                     if  tao~=1   
                         mdl = fitlm(array2table([y,ones(size(ind,1),1),ind],  'VariableNames',{'y','intercept','x'}), 'ResponseVar','y','Intercept',false);
                         s0 = std(mdl.Residuals.Raw)*sqrt(250); 
                         s1 = skewness(mdl.Residuals.Raw);
                         [c1,c2] = cal_vol_ewma_single1( mdl.Residuals.Raw,w);
                         if if_mix
                             ivol(i,j)   = (1-tao*tao*tao)*s0 + tao*tao*tao*vi(i,j);
                             ievol(i,j)  = (1-tao*tao*tao)*c1 + tao*tao*tao*ve(i,j);
                             iskew(i,j)  = (1-tao*tao*tao)*s1 + tao*tao*tao*si(i,j);
                             ieskew(i,j) = (1-tao*tao*tao)*c2 + tao*tao*tao*se(i,j);
                         else
                             ivol(i,j)   = s0 ;
                             ievol(i,j)  = c1 ;
                             iskew(i,j)  = s1 ;
                             ieskew(i,j) = c2 ;
                         end   
                     else
                         if if_mix
                             ivol(i,j)   = vi(i,j);
                             ievol(i,j)  = ve(i,j);
                             iskew(i,j)  = si(i,j);
                             ieskew(i,j) = se(i,j);
                         else
                             ivol(i,j)   = NaN ;
                             ievol(i,j)  = NaN ;
                             iskew(i,j)  = NaN ;
                             ieskew(i,j) = NaN ;
                         end   
                     end    % end  if  tao~=1                 
                  end % end if p.all_trading_dates(i)>ipo_dates(j)
               end  % end for j = 1: N
%               toc
           end
          eval(['hdf5write(tgt_file1, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag1, ''',','' tgt_tag1, ');']);  
          eval(['hdf5write(tgt_file2, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag2, ''',','' tgt_tag2, ');']);  
          eval(['hdf5write(tgt_file3, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag3, ''',','' tgt_tag3, ');']);  
          eval(['hdf5write(tgt_file4, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag4, ''',','' tgt_tag4, ');']);  
       end   % end  if S>0    

   end % end index = 1: length(index_names)    
     
end % end function 