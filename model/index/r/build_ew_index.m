function [index_self,index_membs,a] = build_ew_index(project_path,input_data_path,output_data_path)

     [p,a] = set_index(project_path,input_data_path,output_data_path);
     T = length(p.model.model_trading_dates);
     T0 = length(p.model.all_trading_dates);
     
    % data_mktcap     = h5read(p.file.totalshrs,   '/total_capital')'/1e4;  % #dates by #stocks
    data_freecap    = h5read(p.file.freeshrs,    '/free_cap')'/1e4;       % #dates by #stocks  自由流通市值
%      data_freecap(data_freecap==0) = NaN;   
%      
     data_tradingamt = h5read(p.file.stk,         '/trading_amount')'/1e4;  % #dates by #stocks 
     data_tradingamt(data_tradingamt==0) = NaN;   
     
%      free_shr     = h5read(p.file.freeshrs,  '/free_shares')';
%      free_shr(free_shr==0) = NaN;   
%      
%      total_shr    = h5read(p.file.totalshrs, '/total_shares')';
%      total_shr(total_shr==0) = NaN;   
     
     data_satus      =  h5read(p.file.status,'/stk_status')';          % if(ST<>PT<>暂停上市<>该日期<该股票上市日<>该日期>该股票退市日,0,1)
     data_satus(isnan(data_satus)) = 0;
     data_satus = logical(data_satus);
     
     
%     close_prices  = h5read(p.file.stk,         '/close_prices')';  % #dates by #stocks 
     adj_pirces    =  h5read(p.file.stk,         '/adj_prices')';  % #dates by #stocks 
     
%      data_sus        =  h5read(p.file.sus,'/is_suspended')';           % if(停盘，1,0）
%      data_sus(isnan(data_sus)) = 0;
%      data_sus = logical(data_sus);
%     
     index_memb = zeros(size(data_satus));
     
     index_lev =  repmat(1000,T0,1);
     index_rtn = zeros(T0,1);
%%      
    for i = 1 : T
        idx = p.model.model_trading_dates(i) == p.model.all_trading_dates;
       % idx_stk    = (data_satus(idx,:) == 1)&(data_sus(idx,:)==0);
        idx_stk    = data_satus(idx,:) == 1; 
       
        k1 = quantile(data_freecap(idx,~isnan(data_freecap(idx,:))),p.freecap.quantile);
        idx_stk(data_freecap(idx,:)<k1) = false;
        

        k = nanmean(data_tradingamt(find(idx)-p.lagdays:find(idx)-1,:));
        k2 = quantile(data_tradingamt(idx,~isnan(k)),p.tradingamt.quantile);   
        idx_stk(data_tradingamt(idx,:)<k2) = false;
   %     index_memb(idx,:) = idx_stk;
        
%          free_shr_pct   = free_shr(idx,idx_stk)./total_shr(idx,idx_stk);    % 自由流通比例
%          free_shr_wtd   = zeros(1,size(free_shr_pct,2));  %加权比例
%         
%          for j = 1 : size(free_shr_wtd,2)
%              free_shr_wtd(1,j) = get_free_ratio(free_shr_pct(1,j));
%          end
%          
%          free_shr_i   = free_shr_wtd.*total_shr(idx,idx_stk);  %加权股本
%          mkt_value_i  = free_shr_i.*close_prices(idx,idx_stk);  %市值
         mkt_value_pct_i  = 1/sum(idx_stk);% 这里是自建权重
         
         index_memb(idx,idx_stk) = mkt_value_pct_i*100;
        
         if i<T
             daily_rtn = mkt_value_pct_i.* (adj_pirces(find(idx)+1,idx_stk)./adj_pirces(idx,idx_stk)-1);
             index_rtn(find(idx)+1,1) = nansum(daily_rtn);
             index_lev(find(idx)+1,1) = index_lev(idx,1) *(1+ nansum(daily_rtn));
         end
         clear k1 k k2 idx_stk
           
    end
    
    index_self    = array2table(index_lev,   'RowNames',cellstr(datestr(p.model.all_trading_dates,29)),   'VariableNames',{'Index'});
    index_self    =  index_self(datenum(index_self.Properties.RowNames)>=p.model.model_trading_dates(1),:);
    

    index_membs    = array2table(index_memb,   'RowNames',cellstr(datestr(p.model.all_trading_dates,29)),   'VariableNames', p.model.stk_codes1);
    index_membs    =  index_membs(datenum(index_membs.Properties.RowNames)>=p.model.model_trading_dates(1),:);
    
end