function [] = volume_1m_60m_12m(a,p)
% volume_1m_60m_12m 1个月日均交易量/12个月日均交易量 
  % 1个月日均成交额

%     D1 = 20;
%     D2 = 240;
%    
%     T = length(p.all_trading_dates);
%     N = length(p.stk_codes);
%     tgt_tag  = 'volume_1m_60m_12m';  
%     tgt_file = [a.output_data_path,'/','volume_1m_60m_12m.h5'];
% 
%     [S,volume_1m_60m_12m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
% 
%     if S>0
% 
%        trading_volume   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/trading_volume')'; 
%        trading_volume(isnan(trading_volume)) = 0;
% 
%        stk_status   = h5read([a.input_data_path,'\fdata\base_data\stk_status.h5'],'/stk_status')'; 
%        is_suspended = double(h5read([a.input_data_path,'\fdata\base_data\suspended.h5'],'/is_suspended')');
%        ipo_dates    = datenum_h5(h5read([a.input_data_path,'\fdata\base_data\securites_terms.h5'],'/ipo_date')); 
% 
%        is_suspended(isnan(stk_status)) = NaN;
%        is_suspended(is_suspended==1) = NaN;
%        is_suspended(isnan(is_suspended)) =1;
% 
%        for  i  = S  : T
%            for j = 1: N
%               if p.all_trading_dates(i)>ipo_dates(j)
%                  V1 = trading_volume(i-D1+1:i,j);
%                  V2 = trading_volume(i-D2+1:i,j);
%                  sus1 = is_suspended(i-D1+1:i,j);
%                  sus2 = is_suspended(i-D2+1:i,j);
%                  v1 = V1(sus1==0);
%                  v2 = V2(sus2==0);
%                  c = mean(v1)/mean(v2);
%                  tao1 = sum(sus1)/length(sus1); % 一个月内的停牌率
%                  tao2 = sum(sus2)/length(sus2); % 一年内的停牌率
%                  if tao2~=1
%                      if tao1~=1
%                         volume_1m_60m_12m(i,j) = c; 
%                      else
%                          volume_1m_60m_12m(i,j) = NaN;
%                      end
%                  else
%                      volume_1m_60m_12m(i,j) = NaN; % 若一年内都停牌则NaN
%                  end
%               end
%            end
%        end
% 
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    % settings
    len1 = 20;
    len2 = 60;
    factor = 'volume_1m_60m_60m';
    key = 's_dq_volume';

    tgt_file = [a.output_data_path,'/volume_1m_60m.mat'];
    if exist(tgt_file,'file')==2
        volume_1m_60m = load(tgt_file);
        dt = volume_1m_60m.data.DATEN;
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
            result = factor_append(volume_1m_60m,new);
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

        data.volume_1m_60m = av1_over_av2(stk_num,DATEN,key,factor,all_dates,dt_max,len);
        code_map = result.code_map; %#ok<NASGU>
            
        
        save(tgt_file,'data','code_map');
        
    end


end


% 求len1均值与len2均值之间的商
% key一类需要求均值的数据，为DATEN>dt_max的数据求均值，len是均值窗口长度
% factor是结论数据比如momentum_1m, amount_1m
% all_dates用来对齐不同股票代码的数据以防某些票的数据缺失
function x = av1_over_av2(stk_num,DATEN,key,factor,all_dates,dt_max,len1,len2)

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
        
        start_dt1 = all_dates(n-len1+1); 
        start_dt2 = all_dates(n-len2+1);
        
        n1 = stk_num((r-len1+1):r);
        p1 = key((r-len1+1):r);
        d1 = DATEN((r-len1+1):r);
        
        n2 = stk_num((r-len2+1):r);
        p2 = key((r-len2+1):r);
        d2 = DATEN((r-len2+1):r);
        
        if(n1(1)~=n1(end) || n2(1)~=n2(end))
            x(r) = NaN;
        else
            m1 = mean(p1(d1>=start_dt1),'omitnan');
            m2 = mean(p2(d2>=start_dt2),'omitnan');
            if m2==0
                x(r) = NaN;
            else
                x(r) = m1/m2;
            end
        end
    end
    
end

