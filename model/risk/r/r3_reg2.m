function mkt = r3_reg2(p,a)
    
     N = length(p.model.stk_codes);
     T = length(p.model.model_trading_dates);
     S = length(p.ind.lv2);
     M = length(p.style);

%%

    adj_price     = h5read(p.file.stk,'/adj_prices')';   % T by N
    adj_rtn       = [nan(1,size(adj_price,2));adj_price(2:end,:)./adj_price(1:end-1,:)-1];
    adj_rtn(adj_rtn>0.105) = 0;
    adj_rtn(adj_rtn<-0.105) = 0;
    %adj_rtn(isnan(adj_rtn)) = 0;
    sectors        = h5read(p.file.ind,'/citics_stk_sectors_2')';
    mkt  = zeros(T,2);
    for i = 1 : T
          %disp(i)

          load([a.sector,'\',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_today','T_stocks_cap_freecap_sector');
  
          % y = Xf +e  这里先算出 y
          idx = p.model.model_trading_dates(i) == p.model.all_trading_dates;
          y = adj_rtn(idx,:)';
          y = y( ismember( p.model.stk_codes1,T_sector_today.Properties.RowNames));  % 今天cov 里面的股票

          ok_y = ~isnan(y);

          T_sector = T_sector_today;

          nan_sector = sum(table2array(T_sector),1)<=0;  %如果所有股票都不属于这个行业, 要剔除。

          % X = [1,行业因子，风格因子 ]，先求行业因子    
          % 计算基准在各个行业上的分布
          indexw  =  table2array(p.model.indexmemb(i,:))/100; % 基准当天的权重情况
     %     sum(indexw)
          
          u = zeros(S,1);
          for j = 1 :S
              % 计算基准在该天的行业分布情况
             for k = 1 : length( p.ind.lv2{j})
                 idx_s  = p.ind.lv2{j}{k}==sectors(idx,:);
                 u(j,1) = u(j,1) + sum(indexw(idx_s));
             end
          end
          clear j
        %  sum(u)
          u = u/sum(u);
          [~ ,id]  = max(u);       id_ = (id==1:S); 

          % 用流通市值最大的行业做分母： r_n = f_c + \sum_{i=1}^{I-1} (X_{ni} - \frac{\omega_i}{\omega_I} X_{nI})f_i  +... + \epsilon_n
          x0  = table2array(T_sector) - repmat(u'/u(id),size(T_sector,1),1).*repmat(table2array(T_sector(:,id)),1,size(T_sector,2));
          ok_x_col_sector = ~(nan_sector|id_);
          x0(:,~ok_x_col_sector) = NaN; 

          x = [ones(size(x0,1),1),x0(:,ok_x_col_sector)];

   
         w =  diag(ones(N,1));

          w_ = w(ok_y,ok_y);
          y_ = y(ok_y,:);
          x_ = x(ok_y,:);

          tbl = array2table([ mtimes(w_,y_),mtimes(w_,x_)],'RowNames',T_sector_today.Properties.RowNames(ok_y),...
                                'VariableNames', [{'y';'mkt'};T_sector.Properties.VariableNames(ok_x_col_sector)']);
          clear x y w x_ y_ w_ 
         % toc
         % tic
          mdl   = fitlm(tbl,'ResponseVar','y','Intercept',false);
        
          mkt(i,1) = mdl.Coefficients.Estimate(1);
          clear  T_sector_today T_sector_style T_stocks_cap_freecap_sector f f_r tbl exposures mdl mdl_r T_sector T_style;
    end
end