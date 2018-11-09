function  cal_fee_ratio(p,a,K0,K1,K2,K3,K4,K5,K6)
% (销售费用_TTM+管理费用_TTM+财务费用_TTM)/营业收入_TTM
   
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
%      K0 = 4; % 同比 
%      K1 = 8; % 短稳定性
%      K2 = 16;  % 长稳定性
%      K3 = 12;% 长期均值　
%      K4 = 8;%  加速度　
%      K5 = 20; % 回归
%      K6 = 8; % 二次项

     get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,'cal_fee_ratio');
end