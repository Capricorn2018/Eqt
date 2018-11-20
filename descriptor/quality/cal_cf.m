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
%      K0 = 4; % 同比 
%      K1 = 8; % 短稳定性
%      K2 = 16;  % 长稳定性
%      K3 = 12;% 长期均值　
%      K4 = 8;%  加速度　
%      K5 = 20; % 回归
%      K6 = 8; % 二次项

     get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,'cf');
end