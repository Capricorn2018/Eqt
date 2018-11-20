function  cal_dtoa(p,a,K0,K1,K2,K3,K4,K5,K6)
% �ʲ���ת��
   
      [q1,~,d1]     = get_rpt_table('AShareBalanceSheet', 'TOT_ASSETS',0,a.input_data_path,p.stk_codes_);
      [q2,~,d2]     = get_rpt_table('AShareBalanceSheet', 'TOT_LIAB',0,a.input_data_path,p.stk_codes_);
      [~,ia,ib] = intersect(d1,d2);
      d = d1(ia);
      q1_  = q1(ia,:);
      q2_  = q2(ib,:);
      q  = q1_./q2_;
      
%%
%     
%      K0 = 4; % ͬ�� 
%      K1 = 8; % ���ȶ���
%      K2 = 16;  % ���ȶ���
%      K3 = 12;% ���ھ�ֵ��
%      K4 = 8;%  ���ٶȡ�
%      K5 = 20; % �ع�
%      K6 = 8; % ������

     get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,'dtoa');
end