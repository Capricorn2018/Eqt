% T: 总交易日数
% N: 总股票个数
% p: struct, 储存parameters
% S：需要更新的首个交易日数据再p.all_trading_dates中的下标
% X：更新前的数据

function [S,X] =  check_exist(tgt_file,tgt_tag,p,T,N)

       S = 0;
       X = [];

       % exist_flag: 0,即所有日期都找不到文件需要全部更新; 1,即有些需要更新
       % loc_stk: 不需要更新的票标注下标，需要更新的那些票为0
       % loc_dt: 不需要更新的日期标注下标，需要更新的交易日为0
       [idx_stk,loc_stk,idx_dt,loc_dt,exist_flag] = check_exist_h5(tgt_file,p);
       
       % 如果对应文件都存在则不需要更新
       if all(idx_stk)&&all(idx_dt)  
           return;
       end
       
       X = NaN(T,N);
       
       if exist_flag==0 % 当所有交易日都需要更新时      
           S = find(p.all_trading_dates>=datenum(2005,1,1),1,'first');
       elseif exist_flag==1 % 当有一些交易日需要更新时
           X(idx_dt,idx_stk) = h5read(tgt_file,tgt_tag);
           S = find(loc_dt==0,1,'first'); % 找到需要更新的第一个交易日的下标
       end
       
end