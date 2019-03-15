function [] = vol_1y(a,p)
% vol_1y 一年的日收益标准差
     
    D = 20; % 假设20交易日

    % 后面基本都是cal_stk_rtn.m的代码
    
    T = length(p.all_trading_dates);
    N = length(p.stk_codes);
    tgt_tag  = 'skew_1m'; % 这里改了下
    tgt_file = [a.output_data_path,'/','skew_1m.h5']; % 这里改了下

    [S,skew_1m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);

    if S>0

       adj_prices   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')'; 
       stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
       is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
       ipo_dates    = datenum_h5(h5read([a.input_data_path,'\fdata\base_data\securites_terms.h5'],'/ipo_date')); 

       is_suspended(isnan(stk_status)) = NaN;
       is_suspended(is_suspended==1) = NaN;
       is_suspended(isnan(is_suspended)) =1;

       for i = 1 : N
           idx = find(p.all_trading_dates>=ipo_dates(i),1,'first');
           adj_prices(idx:idx + 21,i)  = NaN; % first 1 month set to NaN
       end

       adj_prices = adj_prices(1:T,:);  
       adj_prices  = adj_table(adj_prices);

       for  i  = S  : T
           for j = 1: N
              if p.all_trading_dates(i)>ipo_dates(j)
                 Y     = adj_prices(i-D:i,j);
                 sus   = is_suspended(i-D+1:i,j);
                 y     = Y(2:end)./Y(1:end-1)-1;  
                % y(isnan(y))= 0;
                 y = y(sus==0);
                 z = std(y);
                 tao = sum(sus)/length(sus);%  停牌率
                 if tao~=1
                     skew_1m(i,j) = z;
                 else
                     skew_1m(i,j) = NaN;
                 end
              end
           end
       end


       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',...
                tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

