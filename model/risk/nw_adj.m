
function   [c_nw,c_daily] = nw_adj(f,p)

                  
     c_daily =  cov_(f,f,p.cov.vol_HL , p.cov.corr_HL );
     n = size(c_daily,1);
     
     [c_diag,c_off_diag,c]     = deal(zeros(n));
     c_nw       = NaN(n);
     
     % First fill in the diagonal:
     for i = 1 : p.cov.nwlag_vol
         t1 = f( 1:(end-i),:);
         t2 = f( (i+1):end,:);
         c_diag = c_diag + (1- i/(p.cov.nwlag_vol + 1))*(cov_diag(t1,t2, p.cov.vol_HL , p.cov.corr_HL )+...
                                                      cov_diag(t2,t1, p.cov.vol_HL , p.cov.corr_HL ));
     end
     
     % Now compute off-diagonal entries
     for i  = 1 :  p.cov.nwlag_corr
         t1 = f(1:(end-i),:);
         t2 = f((i+1):end,:);
         c_off_diag = c_off_diag + (1- i/(p.cov.nwlag_corr+1))*(cov_off_diag(t1,t2,p.cov.vol_HL , p.cov.corr_HL )+...
                                                             cov_off_diag(t2,t1,p.cov.vol_HL , p.cov.corr_HL ));
     end
     
     c(1:n+1:end) = diag(c_diag);
     for j = 2:n
         c(j,1:j-1)  = c_off_diag(j,1:j-1);
     end
     c = c + tril(c,-1)';
     
     c = p.cov.N*(c_daily + c);
     not_nan_flag = ~isnan(c(:,1));
     [u,s,v] = svd(c(not_nan_flag,not_nan_flag));     
     s(s<0)  =  p.cov.small_eigen ;

     c_nw(not_nan_flag,not_nan_flag)    =  u*s*v';
end