function Y = expand_single_value(X,d,p)
       
        T = length(p.all_trading_dates);
        Y  = NaN(T,size(X,2));
        
       for i  = 1 : length(d)
           [x1,x2] = get_dates_from_rpt(d(i));
           if ~isempty(x1)
                  d1 = find(p.all_trading_dates>=x1,1,'first');
                  d2 = find(p.all_trading_dates<=x2,1,'last');
                  if (~isempty(d1))&&(~isempty(d2))
                    %  if  d2>=d1
                         Y(d1:d2,:) = repmat(X(i,:),d2-d1+1,1);
                     % end
                  end
           end
       end
       
end