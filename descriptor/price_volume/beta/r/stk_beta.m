function  stk_beta(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);
       D = 252;
       HL = 63;

       adj_prices   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')'; 
       stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
       is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
       ipo_dates    = datenum_h5(h5read([a.input_data_path,'\fdata\base_data\securites_terms.h5'],'/ipo_date')); 

       is_suspended(isnan(stk_status)) = NaN;
       is_suspended(is_suspended==1) = NaN;
       is_suspended(isnan(is_suspended)) =1;

       for i = 1 : N
           idx = find(p.all_trading_dates>=ipo_dates(i),1,'first');
           adj_prices(idx:idx+30,i)  = NaN;
       end
       
       adj_prices = adj_prices(1:T,:);
       
      disp(['winda: ',datestr(now)])
      shrink_beta('betawinda','windA.h5',p,a,T,N,D,HL,adj_prices,is_suspended,ipo_dates); 
%       disp(['300: ',datestr(now)])
%       shrink_beta('beta300','csi300.h5',p,a,T,N,D,HL,adj_prices,is_suspended,ipo_dates);
%       disp(['500: ',datestr(now)])
%       shrink_beta('beta500','csi500.h5',p,a,T,N,D,HL,adj_prices,is_suspended,ipo_dates);
%       disp(['1000: ',datestr(now)])
%       shrink_beta('beta1000','csi1000.h5',p,a,T,N,D,HL,adj_prices,is_suspended,ipo_dates);

end