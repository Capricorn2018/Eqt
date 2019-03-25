function [] = lottery_1m(a,p)
% 1个月内最大涨幅

    D1 = 0;
    D2 = 20; % 假设20交易日

    % 后面基本都是cal_stk_rtn.m的代码
    
    T = length(p.all_trading_dates);
    N = length(p.stk_codes);
    tgt_tag  = 'lottery_1m'; % 这里改了下
    tgt_file = [a.output_data_path,'/','lottery_1m.h5']; % 这里改了下

    [S,lottery_1m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);

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
                 Y     = adj_prices(i-D2:i,j);
                 sus   = is_suspended(i-D2+1:i,j);
                 [z,~] = max_interval(Y);
                 tao = sum(sus)/length(sus);%  停牌率
                 
                 if tao~=1
                     lottery_1m(i,j) = z;
                 else
                     lottery_1m(i,j) = NaN;   
                 end
              end
           end
       end


       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',...
                tgt_tag, ''',','' tgt_tag, ');']);  
    end

end


% 用递归方法计算时段内的区间最大涨幅
function [ret,m] = max_interval(prices)
% ret是价格序列中子区间的最大涨幅
% m是区间最小值

    if(length(prices)<2)
        disp('max_interval: length(prices)<2');
        return;
    end

    if(length(prices)==2)
        % 序列长度是2则直接返回
        ret = max(0,prices(2)/prices(1)-1);
        m = min(prices);
    else
        % 序列长度超过2用递归
        
        % 先降长度递归
        [ret1,m1] = max_interval(prices(1:end-1));
        
        % 最新的价格
        new = prices(end);
        
        % 比较price(1:end-1)区间的最大涨幅
        % 以及更新区间最小值
        ret = max(ret1,new/m1-1);
        m = min(m1,new);
    end

end
