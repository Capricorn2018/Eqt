function [] = lottary_1m(p,a)
% 1����������Ƿ�

    D1 = 0; %#ok<NASGU>
    D2 = 20; % ����21������
    if_mix = false; % ������ҵƽ����shrinkage

    % �����������cal_stk_rtn.m�Ĵ���
    
    T = length(p.all_trading_dates);
    N = length(p.stk_codes);
    tgt_tag  = 'lottary_1m'; % ���������
    tgt_file = [a.output_data_path,'/','lottary_1m.h5']; % ���������

    [S,lottary_1m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);

    if S>0      
       if if_mix
          vi = sector_rtn(a,D1,D2,S,T,lottary_1m); %#ok<UNRCH>
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
           adj_prices(idx:idx + 21,i)  = NaN; % first 1 month set to NaN
       end

       adj_prices = adj_prices(1:T,:);  
       adj_prices  = adj_table(adj_prices);

       for  i  = S  : T
           for j = 1: N
              if p.all_trading_dates(i)>ipo_dates(j)
                 Y     = adj_prices(i-D2:i,j);
                 sus   = is_suspended(i-D2+1:i,j);
%                  y     = Y(2:end)./Y(1:end-1)-1;  
%                 % y(isnan(y))= 0;
%                  z = cumprod(1 + y);
%                  tao = sum(sus)/length(sus);%  ͣ����
                 [z,~] = max_interval(Y);
                 tao = sum(sus)/length(sus);%  ͣ����
                 
                 if tao==1
                     if if_mix
                         lottary_1m(i,j) = (1-tao*tao*tao)*z + tao*tao*tao*vi(i,j); %#ok<UNRCH>
                     else
                         lottary_1m(i,j) = z;
                     end      
                 else
                     if if_mix
                         lottary_1m(i,j) = vi(i,j); %#ok<UNRCH>
                     else
                         lottary_1m(i,j) = NaN;
                     end      
                 end
              end
           end
       end


       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',...
                tgt_tag, ''',','' tgt_tag, ');']);  
    end

end


% �õݹ鷽������ʱ���ڵ���������Ƿ�
function [ret,m] = max_interval(prices)
% ret�Ǽ۸������������������Ƿ�
% m��������Сֵ

    if(length(prices)<2)
        disp('max_interval: length(prices)<2');
        return;
    end

    if(length(prices)==2)
        % ���г�����2��ֱ�ӷ���
        ret = max(0,prices(2)/prices(1)-1);
        m = min(prices);
    else
        % ���г��ȳ���2�õݹ�
        
        % �Ƚ����ȵݹ�
        [ret1,m1] = max_interval(prices(1:end-1));
        
        % ���µļ۸�
        new = prices(end);
        
        % �Ƚ�price(1:end-1)���������Ƿ�
        % �Լ�����������Сֵ
        ret = max(ret1,new/m1-1);
        m = min(m1,new);
    end

end
