function  cal_sgro(p,a,K0,K1,K2,K3,K4,K5,K6)

      [~,q1,d]    = get_rpt_table('AShareIncome', 'OPER_REV',1,a.input_data_path,p.stk_codes_);

       tshrs  = h5read([a.input_data_path,'\fdata\base_data\capital.h5'],'/total_shares')'*10000;
       q = NaN(size(q1)); 
       for i  = 1 : length(d)
          idx  = find(p.all_trading_dates<=d(i),1,'last');
          if ~isempty(idx)
             q(i,:) = q1(i,:)./tshrs(idx,:);
          end
       end
       
      
%%
%     
%      K0 = 4; % ͬ�� 
%      K1 = 8; % ���ȶ���
%      K2 = 16;  % ���ȶ���
%      K3 = 12;% ���ھ�ֵ��
%      K4 = 8;%  ���ٶȡ�
%      K5 = 20; % �ع�
%      K6 = 8; % ������

     get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,'sps');
end