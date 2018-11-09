function  [c_era,v0,U0,D0] = eigen_adj(F0,f,p)

      % (F0) is the K*K sample covariance matrix (FCM) where K is the
      %        number of factors and T is the number of periods
      %   (f) is the K*T matrix of realized factor returns
  
      
      %  F0 = U0*D0*U0'  hence  D0  =  U0'*F0*U0
      
     % F0 = corr_nw;
      
      nan_flag = isnan(F0(:,1));
      if  any(nan_flag)
          error('nan elements in FO');
      end
      
      [U0,D0,~] = svd(F0);     
      diagD0 = diag(D0);
      
      K  = size(D0,1); % number of factors
      T  = size(f,1);  % number of days
      
      Dmk  = NaN(p.cov.simtimes,K);
      Dm_k = NaN(p.cov.simtimes,K);
      
      for i  = 1 : p.cov.simtimes
           % simulation  b_m:  f_m = u*b_m  b_m is a K*T  matrix of
           % simulated eigenfactor returns the elsements f row k of b_m 
           % ~ N(O,k th elements of d)
            bm =  NaN(K,T);  
            for j  = 1 : K
                bm(j,:)  = sqrt(diagD0(j))*randn(1,T);
            end
            fm = U0*bm;
            Fm = corr(fm');
            [Um,Dm,~] = svd(Fm);      
            Dmbar = Um'*F0*Um;
            Dmk(i,:)   = diag(Dm);
            Dm_k(i,:)  = diag(Dmbar);
      end
      
      % compute simulated volatility biases
       v0 = sqrt(mean(Dm_k./Dmk,1))';% plot(v)... need to check out here
       
       %v = p.eig_a*(v0 - 1) +1;
       % parabolic fit
      
       c_era = U0*(diag(v0)*diag(v0)*D0)*U0';
end