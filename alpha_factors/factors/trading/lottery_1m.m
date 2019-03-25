function [] = lottery_1m(a,p)
% 1����������Ƿ�

    D1 = 0;
    D2 = 20; % ����20������

    % �����������cal_stk_rtn.m�Ĵ���
    
    T = length(p.all_trading_dates);
    N = length(p.stk_codes);
    tgt_tag  = 'lottery_1m'; % ���������
    tgt_file = [a.output_data_path,'/','lottery_1m.h5']; % ���������

    [S,lottery_1m] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);

    if S>0

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
                 [z,~] = max_interval(Y);
                 tao = sum(sus)/length(sus);%  ͣ����
                 
                 if tao~=1
                     lottery_1m(i,j) = z;
                 else
                     lottery_1m(i,j) = NaN;   
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
