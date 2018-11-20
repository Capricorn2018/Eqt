function  p = set_index(input_data_path)
 

    %% whole model-wise   
     p.model.all_trading_dates = datenum_h5 (h5read([input_data_path,'\base_data\securites_dates.h5'],'/date'));      T = length(p.model.all_trading_dates);
     p.model.stk_codes         = stk_code_h5(h5read([input_data_path,'\base_data\securites_dates.h5'],'/stk_code'));  N = length(p.model.stk_codes);
     
     x = [];
     for k = 1 : length(p.model.stk_codes)
        z = cell2mat(p.model.stk_codes(k));
        x = [x,cellstr(z([8:9,1:6]))];
     end
     p.model.stk_codes1 = x;
     
     p.model.start_date  = datenum(2005,01,01);
     p.model.model_trading_dates  = p.model.all_trading_dates(p.model.all_trading_dates>= p.model.start_date);
    %% file check
     p.file.stk  =      [input_data_path,'\base_data\stk_prices.h5'];              err_chk(p.file.stk,T,N);
     p.file.ind  =      [input_data_path,'\base_data\citics_stk_sectors_all.h5'];  err_chk(p.file.ind,T,N); % 中信行业分类  
     p.file.totalshrs = [input_data_path,'\base_data\capital.h5'];                 err_chk(p.file.totalshrs,T,N); % 总市值
     p.file.freeshrs  = [input_data_path,'\base_data\free_shares.h5'];             err_chk(p.file.freeshrs,T,N); % 自由流通市值
     p.file.status    = [input_data_path,'\base_data\stk_status.h5'];              err_chk(p.file.status,T,N);   % if(ST<>PT<>暂停上市<>该日期<该股票上市日<>该日期>该股票退市日,0,1)
     p.file.sus       = [input_data_path,'\base_data\suspended.h5'];               err_chk(p.file.sus,T,N);      % if(停盘，1,0）
     p.file.sector    = 'D:\Projects\Eqt\files\sector_table.csv';
     p.file.codes     = 'D:\Projects\Eqt\files\sector_codes.csv';

     %%
     p.freecap.quantile = 0;
     p.tradingamt.quantile = 0;
     p.lagdays = 42;
end

