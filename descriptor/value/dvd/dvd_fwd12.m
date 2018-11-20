function  dvd_fwd12(p,a)


    sql = ['SELECT t.s_info_windcode, t.est_dt ,t.EST_DPS FROM wind.AShareConsensusRollingData t',...
           ' WHERE t.est_dt >= ','''','20050101','''',...
           ' AND t. rolling_type= ','''','FY1',''''];
    t  = q_table(p.conn_wind,sql);
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);
    [dvd,dvd_f] = deal(zeros(T,N));


    t(isnan(t.EST_DPS),:)= [];
    
    x = unique(t.EST_DT);

    for i = 1 : length(x)

        x0_ = x{i};   
        x0  = datenum(str2double(x0_(1:4)),str2double(x0_(5:6)),str2double(x0_(7:8)));

        idx_d = strcmp(t.EST_DT,x(i));

        stk_today  = t.S_INFO_WINDCODE(idx_d);
        div_today  = t.EST_DPS(idx_d);

        idx_stk_today   = ismember(stk_today,p.stk_codes);   
        stk_today = stk_today(idx_stk_today);
        div_today = div_today(idx_stk_today);

        idx_today = p.all_trading_dates == x0;

        if  any(idx_today)    
            idx_stk   = ismember(p.stk_codes,stk_today);           
            dvd(idx_today,idx_stk) = div_today;
        end
    end


     close_prices = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/close_prices')';
     dvd_f = dvd./close_prices;
     dvd_f(isnan(dvd_f)) = 0;

     hdf5write([a.output_data_path,'\dvd_fwd12.h5'], 'date',p.all_trading_dates_, 'stk_code',p.stk_codes_, 'dvd_fwd12',dvd_f);  

end