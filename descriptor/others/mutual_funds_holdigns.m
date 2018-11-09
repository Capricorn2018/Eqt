function mutual_funds_holdigns(p,a)
     T = length(p.all_trading_dates );
     N = length(p.stk_codes); 
     tgt_file = [a.output_data_path,'\mutual_funds_holdings.h5'];
     hdings =  h5read( [a.input_data_path,'\DB\wind\holdings.h5'],'/holdings')'/10000;
     
     free_shrs  = h5read( [a.input_data_path,'\fdata\base_data\free_shares.h5'],'/free_shares')'*10000;
     
     rpt_dates = datenum_h5(h5read( [a.input_data_path,'\DB\wind\holdings.h5'],'/rpt_dates'));
     stks = h5read( [a.input_data_path,'\DB\wind\holdings.h5'],'/stk_code');
     for i  = 1 : length(stks)
         x = stks{i,1};
         stks{i,1} = deblank(x);
     end  
     [~,ia,ib] = intersect(p.stk_codes_,stks);
    % stks = stks(ib);
     
     
     
     holdings = NaN(T,N);
     
     for i = 1 : size(hdings,1)
           [x1,x2] = get_dates_from_holdigs(rpt_dates(i));
           if ~isempty(x1)
                  d1 = find(p.all_trading_dates>=x1,1,'first');
                  d2 = find(p.all_trading_dates<=x2,1,'last');
                  if (~isempty(d1))&&(~isempty(d2))
                      if  d2>=d1
                         x = hdings(i,ib)./free_shrs(d1-1,ia);
                         holdings(d1:d2,ia) = repmat(x,d2-d1+1,1);
                      end
                  end
           end
     end
      hdf5write(tgt_file, 'date',p.all_trading_dates_, 'stk_code',p.stk_codes_, 'holdings',holdings);   
   
end