function mkt = r3_reg1(p,a)
    
     N = length(p.model.stk_codes);
     T = length(p.model.model_trading_dates);
     S = length(p.ind.lv2);
     M = length(p.style);

     % 考虑模型  W^1/2 r  =   W^1/2 1_n f  + W^1/2 u , 该模型的参数估计f应该是 记住指数的日收益率
     
%%

    adj_price     = h5read(p.file.stk,'/adj_prices')';   % T by N
    adj_rtn       = [nan(1,size(adj_price,2));adj_price(2:end,:)./adj_price(1:end-1,:)-1];
    %adj_rtn(adj_rtn>0.105) = 0;
    %adj_rtn(adj_rtn<-0.105) = 0;
    %adj_rtn(isnan(adj_rtn)) = 0;

    mkt  = zeros(T,4);

    idx = find(p.model.model_trading_dates(1) == p.model.all_trading_dates);

    idx_index_dates = find(datenum(p.model.indexmemb.Properties.RowNames)== p.model.model_trading_dates(1));
    
    
    for i = 1 : T
          %disp(i)

          load([a.sector,'\',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_today','T_stocks_cap_freecap_sector');
  
          % y = Xf +e  这里先算出 y
        % -------for debug use  
        % idx = find(p.model.model_trading_dates(i) == p.model.all_trading_dates);
        %idx_index_dates = find(datenum(p.model.indexmemb.Properties.RowNames)== p.model.model_trading_dates(i));
        %----------- 

          idx_stk = ismember( p.model.stk_codes1,T_sector_today.Properties.RowNames);
          
          index_w  = table2array(p.model.indexmemb(idx_index_dates,idx_stk))';
          model_w  = T_stocks_cap_freecap_sector.free_cap/sum(T_stocks_cap_freecap_sector.free_cap)*100;
          
       %   comp = [index_w,model_w];
          mkt(i,2) = sum(index_w==0);
          mkt(i,3) = sum(model_w==0);
          
          
          y = adj_rtn(idx,:)';
          y = y(idx_stk); 
          x = ones(size(y,1),1);
          w =  diag(sqrt(T_stocks_cap_freecap_sector.free_cap*1e10));


          ok_y = ~isnan(y);

          w_ = w(ok_y,ok_y);
          y_ = y(ok_y,:);
          x_ = x(ok_y,:);

          tbl = array2table([ mtimes(w_,y_),mtimes(w_,x_)],'RowNames',T_sector_today.Properties.RowNames(ok_y),...
                                'VariableNames', {'y';'mkt'});
         % clear x y w x_ y_ w_ 
   
          mdl   = fitlm(tbl,'ResponseVar','y','Intercept',false);
        
          mkt(i,1) = mdl.Coefficients.Estimate(1);
          mkt(i,4) = sum(y.*T_stocks_cap_freecap_sector.free_cap/sum(T_stocks_cap_freecap_sector.free_cap));
          
          
          if  i<T,idx = idx+1;end
          if  i<T,idx_index_dates = idx_index_dates+1;end
          clear  T_sector_today T_sector_style T_stocks_cap_freecap_sector f f_r tbl exposures mdl mdl_r T_sector T_style;
    end
end