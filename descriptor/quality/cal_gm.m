function  cal_gm(p,a,K0,K1,K2,K3,K4,K5,K6)

      [~,q,d]     = get_rpt_table_by_ttm('AShareTTMHis', 'S_FA_GROSSPROFITMARGIN_TTM',1,a.input_data_path,p.stk_codes_);
  
%%
%     
%      K0 = 4; % 同比 
%      K1 = 8; % 短稳定性
%      K2 = 16;  % 长稳定性
%      K3 = 12;% 长期均值　
%      K4 = 8;%  加速度　
%      K5 = 20; % 回归
%      K6 = 8; % 二次项

     get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,'gm');
end