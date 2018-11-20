function  [c_nw,c_daily] = nw_adj_cov(exp_matrix,p )
                  
     c_daily =  cov_(exp_matrix,exp_matrix,factor_vol_hl,factor_corr_hl);
     n = size(c_daily,1);
     
     c_diag      = zeros(n);
     c_off_diag  = zeros(n);
     c           = zeros(n);
     c_nw       = NaN(n);
     
     % First fill in the diagonal:
     for i = 1 : nw_vol_lag
         t1 = exp_matrix(1:(end-i),:);
         t2 = exp_matrix( (i+1):end,:);
         c_diag = c_diag + (1- i/(nw_vol_lag+1))*(cov_(t1,t2,factor_vol_hl,factor_corr_hl)+...
                                                  cov_(t2,t1,factor_vol_hl,factor_corr_hl));
     end
     
     % Now compute off-diagonal entries
     for i  = 1 : nw_corr_lag
         t1 = exp_matrix(1:(end-i),:);
         t2 = exp_matrix((i+1):end,:);
         c_off_diag = c_off_diag + (1- i/(nw_corr_lag+1))*(cov_(t1,t2,factor_vol_hl,factor_corr_hl)+...
                                                           cov_(t2,t1,factor_vol_hl,factor_corr_hl));
     end
     
     c(1:n+1:end) = diag(c_diag);
     for j = 2:n
         c(j,1:j-1)  = c_off_diag(j,1:j-1);
     end
     c = c + tril(c,-1)';
     
     c = N*(c_daily + c);
     not_nan_flag = ~isnan(c(:,1));
     [u,s,v] = svd(c(not_nan_flag,not_nan_flag));     
     s(s<0)  = small_eigen;

     c_nw(not_nan_flag,not_nan_flag)    =  u*s*v';
end