function r4_cov(p,a,K1,K2)


%%
      N = length(p.model.stk_codes);
      T = length(p.model.model_trading_dates);
      M = length(p.style.style);
          
      D = max([p.cov.cov_N ,p.cov.corr_N,p.cov.vra_N]);
     

  for  idx_index = K1:K2     
         
         S  = size(p.model.alpha_code.(['Index',num2str(idx_index)]),1);%  总行业的个数
         
         factor_rtn_matrix = NaN(length(p.model.all_trading_dates),S+M+1); % 市场（1）+ 行业(S) +风格（M)
         for i = 1: length(p.model.all_trading_dates)
             x = exist([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],'file');
             if  x==2
                 load ([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'], 'factor_rtn'); 
                 factor_rtn_matrix(i,:) = table2array(factor_rtn);
            end
         end
         
         all_factors =  [ p.model.alpha_code.(['Index',num2str(idx_index)]).Eng',p.style.style'];       
         [Bf,factor_csv,lambda]  = deal(zeros(length(p.model.all_trading_dates),1));
         
         for i = (D + 1): length(p.model.all_trading_dates)      
                 frtn0 = factor_rtn_matrix((i-p.cov.cov_N)  :i-1,2:end);  
                 frtn  = factor_rtn_matrix((i-p.cov.cov_N+1):i,  2:end);  
                 nan_fs  = (sum(isnan(frtn),1)+sum(isnan(frtn0),1))>0;
                 f0 = frtn0(:,~nan_fs);
                 if  ~isempty(f0)                    
                     c_d =  cov_(f0,f0,p.cov.vol_HL , p.cov.corr_HL );
                     t = frtn(end,~nan_fs)./sqrt(diag(c_d))';                           
                     factor_csv(i,1) = sqrt(mean(frtn(end,~nan_fs).*frtn(end,~nan_fs)));               
                     Bf(i,1) = sqrt(mean(t.*t));
                     tmp = Bf((i-p.cov.vra_N+2):i);
                     lambda(i,1) =  sqrt(vra(p.cov.vra_HL,tmp));
                 end
         end
         

         for i = 1 : T
             if i>D+1
               %  tic;
                 idx_dt = find(p.model.model_trading_dates(i)==p.model.all_trading_dates,1,'first');
                 
                 frtn0 = factor_rtn_matrix((idx_dt-p.cov.cov_N)  :idx_dt-1,2:end);  
                 frtn  = factor_rtn_matrix((idx_dt-p.cov.cov_N+1):idx_dt,  2:end);  
                 nan_fs  = (sum(isnan(frtn),1)+sum(isnan(frtn0),1))>0;
                 
                 factors_today = all_factors(~nan_fs);
               
                 f  =  frtn(:,~nan_fs);                 
                 [c_nw,c_daily] = nw_adj(f,p); % first compute EWMA convariance matrix c_daily then calculate c_nw

                 diag_c_nw  = diag(c_nw);
                 if any(diag_c_nw<0)
                    disp(['Index',num2str(idx_index),':',datestr(p.model.model_trading_dates(i),29)])
                 end
                 corr_nw = c_nw ./ sqrt(diag_c_nw * diag_c_nw');  %  the nw adjusted correlation matirx
                
                 [c_era,v0,U0,D0] = eigen_adj(corr_nw,f,p);  % eigen adj for the 【correlation】 matrix
                
                 cov_eig = corr2cov(sqrt(diag_c_nw), c_era); % go back to the covariance matrix
                 
                 tmp = Bf((idx_dt-p.cov.vra_N+2):idx_dt);
                 if  ~any(tmp)
                     lam = sqrt(vra(p.cov.vra_HL,tmp));
                     c = lam*lam*cov_eig;
                 else
                     c = cov_eig;
                 end                
             %    toc;
                 save ([a.cov,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'c','cov_eig','c_nw','c_daily','factors_today','c_d','v0','U0','D0'); 
             end  % end  if i>D+1          
         end
  end    % end for for  idx_index = K1:K2 
     
end