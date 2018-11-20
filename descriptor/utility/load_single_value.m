function X = load_single_value(S,T,N,p,value,tags,tagn,tagr)
       X = NaN(T,N);

       s_codes =  h5read(value,tags);
       s_numbs =  h5read(value,tagn);
       s_rpts  =  datenum_h5(h5read(value,tagr));
       
       for  i  = 1 : length(s_codes)
           s_codes{i,1} = deblank(s_codes{i,1});
       end
       [~,ia,ib]  = intersect(p.stk_codes_,s_codes); 
       
       for i  = 1 : length(s_rpts)
           [x1,x2] = get_dates_from_rpt(s_rpts(i));
           if ~isempty(x1)
                  d1 = max(find(p.all_trading_dates>=x1,1,'first'),S);
                  d2 = find(p.all_trading_dates<=x2,1,'last');
                  if (~isempty(d1))&&(~isempty(d2))
                      if  d2>=d1
                         X(d1:d2,ia') = repmat(s_numbs(ib',i)',d2-d1+1,1);
                      end
                  end
           end
       end
       

end