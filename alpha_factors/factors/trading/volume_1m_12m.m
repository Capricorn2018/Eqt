function [] = volume_1m_12m(a,p)
% volume_1m_12m 1个月日均交易量/12个月日均交易量 
  % 1个月日均成交额

    D1 = 20;
    D2 = 240;
   
    T = length(p.all_trading_dates);
    N = length(p.stk_codes);
    tgt_tag  = 'volume_1m_12m';  
    tgt_file = [a.output_data_path,'/','volume_1m_12m.h5'];

    [S,volume_1m_12m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);

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
                 V1 = trading_volume(i-D1+1:i,j);
                 V2 = trading_volume(i-D2+1:i,j);
                 sus1 = is_suspended(i-D1+1:i,j);
                 sus2 = is_suspended(i-D2+1:i,j);
                 v1 = V1(sus1==0);
                 v2 = V2(sus2==0);
                 c = mean(v1)/mean(v2);
                 tao1 = sum(sus1)/length(sus1); % 一个月内的停牌率
                 tao2 = sum(sus2)/length(sus2); % 一年内的停牌率
                 if tao2~=1
                     if tao1~=1
                        volume_1m_12m(i,j) = c; 
                     else
                         volume_1m_12m(i,j) = NaN;
                     end
                 else
                     volume_1m_12m(i,j) = NaN; % 若一年内都停牌则NaN
                 end
              end
           end
       end

       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end


end

