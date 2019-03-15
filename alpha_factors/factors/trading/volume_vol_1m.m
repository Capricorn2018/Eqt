function [] = volume_vol_1m(a,p)
% volume_vol_1m 过去一个月成交量标准差 / 日均成交量

    D = 20;

    T = length(p.all_trading_dates);
    N = length(p.stk_codes);
    tgt_tag  = 'volume_vol_1m';  
    tgt_file = [a.output_data_path,'/','volume_vol_1m.h5'];

    [S,volume_vol_1m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);

    if S>0

       trading_volume   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/trading_volume')'; 
       trading_volume(isnan(trading_volume)) = 0;

       stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
       is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
       ipo_dates    = datenum_h5(h5read([a.input_data_path,'\fdata\base_data\securites_terms.h5'],'/ipo_date')); 

       is_suspended(isnan(stk_status)) = NaN;
       is_suspended(is_suspended==1) = NaN;
       is_suspended(isnan(is_suspended)) =1;

       for  i  = S  : T
           for j = 1: N
              if p.all_trading_dates(i)>ipo_dates(j)
                 V = trading_volume(i-D+1:i,j);
                 sus = is_suspended(i-D+1:i,j);
                 v = V1(sus==0);
                 c = std(v)/mean(v);
                 tao = sum(sus)/length(sus); % 一个月内的停牌率
                 if tao~=1
                     volume_vol_1m(i,j) = c;
                 else
                     volume_vol_1m(i,j) = NaN; % 若一年内都停牌则NaN
                 end
              end
           end
       end

       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

