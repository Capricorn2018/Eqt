function [index_self,index_membs,num_of_stks_index,alpha_factors]= build_base_index(input_data_path)

     p = set_index(input_data_path);
     T = length(p.model.model_trading_dates);
     T0 = length(p.model.all_trading_dates);
     
     sec_codes_lv3  = h5read(p.file.ind,'/citics_stk_sectors_3')';
     
    % data_mktcap     = h5read(p.file.totalshrs,   '/total_capital')'/1e4;  % #dates by #stocks
     data_freecap    = h5read(p.file.freeshrs,    '/free_cap')'/1e4;       % #dates by #stocks  自由流通市值
     data_freecap(data_freecap==0) = NaN;   
     
     data_tradingamt = h5read(p.file.stk,         '/trading_amount')'/1e4;  % #dates by #stocks 
     data_tradingamt(data_tradingamt==0) = NaN;   
     
     free_shr     = h5read(p.file.freeshrs,  '/free_shares')';
     free_shr(free_shr==0) = NaN;   
     
     total_shr    = h5read(p.file.totalshrs, '/total_shares')';
     total_shr(total_shr==0) = NaN;   
     
     data_satus      =  h5read(p.file.status,'/stk_status')';          % if(ST<>PT<>暂停上市<>该日期<该股票上市日<>该日期>该股票退市日,0,1)
     data_satus(isnan(data_satus)) = 0;
     data_satus = logical(data_satus);
          
     close_prices  = h5read(p.file.stk,         '/close_prices')';  % #dates by #stocks 
     adj_pirces    =  h5read(p.file.stk,         '/adj_prices')';  % #dates by #stocks 
     adj_rtn       = [nan(1,size(adj_pirces,2));adj_pirces(2:end,:)./adj_pirces(1:end-1,:)-1];
     adj_rtn(adj_rtn>0.105) = 0;
     adj_rtn(adj_rtn<-0.105) = 0;
     adj_rtn(isnan(adj_rtn)) = 0;
          
     data_sus        =  h5read(p.file.sus,'/is_suspended')';           % if(停盘，1,0）
     data_sus(isnan(data_sus)) = 0;
     data_sus = logical(data_sus);
     %data_satus   = logical(data_satus.*(1-data_sus));  
     
    [ self,membs,numb,dates]  = sim_index(total_shr,data_satus,p,T0,T,data_freecap,data_tradingamt,free_shr,close_prices,adj_rtn,sec_codes_lv3);
     
      x = readtable(p.file.sector);
      y = readtable(p.file.codes);
      index_membs.index0 = membs;
      
      alpha_factors  = sort(unique(x.Var1));
      self_  = zeros(size(self,1),length(alpha_factors));
      numb_  = zeros(size(self,1),length(alpha_factors));    
          
      for i  = 1 : length(alpha_factors)
         idx  = ismember(x.Var1,alpha_factors(i));
         l3codes = table2array(y(idx,:)); 
         l3codes = l3codes(:);
         l3codes(isnan(l3codes)) = [];
          [ selft,membst,numbt,datest]= sim_sec_index(sec_codes_lv3,l3codes,total_shr,data_satus,...
                  p,T0,T,data_freecap,data_tradingamt,free_shr,close_prices,adj_rtn);
          self_(:,i) = selft;
          numb_(:,i) = numbt;
          index_membs.(['index',num2str(i)]) = membst;
      end
      
      vnames  = cellstr(strcat('index',num2str((0:length(alpha_factors))')))';
      index_self = array2table([self,self_],'RowNames',cellstr(datestr(dates,29)),'VariableNames',vnames);
      num_of_stks_index = array2table([numb,numb_],'RowNames',cellstr(datestr(dates,29)),'VariableNames',vnames);
end