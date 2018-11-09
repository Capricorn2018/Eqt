function    [index_self,index_membs,num_of_stks_index,index_dates]= sim_index(total_shr,data_satus,p,T0,T,data_freecap,data_tradingamt,free_shr,close_prices,adj_rtn,sec_codes_lv3)

    
     index_memb = zeros(size(data_satus));

     
     index_lev =  repmat(1000,T0,1);
     index_rtn = zeros(T0,1);
     
      idx = find(p.model.model_trading_dates(1) == p.model.all_trading_dates);
%%      
    for i = 1 : T

        idx_stk    = data_satus(idx,:) == 1; 
       
        k1 = quantile(data_freecap(idx,~isnan(data_freecap(idx,:))),p.freecap.quantile);
        idx_stk(data_freecap(idx,:)<k1) = false;
        
       
        
        k = nanmean(data_tradingamt(idx-p.lagdays:idx-1,:));
        k2 = quantile(data_tradingamt(idx,~isnan(k)),p.tradingamt.quantile);   
        idx_stk(data_tradingamt(idx,:)<k2) = false;
        
        
        
         idx_stk( isnan(sec_codes_lv3(idx,:))) = 0;
        
         free_shr_pct   = free_shr(idx,idx_stk)./total_shr(idx,idx_stk);    % 自由流通比例
         free_shr_wtd   = zeros(1,size(free_shr_pct,2));  %加权比例
        
         for j = 1 : size(free_shr_wtd,2)
             free_shr_wtd(1,j) = get_free_ratio(free_shr_pct(1,j));
         end
         
         free_shr_i   = free_shr_wtd.*total_shr(idx,idx_stk);  %加权股本
         mkt_value_i  = free_shr_i.*close_prices(idx,idx_stk);  %市值
         mkt_value_pct_i  = mkt_value_i/sum(mkt_value_i);% 这里是自建权重 end of day
         
         index_memb(idx,idx_stk) = mkt_value_pct_i*100;
        
         if i<T
             %daily_rtn = mkt_value_pct_i.* (adj_pirces(idx+1,idx_stk)./adj_pirces(idx,idx_stk)-1);
             daily_rtn = mkt_value_pct_i.* adj_rtn(idx+1,idx_stk) ;
             index_rtn(idx+1,1) = sum(daily_rtn);
             index_lev(idx+1,1) = index_lev(idx,1) *(1+ sum(daily_rtn));
             idx = idx+1;
         end

    end
    
    %index_self    = array2table(index_lev,   'RowNames',cellstr(datestr(p.model.all_trading_dates,29)),   'VariableNames',{'Index'});
    index_dates   =  p.model.all_trading_dates(p.model.all_trading_dates>=p.model.model_trading_dates(1),:);
    index_self    =  index_lev(p.model.all_trading_dates>=p.model.model_trading_dates(1),:);
    

    index_membs    =  array2table(index_memb,   'RowNames',cellstr(datestr(p.model.all_trading_dates,29)),   'VariableNames', p.model.stk_codes1);
    index_membs    =  index_membs(datenum(index_membs.Properties.RowNames)>=p.model.model_trading_dates(1),:);
    
    numofstks_index =  sum(index_memb>0,2);
    num_of_stks_index   = numofstks_index(p.model.all_trading_dates>=p.model.model_trading_dates(1),:);
  %  num_of_stks_index    = array2table(numofstks_index(:,2),   'RowNames',cellstr(datestr(p.model.all_trading_dates,29)),   'VariableNames', {'num_of_stks'});
  %  num_of_stks_index    =  num_of_stks_index(datenum(num_of_stks_index.Properties.RowNames)>=p.model.model_trading_dates(1),:);
end