function  cal_fee_ratio(p,a,K0,K1,K2,K3,K4,K5,K6)
% (���۷���_TTM+�������_TTM+�������_TTM)/Ӫҵ����_TTM
   
      [~,q1,d1]     = get_rpt_table('AShareIncome', 'LESS_SELLING_DIST_EXP',1,a.input_data_path,p.stk_codes_);
      [~,q2,d2]     = get_rpt_table('AShareIncome', 'LESS_GERL_ADMIN_EXP',1,a.input_data_path,p.stk_codes_);
      [~,q3,d3]     = get_rpt_table('AShareIncome', 'LESS_FIN_EXP',1,a.input_data_path,p.stk_codes_);
      [~,q4,d4]     = get_rpt_table('AShareIncome', 'OPER_REV',1,a.input_data_path,p.stk_codes_);
   
      d = intersectvecs(d1,d2,d3,d4);
      q1_ = q1(ismember(d1,d),:);
      q2_ = q2(ismember(d2,d),:);
      q3_ = q3(ismember(d3,d),:);
      q4_ = q4(ismember(d4,d),:);
      
      q = (q1_ + q2_ + q3_ )./q4_;
      
%%
%     
%      K0 = 4; % ͬ�� 
%      K1 = 8; % ���ȶ���
%      K2 = 16;  % ���ȶ���
%      K3 = 12;% ���ھ�ֵ��
%      K4 = 8;%  ���ٶȡ�
%      K5 = 20; % �ع�
%      K6 = 8; % ������

     get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,'cal_fee_ratio');
end