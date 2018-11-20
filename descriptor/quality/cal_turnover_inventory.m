function  cal_turnover_inventory(p,a,K0,K1,K2,K3,K4,K5,K6)
    % Ӧ���˿���ת�� = Ӫҵ�ɱ�/ƽ�������� 
      [~,q1,d1]     = get_rpt_table('AShareIncome', 'LESS_OPER_COST',1,a.input_data_path,p.stk_codes_);
      [~,q2,d2]     = get_rpt_avg_table('AShareBalanceSheet', 'INVENTORIES', 1,a.input_data_path,p.stk_codes_);

      d = intersectvecs(d1,d2);
      q1_ = q1(ismember(d1,d),:);
      q2_ = q2(ismember(d2,d),:);
  
      
      q = q1_./q2_;
%%
%     
%      K0 = 4; % ͬ�� 
%      K1 = 8; % ���ȶ���
%      K2 = 16;  % ���ȶ���
%      K3 = 12;% ���ھ�ֵ��
%      K4 = 8;%  ���ٶȡ�
%      K5 = 20; % �ع�
%      K6 = 8; % ������

     get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,'turnover_inventory');
end