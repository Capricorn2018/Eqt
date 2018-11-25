
function   [c_nw,c_daily] = nw_adj_spk(f_c,f_nw,p)
 
     n = size(f_c,2);
                
     c_daily = zeros(n,1);
     for i  = 1 : n
         c_daily(i,1)  = cov_(f_c(:,i),f_c(:,i),p.spk.spk_HL , p.spk.spk_HL );
     end
     
    
     c_diag     = deal(zeros(n));
    
  
     for i = 1 : p.spk.nwlag
         t1 = f_nw( 1:(end-i),:);
         t2 = f_nw( (i+1):end,:);
         c_diag = c_diag + (1- i/(p.spk.nwlag + 1))*(cov_diag(t1,t2, p.spk.nw_HL , p.spk.nw_HL )+...
                                                     cov_diag(t2,t1, p.spk.nw_HL , p.spk.nw_HL ));
     end
     
     c_nw = diag(c_diag) + c_daily;
     
     c_nw(c_nw<p.cov.small_eigen) = p.cov.small_eigen;
end