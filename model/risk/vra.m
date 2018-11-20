function  lam_vra2 = vra(factor_vra_hl,bf)
     
      t = size(bf,1);
      lam        =  (1/2)^(1/factor_vra_hl); % weight at t0,...,tn  = (1-lam)*lam^(n-1)
      lam_hl     =   power(lam, ((t-1):-1:0))';
      lam_hl     =    lam_hl/sum(lam_hl);
      
      lam_vra2 =  nansum(lam_hl.*bf.*bf);
      
      if all(isnan(bf))
            lam_vra2 = NaN;
      end
        
end

