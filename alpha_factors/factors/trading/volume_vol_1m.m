function [] = volume_vol_1m(a,p)
% volume_vol_1m ��ȥһ���³ɽ�����׼�� / �վ��ɽ���

%     D = 20;
% 
%     T = length(p.all_trading_dates);
%     N = length(p.stk_codes);
%     tgt_tag  = 'volume_vol_1m';  
%     tgt_file = [a.output_data_path,'/','volume_vol_1m.h5'];
% 
%     [S,volume_vol_1m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
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
%                  V = trading_volume(i-D+1:i,j);
%                  sus = is_suspended(i-D+1:i,j);
%                  v = V(sus==0);
%                  c = std(v)/mean(v);
%                  tao = sum(sus)/length(sus); % һ�����ڵ�ͣ����
%                  if tao~=1
%                      volume_vol_1m(i,j) = c;
%                  else
%                      volume_vol_1m(i,j) = NaN; % ��һ���ڶ�ͣ����NaN
%                  end
%               end
%            end
%        end
% 
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    % settings
    len = 20;
    factor = 'volume_vol_1m';
    key = 's_dq_volume';

    tgt_file = [a.output_data_path,'/volume_vol_1m.mat'];
    if exist(tgt_file,'file')==2
        volume_vol_1m = load(tgt_file);
        dt = volume_vol_1m.data.DATEN;
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
            result = factor_append(volume_vol_1m,new);
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

        data.volume_vol_1m = stdev(stk_num,DATEN,key,factor,all_dates,dt_max,len);
        code_map = result.code_map; %#ok<NASGU>
            
        
        save(tgt_file,'data','code_map');
        
    end

end



% ���ֵ
% keyһ����Ҫ���ֵ�����ݣ�ΪDATEN>dt_max���������ֵ��len�Ǿ�ֵ���ڳ���
% factor�ǽ������ݱ���momentum_1m, amount_1m
% all_dates�������벻ͬ��Ʊ����������Է�ĳЩƱ������ȱʧ
function x = stdev(stk_num,DATEN,key,factor,all_dates,dt_max,len)

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
            x(r) = std(p(d>=start_dt),'omitnan');            
        end
    end
    
end

