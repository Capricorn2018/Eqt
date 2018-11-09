% ���������ָ�������շ�Χ�ڵ�high/low����
% p: sturct, ����parameters
% a: struct, �����д�����ļ���ַ
% D��int, ����high/low��ǰ���ݵĽ����ո���
% if_mix��bool, true������ҵƽ����Ȩ����ȱʧ����

function  cal_stk_hl(p,a,D,if_mix)
   
   T = length(p.all_trading_dates);
   N = length(p.stk_codes);
  
   tgt_tag1  = 'hl';  
   tgt_file1 = [a.output_data_path,'\','hl_',num2str(D),'-',num2str(if_mix),'.h5'];
   
   % ���Ŀ���ļ�, ������Ҫ��һ����Ҫ���µ����ڶ�Ӧ���±�S, �͸���ǰ������hl
   [S,hl] =  check_exist(tgt_file1,['/',tgt_tag1],p,T,N);
   
   if S>0      
       if if_mix
          vi = sector_hl(a,D,S,T,hl);
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
           adj_prices(idx:idx + 21,i)  = NaN; % IPO֮��21�������ռ۸񲻼�, ��ΪNaN
       end
       
       adj_prices = adj_prices(1:T,:);  
       adj_prices  = adj_table(adj_prices);
       
       % ������Ҫ���µ������±�S:T, �������ո���
       for  i  = S  : T
           for j = 1: N  % �����Ʊ����
              if p.all_trading_dates(i)>ipo_dates(j)
                 Y     = adj_prices(i-D:i,j);
                 sus   = is_suspended(i-D+1:i,j);
                 y     =  Y(2:end)./Y(1:end-1)-1;  
                 %  y(isnan(y)) = 0;
                 hl_ = cumprod(1+y);
                 hls = max(hl_)/min(hl_)-1;
                 tao = sum(sus)/length(sus); % ����ͣ����
                 if tao~=1
                     if if_mix
                         % ��ͣ���ʹ���ʱ�������ƫ����ҵƽ����high/low, ��������ͣ����taoȡ����
                         hl(i,j) = (1-tao*tao*tao)*hls + tao*tao*tao*vi(i,j);
                     else
                         hl(i,j) = hls;
                     end   
                 else
                     if if_mix
                         hl(i,j) = vi(i,j);
                     else
                         hl(i,j) = NaN;
                     end   
                 end
              end
           end
       end
       % д�ļ�, ��������tgt_tag1
       eval(['hdf5write(tgt_file1, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,''',tgt_tag1, ''',',tgt_tag1, ');']);   
   end
     
end