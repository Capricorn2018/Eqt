function  dvd_his(p,a)

    load ([a.input_data_path ,'\DB\wind\ybl\his_dvd.mat']);
     

    T = length(p.all_trading_dates);
    N = length(p.stk_codes);
    [dvd,dvd_c] =deal(zeros(T,N));

    for i  = 1 : N
        t_info_this_stk = t(strcmp(t.S_INFO_WINDCODE,p.stk_codes(i)),:);
        x  = t_info_this_stk.eqy_record_dt;
        y  = t_info_this_stk.CASH_DVD_PER_SH_AFTER_TAX;
        z  = t_info_this_stk.S_DIV_BASESHARE;

        if ~isempty(x)
            for j = 1 : size(x,1)
                d1 = x(j);
                d2 = addtodate( x(j),1,'year');
                idx = p.all_trading_dates>=d1&p.all_trading_dates<=d2;
                dvd(idx,i) = dvd(idx,i) + y(j)*z(j);
            end
        end
    end

    total_capital = h5read([a.input_data_path,'\fdata\base_data\capital.h5'],'/total_capital')';
    dvd_c = dvd./total_capital;
    dvd_c(isnan(dvd_c)) = 0;

    hdf5write([a.output_data_path,'\dvd_his.h5'], 'date',p.all_trading_dates_, 'stk_code',p.stk_codes_, 'dvd_his',dvd_c);  

end