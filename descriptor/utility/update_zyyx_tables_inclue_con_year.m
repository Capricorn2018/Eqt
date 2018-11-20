function X = update_zyyx_tables_inclue_con_year(S,T,X,p,a,table_name,tagn)

    for i = S:T
       x = [a.input_data_path,'\DB\zyyx\daily\',table_name,'\',table_name,'_',datestr(p.all_trading_dates(i),29),'.mat'];
       if  exist(x,'file')==2
          load(x);
          stks = t.STOCK_CODE;
          y = t.(upper(tagn));
          if month(datestr(p.all_trading_dates(i)))<5
             idx  = t.CON_YEAR == year(datestr(p.all_trading_dates(i))) -1;           
          else
             idx  = t.CON_YEAR == year(datestr(p.all_trading_dates(i)));           
          end
          stks = stks(idx);
          y  = y(idx);       
          clear t
          [~,ia,ib] = intersect(get_stk_num(p.stk_codes),stks);
          X(i,ia) = y(ib);
       end      
    end

end