function do_cov(p,a,K1,K2)

     N = length(p.model.stk_codes);
     T = length(p.model.model_trading_dates);
     S = height(p.model.ind_names);
     M = length(p.style.style);  
     all_factors = [{'mkt'};p.model.ind_names.Eng;p.style.style];     
     non_mkt_factors = [p.model.ind_names.Eng;p.style.style];    
     D = max([p.cov.cov_N ,p.cov.corr_N,p.cov.vra_N]);
     

  for  idx_index = K1:K2     

         %  －－－－－－－－－－ load 历史上每一天的 factor return （可能有空值就用NAN表示），存储在 factor_rtn_matrix 里面  －－－－－－－－－－
         factor_rtn_matrix = NaN(length(p.model.all_trading_dates),1+S+M); % 市场（1）+ 行业(S) +风格（M)
         for i = 1: length(p.model.all_trading_dates)
             x = exist([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],'file');
             if  x==2
                 load ([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'], 'factor_rtn'); 
                 idx = ismember(all_factors,factor_rtn.Properties.VariableNames);
                 factor_rtn_matrix(i,idx) = table2array(factor_rtn);
            end
         end
            
         %  －－－－－－－－－－计算每天的经过特征值调整后的cov , 计算 B_t^F  =  sqrt(mean(f/sigma))－－－－－－－－－－
         cov_eig_last = [];
         factors_last_day   = [];  
         for i = (D + 1): length(p.model.all_trading_dates)      
             x = exist([a.cov,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],'file');
             if  x==2
                 load ([a.cov,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],  'cov_eig','factors_today');    
             else
                 idx_dt = find(p.model.all_trading_dates(i)==p.model.all_trading_dates,1,'first');
                 frtn  = factor_rtn_matrix((idx_dt-p.cov.cov_N+1):idx_dt,  2:end);    % 这里实际上默认了 corr_N  = cov_N
                 nan_fs  = sum(isnan(frtn),1)>0;
                 factors_today = non_mkt_factors(~nan_fs);
                 if  length(factors_today) > 1
                     % －－－－－－－－－－c_daily( EWMA cov) and c_nw(nw adj cov based on c_daily) －－－－－－－－－－
                     f  =  frtn(:,~nan_fs);                 
                     [cov_nw,cov_daily] = nw_adj(f,p); 
                     diag_cov_nw  = diag(cov_nw);
                     if any(diag_cov_nw<0)
                        disp(['Index',num2str(idx_index),':',datestr(p.model.all_trading_dates(i),29)])
                     end
                     %  －－－－－－－－－－ nw adjusted correlation matirx －－－－－－－－－－
                     corr_nw = cov_nw ./ sqrt(diag_cov_nw * diag_cov_nw');  
                     %  －－－－－－－－－－eigen adj for the correlation matrix －－－－－－－－－－
                     [corr_era,v0,U0,D0] = eigen_adj(corr_nw,f,p);  
                     %corr_era = corr_nw;  v0 = []; U0 = []; D0 = [];
                     %  －－－－－－－－－－  go back to the covariance matrix －－－－－－－－－－
                     cov_eig = corr2cov(sqrt(diag_cov_nw), corr_era);                 
                 else
                     cov_eig = []; cov_nw = []; cov_daily = []; factors_today = []; v0 = []; U0 = []; D0 = [];
                 end 

                 [u,ia,ib] = intersect(factors_today,factors_last_day);
                 if  ~isempty(u)
                     t = f(end,ia)./sqrt(diag(cov_eig_last(ib,ib)))';                                    
                     Bf = sqrt(mean(t.*t));
                 else
                     Bf = [];
                 end
                 save ([a.cov,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],  'cov_eig','cov_nw','cov_daily','factors_today','v0','U0','D0','Bf');    
                 clear cov_nw cov_daily v0 U0 D0 Bf
             end  % end for  if  x==2
             cov_eig_last      = cov_eig;  clear cov_eig;
             factors_last_day  = factors_today;  clear factors_today;
         end  % end for i = (D + 1): length(p.model.all_trading_dates)      
  
         %  －－－－－－－－－－load  B_t^F  的历史时间序列－－－－－－－－－－
         B_f = deal(zeros(length(p.model.all_trading_dates),1));
         for  i =  (D + 1): length(p.model.all_trading_dates)      
              load ([a.cov,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],  'Bf');
              if ~isempty(Bf)
                  B_f(i,1) =  Bf;
              end
         end
  
         %  －－－－－－－－－－VRA－－－－－－－－－－
         for i = 1 : T
             load ([a.cov,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],  'cov_eig','cov_nw','cov_daily','factors_today','v0','U0','D0','Bf');  
             idx_dt = find(p.model.model_trading_dates(i)==p.model.all_trading_dates,1,'first');
             tmp = B_f((idx_dt-p.cov.vra_N+2):idx_dt);
             if  all(tmp>0)
                 lam = sqrt(vra(p.cov.vra_HL,tmp));
                 c = lam*lam*cov_eig;
             else
                 c = cov_eig;
             end  
             save ([a.cov,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],  'c','cov_eig','cov_nw','cov_daily','factors_today','v0','U0','D0','Bf');    
          end
          
  end    % end for for  idx_index = K1:K2 
     
end