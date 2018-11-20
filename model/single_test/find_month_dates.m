% 寻找每个月的第num个交易日, 或倒数第num个交易日
% num: 整数, 寻找的交易日对应的序数
% trading_dates: 格式是datenum, 是一列交易日
% direction: 若不传入此参数则默认为'first'
%            'first'即从每个月最初寻找第num个交易日
%            'last'即从每个月最末寻找倒数第num个交易日

function  [dates, dates_idx] = find_month_dates( num, trading_dates, direction)

    % 若不传入第三个参数direction, 则默认为'first'
    % 即寻找每个月第num个交易日
    if(nargin<3)
        direction='first';
    end

    % 先把日期排序以方便后续分组
    dates_num = sort(trading_dates);
    
    % 转换成char并取年和月, 如 yr_mth = '199012'
    dates_str = datestr(dates_num,'yyyymmdd');
    yr_mth = dates_str(:,1:6);
    
    % 把年月转换成double以方便转table
    yr_mth = str2num(yr_mth); %#ok<ST2NM>
    
    % 把年月数字和年月日对应datenum存入table
    ds = [array2table(yr_mth),array2table(dates_num)];
    
    % 用grpstats按照同年同月为一组, 每个月取需要的那一个交易日
    func = @(x) grp_indexing(x,num,direction);
    ds = grpstats(ds,'yr_mth',func);   
    
    % 返回赋值
    dates = ds.Fun1_dates_num;
    
    idx = zeros(length(dates,1);
    for i = 1:length(dates)
       idx(i) = find(trading_dates == dates(i),1,'first');
    end
    
    %dates = dates(~isnan(rebalance_dates));

end

% direction=='first': 寻找x的第num个元素
% direction=='last': 寻找x的倒数第num个元素
function y=grp_indexing(x,num,direction)
        

    if(strcmp(direction,'first'))
        if(length(x)>=num)
            y=x(num); % 第num个元素
        else
            y=NaN;
        end
    elseif(strcmp(direction,'last'))
        if(legnth(x)>=num)
            y=x(legnth(x)-num+1); % 倒数第num个元素
        else
            y=NaN;
        end
    else
        % 如果direction传的不对则报错
        disp('Error: wrong direction in find_month_dates.m');
        return;
    end
    
end

