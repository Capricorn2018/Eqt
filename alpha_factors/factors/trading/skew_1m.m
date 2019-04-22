function [] = skew_1m(a,p)
% skew_1m 1个月日收益率skew
     
%     D = 20; % 假设20交易日
% 
%     % 后面基本都是cal_stk_rtn.m的代码
%     
%     T = length(p.all_trading_dates);
%     N = length(p.stk_codes);
%     tgt_tag  = 'skew_1m'; % 这里改了下
%     tgt_file = [a.output_data_path,'/','skew_1m.h5']; % 这里改了下
% 
%     [S,skew_1m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
% 
%     if S>0
% 
%        adj_prices   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')'; 
%        stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
%        is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
%        ipo_dates    = datenum_h5(h5read([a.input_data_path,'\fdata\base_data\securites_terms.h5'],'/ipo_date')); 
% 
%        is_suspended(isnan(stk_status)) = NaN;
%        is_suspended(is_suspended==1) = NaN;
%        is_suspended(isnan(is_suspended)) =1;
% 
%        for i = 1 : N
%            idx = find(p.all_trading_dates>=ipo_dates(i),1,'first');
%            adj_prices(idx:idx + 21,i)  = NaN; % first 1 month set to NaN
%        end
% 
%        adj_prices = adj_prices(1:T,:);  
%        adj_prices  = adj_table(adj_prices);
% 
%        for  i  = S  : T
%            for j = 1: N
%               if p.all_trading_dates(i)>ipo_dates(j)
%                  Y     = adj_prices(i-D:i,j);
%                  sus   = is_suspended(i-D+1:i,j);
%                  y     = Y(2:end)./Y(1:end-1)-1;  
%                 % y(isnan(y))= 0;
%                  y = y(sus==0);
%                  z = skewness(y);
%                  tao = sum(sus)/length(sus);%  停牌率
%                  if tao~=1
%                      skew_1m(i,j) = z;
%                  else
%                      skew_1m(i,j) = NaN;
%                  end
%               end
%            end
%        end
% 
% 
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',...
%                 tgt_tag, ''',','' tgt_tag, ');']);  
%     end


    % settings
    len = 20;
    factor = 'skew_1m';
    key = 's_dq_pctchange';

    tgt_file = [a.output_data_path,'/skew_1m.mat'];
    if exist(tgt_file,'file')==2
        skew_1m = load(tgt_file);
        dt = skew_1m.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end

    if dt_max<p.all_trading_dates(end)
        
        x = load('D:/Projects/pit_data/origin_data/ashareeodprices.mat');
        
        new = struct();
        new.data = x.data(x.data.DATEN > dt_max,:);        
        
        eval(['new.data.',factor,' = nan(height(new.data),1);']);
        new.data = new.data(:,{'stk_num','DATEN',key,factor});

        new.code_map = x.code_map;
        
        if bool
            result = factor_append(skew_1m,new);
        else
            result = new;
        end

        data = sortrows(result.data,{'stk_num','DATEN'},{'ascend','ascend'});

        all_dates = unique(data.DATEN);
        all_dates = sort(all_dates,'ascend');

        factor = eval(['data.',factor,';']);
        key = eval(['data.',key,';']);
        stk_num = data.stk_num;
        DATEN = data.DATEN;

        data.skew_1m = skew(stk_num,DATEN,key,factor,all_dates,dt_max,len);
        code_map = result.code_map; %#ok<NASGU>
            
        
        save(tgt_file,'data','code_map');
        
    end


end


% 求均值
% key一类需要求均值的数据，为DATEN>dt_max的数据求均值，len是均值窗口长度
% factor是结论数据比如momentum_1m, amount_1m
% all_dates用来对齐不同股票代码的数据以防某些票的数据缺失
function x = skew(stk_num,DATEN,key,factor,all_dates,dt_max,len)

    idx = find(DATEN > dt_max);
    x = factor;
    
    for i=1:length(idx)
        
        r = idx(i);
        
        if r<len
            x(r) = NaN;
            continue;
        end
        
        end_dt = DATEN(r);
        n = find(all_dates==end_dt);
        
        if n<len
            x(r)=NaN;
            continue;
        end
        
        start_dt = all_dates(n-len+1);        
        
        n = stk_num((r-len+1):r);
        p = key((r-len+1):r);
        d = DATEN((r-len+1):r);
        
        if(n(1)~=n(end))
            x(r) = NaN;
        else
            x(r) = skewness(p(d>=start_dt),'omitnan');            
        end
    end
    
end

