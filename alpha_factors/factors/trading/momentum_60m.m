function [] = momentum_60m(a,p)
% 近6个月return

%     D1 = 0;
%     D2 = 20*60; % 假设21交易日一个月
% 
%     % 后面基本都是cal_stk_rtn.m的代码
%     
%     T = length(p.all_trading_dates);
%     N = length(p.stk_codes);
%     tgt_tag  = 'momentum_60m'; % 这里改了下
%     tgt_file = [a.output_data_path,'/','momentum_60m.h5']; % 这里改了下
% 
%     [S,momentum_60m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
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
%                  Y     = adj_prices(i-D2:i,j);
%                  sus   = is_suspended(i-D2+1:i,j);
%                  y     = Y(2:end)./Y(1:end-1)-1;  
%                 % y(isnan(y))= 0;
%                  z = cumprod(1 + y);
%                  tao = sum(sus)/length(sus);%  停牌率
%                  if tao~=1
%                      momentum_60m(i,j) = z(D2-D1)-1;
%                  else
%                      momentum_60m(i,j) = NaN;  
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
    len = 120;
    factor = 'momentum_60m';
    key = 's_dq_pctchange';

    tgt_file = [a.output_data_path,'/momentum_60m.mat'];
    if exist(tgt_file,'file')==2
        momentum_60m = load(tgt_file);
        dt = momentum_60m.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end

    if dt_max<p.all_trading_dates(end)
        
        x = load([a.input_data_path,'/ashareeodprices.mat']);
        
        new = struct();
        new.data = x.data(x.data.DATEN > dt_max,:);        
        
        eval(['new.data.',factor,' = nan(height(new.data),1);']);
        new.data = new.data(:,{'stk_num','DATEN',key,factor});

        new.code_map = x.code_map;
        
        if bool
            result = factor_append(momentum_60m,new);
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

        data.momentum_60m = cumret(stk_num,DATEN,key,factor,all_dates,dt_max,len);
        code_map = result.code_map; %#ok<NASGU>
            
        
        save(tgt_file,'data','code_map');
        
    end


end


% 求均值
% key一类需要求均值的数据，为DATEN>dt_max的数据求均值，len是均值窗口长度
% factor是结论数据比如momentum_1m, amount_1m
% all_dates用来对齐不同股票代码的数据以防某些票的数据缺失
function x = cumret(stk_num,DATEN,key,factor,all_dates,dt_max,len)

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
            p = p(d>=start_dt);
            p(isnan(p)) = 0;
            x(r) = prod(1+p);            
        end
    end
    
end


