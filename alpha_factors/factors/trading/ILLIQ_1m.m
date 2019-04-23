function [] = ILLIQ_1m(a,p)
% ILLIQ_1m 一个月ILLIQ因子
%     
%     D = 20;
% 
%     T = length(p.all_trading_dates);
%     N = length(p.stk_codes);
%     tgt_tag  = 'ILLIQ_1m';  
%     tgt_file = [a.output_data_path,'/','ILLIQ_1m.h5'];
% 
%     [S,ILLIQ_1m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
% 
%     if S>0
% 
%        trading_amount   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/trading_amount')';
%        trading_amount(isnan(trading_amount)) = 0;
% 
%        stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
%        is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
% 
%        adj_prices   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/adj_prices')'; 
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
%                  P     = adj_prices(i-D:i,j);
%                  R     = P(2:end)./P(1:end-1)-1;
%                  A     = trading_amount(i-D+1:i,j);
%                  sus   = is_suspended(i-D+1:i,j);
%                  a     = A(sus==0);  
%                  r     = R(sus==0);
%                  c     = mean(abs(r)./a);
%                  tao = sum(sus)/length(sus);%  停牌率
%                  if tao~=1
%                      ILLIQ_1m(i,j) = c;
%                  else
%                      ILLIQ_1m(i,j) = NaN;
%                  end
%               end
%            end
%        end
% 
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end


    % settings
    len = 20;
    factor = 'ILLIQ_1m';
    key = 'pct_over_amount';
    col = {'s_dq_amount','s_dq_pctchange'};
    
    tgt_file = [a.output_data_path,'/ILLIQ_1m.mat'];
    if exist(tgt_file,'file')==2
        ILLIQ_1m = load(tgt_file);
        dt = ILLIQ_1m.data.DATEN;
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
        new.data = new.data(:,['stk_num','DATEN',col,factor]);

        new.code_map = x.code_map;
        
       %% 这里是需要根据因子本身修改的
        td = new.data(:,col);
        am = td.s_dq_amount;
        pct = td.s_dq_pctchange;
        
        deriv = nan(length(am),1);
        deriv(am~=0) = pct(am~=0)./am(am~=0); %#ok<NASGU>
        
        eval(['new.data.',key,'=deriv;']);
        new.data = new.data(:,{'stk_num','DATEN',key,factor});
        
       %%
        
        if bool
            result = factor_append(ILLIQ_1m,new);
        else
            result = new;
        end

        data = sortrows(result.data,{'stk_num','DATEN'},{'ascend','ascend'});
        
        all_dates = unique(data.DATEN);
        all_dates = sort(all_dates,'ascend');
        key = eval(['data.',key,';']);
        factor = eval(['data.',factor,';']);
        
       
        
       %%
        stk_num = data.stk_num;
        DATEN = data.DATEN;
        
        data.ILLIQ_1m = average(stk_num,DATEN,key,factor,all_dates,dt_max,len);
        code_map = result.code_map; %#ok<NASGU>
            
        
        save(tgt_file,'data','code_map');
        
    end

end


% 求均值
% key一类需要求均值的数据，为DATEN>dt_max的数据求均值，len是均值窗口长度
% factor是结论数据比如momentum_1m, amount_1m
% all_dates用来对齐不同股票代码的数据以防某些票的数据缺失
function x = average(stk_num,DATEN,key,factor,all_dates,dt_max,len)

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
            x(r) = nanmean(p(d>=start_dt));            
        end
    end
    
end

