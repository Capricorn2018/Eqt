function  cal_cf(p,a,K0,K1,K2,K3,K4,K5,K6)

      [~,q,d]    = get_rpt_table('AShareCashFlow', 'STOT_CASH_INFLOWS_OPER_ACT',1,a.input_data_path,p.stk_codes_);
%       [~,qasset,d2] = get_rpt_avg_table('AShareBalanceSheet', 'TOT_SHRHLDR_EQY_EXCL_MIN_INT', 1,a.input_data_path,p.stk_codes_);
%       [~,ia,ib] = intersect(d1,d2);
%       d = d1(ia);
%       e_q = qe(ia,:);
%       asset_q  = qasset(ib,:);
%       q  = e_q./asset_q;
%%
%     
%      K0 = 4; % ͬ�� 
%      K1 = 8; % ���ȶ���
%      K2 = 16;  % ���ȶ���
%      K3 = 12;% ���ھ�ֵ��
%      K4 = 8;%  ���ٶȡ�
%      K5 = 20; % �ع�
%      K6 = 8; % ������

     get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,'cf');
end