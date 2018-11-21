function r4_cov(p,a,K1,K2)


%%
      N = length(p.model.stk_codes);
      T = length(p.model.model_trading_dates);
      M = length(p.style.style);
          
     % lambda_cov  =  (1/2)^(1/p.cov.vol_HL);  % lambda   = 0.5^1/HL 
     % lambda_corr =  (1/2)^(1/p.cov.corr_HL); 
     % lambda_vra  =  (1/2)^(1/p.cov.vra_HL); 

      D = max([p.cov.cov_N ,p.cov.corr_N,p.cov.vra_N]);
     

  for  idx_index = K1:K2     
        
         load ([a.backtest,'\regression\regression_stats_','Index',num2str(idx_index),'.mat'],'factor_rtn_matrix','factor_rtns_matrix');   % 市场（1）+ 行业(S) +风格（M)
         S  = size(p.model.alpha_code.(['Index',num2str(idx_index)]),1);%  总行业的个数
         all_factors =  [ p.model.alpha_code.(['Index',num2str(idx_index)]).Eng',p.style.style'];
         [Bf,factor_csv,lambda]  = deal(zeros(T,1));

         for i = 1 : T
             % i  = 506
             if i>D+1
                % tic;
                 frtn0 = factor_rtn_matrix((i-p.cov.cov_N):i-1,2:end);  
                 frtn  = factor_rtn_matrix((i-p.cov.cov_N+1):i,2:end);  
                 nan_fs  = (sum(isnan(frtn),1)+sum(isnan(frtn0),1))>0;
                 
                 factors_today = all_factors(~nan_fs);
               
                 
                 f  = frtn(:,~nan_fs);
                 f0 = frtn0(:,~nan_fs);
                 [c_nw,c_daily] = nw_adj(f,p);
                 c_d =  cov_(f0,f0,p.cov.vol_HL , p.cov.corr_HL );

                 diag_c_nw  = diag(c_nw);
                 if any(diag_c_nw<0)
                    disp(['Index',num2str(idx_index),':',datestr(p.model.model_trading_dates(i),29)])
                 end
                 corr_nw = c_nw ./ sqrt(diag_c_nw * diag_c_nw');
                
                 [c_era,v0,U0,D0] = eigen_adj(corr_nw,f,p);
                
                 cov_eig = corr2cov(sqrt(diag_c_nw), c_era);
                                
                 t = frtn(end,~nan_fs)./sqrt(diag(c_d))';
                 
                 factor_csv(i,1) = sqrt(mean(frtn(end,~nan_fs).*frtn(end,~nan_fs)));
                 
                 Bf(i,1) = sqrt(mean(t.*t));
                 
                 tmp = Bf((i-p.cov.vra_N+2):i);
                 if  ~any(tmp)
                     lam = sqrt(vra(p.cov.vra_HL,tmp));
                     lambda(i,1) = lam;
                     c = lam*lam*cov_eig;
                 else
                     c = cov_eig;
                 end
                 
                 %toc;
                 save ([a.cov,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'c','cov_eig','c_nw','c_daily','factors_today','c_d','v0','U0','D0'); 
             end

             
         end
         
         cov_stats = array2table( [p.model.model_trading_dates,factor_csv,Bf,lambda],'VariableNames',{'date','factor_csv','Bf','lambda'});
         
         save ([a.backtest,'\cov\cov_stats_','Index',num2str(idx_index),'.mat'],'cov_stats'); 
  end    % end for for  idx_index = K1:K2 
     
     


end