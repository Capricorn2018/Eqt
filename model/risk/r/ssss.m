
%%
      N = length(p.model.stk_codes);
      T = length(p.model.model_trading_dates);
      M = length(p.style.style);
          
      lambda_cov  =  (1/2)^(1/p.cov.vol_HL);  % lambda   = 0.5^1/HL 
      lambda_corr =  (1/2)^(1/p.cov.corr_HL); 
      lambda_vra  =  (1/2)^(1/p.cov.vra_HL); 

      D = max([p.cov.cov_N ,p.cov.corr_N,p.cov.vra_N]);
     
  K1 = 0; K2 = 0;
  for  idx_index = K1:K2     
        
         load ([a.backtest,'\regression\regression_stats_','Index',num2str(idx_index),'.mat'],'factor_rtn_matrix','factor_rtns_matrix');   % 市场（1）+ 行业(S) +风格（M)
         S  = size(p.model.alpha_code.(['Index',num2str(idx_index)]),1);%  总行业的个数
         
         [Bf,factor_csv]  = deal(zeros(T,1));

         for i = 1 : T
             % i  = 506
             if i>D+1
                 frtn0 = factor_rtn_matrix((i-D):i-1,2:end);  % 日期i 的数据用来估计今天的cov
                 frtn  = factor_rtn_matrix((i-D+1):i,2:end);  % 日期i 的数据用来估计今天的cov
            % else 
                 nan_fs  = (sum(isnan(frtn),1)+sum(isnan(frtn0),1))>0;
                 f  = frtn(:,~nan_fs);
                 f0 = frtn0(:,~nan_fs);
                 [c_nw,~] = nw_adj(f,p);
                 c_d =  cov_(f0,f0,p.cov.vol_HL , p.cov.corr_HL );

                 diag_c_nw  = diag(c_nw);
                 if any(diag_c_nw<0)
                    disp(['Index',num2str(idx_index),':',datestr(p.model.model_trading_dates(i),29)])
                 end
                 corr_nw = c_nw ./ sqrt(diag_c_nw * diag_c_nw');
                
                 [c_era,v0,U0,D0] = eigen_adj(corr_nw,f,p);
                
                 t = frtn(end,~nan_fs)./sqrt(diag(c_d))';
                 
                 Bf(i,1) = sqrt(mean(t.*t));
                 lam = sqrt(vra(lambda_vra,Bf((i-D+2):i)));
                 c = c_era;
                 for j = 1 : size(c_era,1)
                     c(i,i) = c_era(i,i)*lam;
                 end
             end

             save ([a.cov,'\',datestr(p.model.model_trading_dates(i),29),'.mat'],'c','c_era','c_nw','c_d','v','v0','U0','D0','lam'); 
         end
  end    % end for for  idx_index = K1:K2 
     
     
