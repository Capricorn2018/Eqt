% 计算个股在指定交易日范围内的high/low比率
% p: sturct, 储存parameters
% a: struct, 储存读写数据文件地址
% D：int, 计算high/low向前回溯的交易日个数
% if_mix：bool, true即用行业平均加权避免缺失过多

function  cal_stk_hl(p,a,D,if_mix)
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
  
   tgt_tag1  = 'hl';  
   tgt_file1 = [a.output_data_path,'\','hl_',num2str(D),'-',num2str(if_mix),'.h5'];
   
   % 检查目标文件, 返回需要第一个需要更新的日期对应的下标S, 和更新前的数据hl
   [S,hl] =  check_exist(tgt_file1,['/',tgt_tag1],p,T,N);
   
   if S>0      
       if if_mix
          vi = sector_hl(a,D,S,T,hl);
       end
       
       adj_prices   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')'; 
       stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
       is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
       ipo_dates    = datenum_h5(h5read([a.input_data_path,'\fdata\base_data\securites_terms.h5'],'/ipo_date')); 

       is_suspended(isnan(stk_status)) = NaN;
       is_suspended(is_suspended==1) = NaN;
       is_suspended(isnan(is_suspended)) =1;

       for i = 1 : N
           idx = find(p.all_trading_dates>=ipo_dates(i),1,'first');
           adj_prices(idx:idx + 21,i)  = NaN; % IPO之后21个交易日价格不计, 设为NaN
       end
       
       adj_prices = adj_prices(1:T,:);  
       adj_prices  = adj_table(adj_prices);
       
       % 对于需要更新的日期下标S:T, 进行逐日更新
       for  i  = S  : T
           for j = 1: N  % 逐个股票更新
              if p.all_trading_dates(i)>ipo_dates(j)
                 Y     = adj_prices(i-D:i,j);
                 sus   = is_suspended(i-D+1:i,j);
                 y     =  Y(2:end)./Y(1:end-1)-1;  
                 %  y(isnan(y)) = 0;
                 hl_ = cumprod(1+y);
                 hls = max(hl_)/min(hl_)-1;
                 tao = sum(sus)/length(sus); % 个股停牌率
                 if tao~=1
                     if if_mix
                         % 当停牌率过高时按大比例偏到行业平均的high/low, 所以这里停牌率tao取立方
                         hl(i,j) = (1-tao*tao*tao)*hls + tao*tao*tao*vi(i,j);
                     else
                         hl(i,j) = hls;
                     end   
                 else
                     if if_mix
                         hl(i,j) = vi(i,j);
                     else
                         hl(i,j) = NaN;
                     end   
                 end
              end
           end
       end
       % 写文件, 变量名是tgt_tag1
       eval(['hdf5write(tgt_file1, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,''',tgt_tag1, ''',',tgt_tag1, ');']);   
   end
     
end