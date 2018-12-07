function X = update_zyyx_tables(S,T,X,p,a,table_name,tagn)


      for i = S:T
           x = [a.input_data_path,'\DB\zyyx\daily\',table_name,'\',table_name,'_',datestr(p.all_trading_dates(i),29),'.mat'];
           if  exist(x,'file')==2
              load(x);
              stks = t.STOCK_CODE;
              y = t.(upper(tagn));
              [~,ia,ib] = intersect(get_stk_num(p.stk_codes),stks);
              X(i,ia) = y(ib);
           end      
      end

end 