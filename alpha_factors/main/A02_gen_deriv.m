% 从pit_data中提取TTM和最新报表数据
% stk_code 在运行前自行读取, 比如：
% load('D:/Projects/pit_data/mat/income/pit_20190201.mat');
% stk_codes = data_last.s_info_windcode;
% stk_codes = unique(stk_codes);

capital_folder = 'D:/Projects/pit_data/mat/capitalization';
close_folder = 'D:/Projects/pit_data/mat/eodprices';
output_folder = 'D:/Projects/pit_data/mat/alpha_factors';
db_names = {'tot_shr','float_a_shr'};
rpt_type = 'LR';
calc_ttm_lr(capital_folder, db_names, output_folder, rpt_type);
db_names = {'s_dq_adjclose','s_dq_close'};
calc_ttm_lr(close_folder, db_names, output_folder, rpt_type);
% 
% input_folder = 'D:/Projects/pit_data/mat/income';
% db_names = {'net_profit_excl_min_int_inc','net_profit_incl_min_int_inc','oper_profit',...
%                 'oper_rev','less_oper_cost','less_selling_dist_exp','less_gerl_admin_exp','less_fin_exp'};
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors';
% rpt_type = 'TTM';
% calc_ttm_lr(input_folder, db_names, output_folder, rpt_type);
% 
% input_folder = 'D:/Projects/pit_data/mat/cashflow';
% db_names = {'net_cash_flows_oper_act'};
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors';
% rpt_type = 'TTM';
% calc_ttm_lr(input_folder, db_names, output_folder, rpt_type);
% 
% input_folder = 'D:/Projects/pit_data/mat/balancesheet';
% db_names = {'tot_shrhldr_eqy_excl_min_int','tot_non_cur_liab','monetary_cap','tot_assets','tot_cur_assets','tot_cur_liab','tot_liab'};
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors';
% rpt_type = 'LR';
% calc_ttm_lr(input_folder, db_names, output_folder, rpt_type);
% 
% 
% input_folder = 'D:/Projects/pit_data/mat/income';
% db_names = {'net_profit_excl_min_int_inc','net_profit_incl_min_int_inc','oper_profit',...
%                 'oper_rev','less_oper_cost'};
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors';
% rpt_type = 'SQ';
% calc_ttm_lr(input_folder, db_names, output_folder, rpt_type);
% 
% 
% input_folder = 'D:/Projects/pit_data/mat/income';
% db_names = {'net_profit_excl_min_int_inc'};
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors';
% rpt_type = 'LYR';
% calc_ttm_lr(input_folder, db_names, output_folder, rpt_type);
% 
% input_folder = 'D:/Projects/pit_data/mat/income';
% db_names = {'net_profit_excl_min_int_inc','oper_rev'};
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors';
% rpt_type = 'LTG';
% calc_ttm_lr(input_folder, db_names, output_folder, rpt_type);
% 
% input_folder = 'D:/Projects/pit_data/mat/income';
% db_names = {'net_profit_excl_min_int_inc','oper_rev','oper_profit'};
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors';
% rpt_type = 'YOY';
% calc_ttm_lr(input_folder, db_names, output_folder, rpt_type);
% 
% input_folder = 'D:/Projects/pit_data/mat/balancesheet';
% db_names = {'tot_assets'};
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors';
% rpt_type = 'MEAN';
% calc_ttm_lr(input_folder, db_names, output_folder, rpt_type);


