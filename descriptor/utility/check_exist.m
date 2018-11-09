% T: �ܽ�������
% N: �ܹ�Ʊ����
% p: struct, ����parameters
% S����Ҫ���µ��׸�������������p.all_trading_dates�е��±�
% X������ǰ������

function [S,X] =  check_exist(tgt_file,tgt_tag,p,T,N)

       S = 0;
       X = [];

       % exist_flag: 0,���������ڶ��Ҳ����ļ���Ҫȫ������; 1,����Щ��Ҫ����
       % loc_stk: ����Ҫ���µ�Ʊ��ע�±꣬��Ҫ���µ���ЩƱΪ0
       % loc_dt: ����Ҫ���µ����ڱ�ע�±꣬��Ҫ���µĽ�����Ϊ0
       [idx_stk,loc_stk,idx_dt,loc_dt,exist_flag] = check_exist_h5(tgt_file,p);
       
       % �����Ӧ�ļ�����������Ҫ����
       if all(idx_stk)&&all(idx_dt)  
           return;
       end
       
       X = NaN(T,N);
       
       if exist_flag==0 % �����н����ն���Ҫ����ʱ      
           S = find(p.all_trading_dates>=datenum(2005,1,1),1,'first');
       elseif exist_flag==1 % ����һЩ��������Ҫ����ʱ
           X(idx_dt,idx_stk) = h5read(tgt_file,tgt_tag);
           S = find(loc_dt==0,1,'first'); % �ҵ���Ҫ���µĵ�һ�������յ��±�
       end
       
end