function [] = turnover_1m(a,p)
% turnover_1m һ�����ڵ��ջ�����

%     D = 20; % 1����
% 
%    T = length(p.all_trading_dates);
%    N = length(p.stk_codes);
%    tgt_tag  = 'turnover_1m';  
%    tgt_file = [a.output_data_path,'/','turnover_1m.h5'];
% 
%    [S,turnover_1m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
%   
%    if S>0
%        
%        trading_volume   = h5read([a.input_data_path,'\fdata\base_data\stk_prices.h5'],'/trading_volume')'; 
%        free_shares      = h5read([a.input_data_path,'\fdata\base_data\free_shares.h5'],'/free_shares')'; 
%        turn = trading_volume./free_shares/100;
%        turn(isnan(turn)) = 0;
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
%                  T     = turn(i-D+1:i,j);
%                  sus   = is_suspended(i-D+1:i,j);
%                  t     = T(sus==0);
%                  c     = mean(t);
%                  tao = sum(sus)/length(sus);%  ͣ����
%                  if tao~=1
%                      turnover_1m(i,j) = c;
%                  else
%                      turnover_1m(i,j) = NaN;
%                  end
%               end
%            end
%        end
% 
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%    end
   
    % settings
    len = 20;
    factor = 'turnover_1m';
    key = 'vol_over_shr';
    col = {'s_dq_volume','float_a_shr'};
    
    tgt_file = [a.output_data_path,'/turnover_1m.mat'];
    if exist(tgt_file,'file')==2
        turnover_1m = load(tgt_file);
        dt = turnover_1m.data.DATEN;
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
        
        
        
        %%%%%%%%%
        new.data.s_dq_volume = ones(height(new.data),1);
        
        
        
        eval(['new.data.',factor,' = nan(height(new.data),1);']);
        new.data = new.data(:,['stk_num','DATEN',col,factor]);

        new.code_map = x.code_map;
        
       %% ��������Ҫ�������ӱ����޸ĵ�
        td = new.data(:,col);
        vol = td.s_dq_volume;
        shr = td.float_a_shr;
        
        deriv = nan(length(vol),1);
        deriv(vol~=0 & shr~=0) = vol(vol~=0 & shr~=0)./shr(vol~=0 & shr~=0)/10000; %#ok<NASGU>
        
        eval(['new.data.',key,'=deriv;']);
        new.data = new.data(:,{'stk_num','DATEN',key,factor});
        
       %%
        
        if bool
            result = factor_append(turnover_1m,new);
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
        
        data.turnover_1m = average(stk_num,DATEN,key,factor,all_dates,dt_max,len);
        code_map = result.code_map; %#ok<NASGU>
            
        
        save(tgt_file,'data','code_map');
        
    end

end


% ���ֵ
% keyһ����Ҫ���ֵ�����ݣ�ΪDATEN>dt_max���������ֵ��len�Ǿ�ֵ���ڳ���
% factor�ǽ������ݱ���momentum_1m, amount_1m
% all_dates�������벻ͬ��Ʊ����������Է�ĳЩƱ������ȱʧ
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
            x(r) = mean(p(d>=start_dt),'omitnan');            
        end
    end
    
end

