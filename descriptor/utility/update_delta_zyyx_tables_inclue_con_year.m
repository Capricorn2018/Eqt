function X = update_delta_zyyx_tables_inclue_con_year(S,T,X,p,a,table_name,tagn)

    K0 =  p.K0;

    for i = S:T
       x0 = [a.input_data_path,'\DB\zyyx\daily\',table_name,'\',table_name,'_',datestr(p.all_trading_dates(i-K0),29),'.mat'];
       x  = [a.input_data_path,'\DB\zyyx\daily\',table_name,'\',table_name,'_',datestr(p.all_trading_dates(i),29),'.mat'];
       if  (exist(x,'file')==2)&& (exist(x0,'file')==2)
          load(x);
          if ~isempty(t)
              stks1 = t.STOCK_CODE;
              y1 = t.(upper(tagn));
              idx1  = t.CON_YEAR == year(datestr(p.all_trading_dates(i)));           
              stks1 = stks1(idx1);
              y1  = y1(idx1);       
              clear t
          else
              continue;
          end  
          
          load(x0);
          if ~isempty(t)
              stks0 = t.STOCK_CODE;
              y0 = t.(upper(tagn));
              idx0  = t.CON_YEAR == year(datestr(p.all_trading_dates(i)));           
              stks0 = stks0(idx0);
              y0  = y0(idx0);       
              clear t
           else
              continue;
          end  
          
           [stks,la,lb] = intersect(stks0,stks1); 
           y = y1(lb) - y0(la);
           idx  = ~isnan(y);
           stks = stks(idx);
           y  = y(idx);
          
           [~,ia,ib] = intersect(get_stk_num(p.stk_codes),stks);
           X(i,ia) = y(ib);
       end      
    end

end