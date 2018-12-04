%%
a.project_path       = 'D:\Projects\Eqt'; 
cd(a.project_path); addpath(genpath(a.project_path));
%%

a.single_test.base_data  = 'D:\Capricorn\fdata\base_data';
a.single_test.descriptors   = 'D:\Capricorn\descriptors';

a.single_test.style = 'D:\Capricorn\model\risk\style'; % 读取risk model中style/sector factor的路径
a.single_test.regression = 'D:\Capricorn\model\risk\regression'; % 读取risk model中regression结果的路径
a.single_test.dfquant_risk = 'D:\Capricorn\model\dfquant_risk'; % 读取东方证券risk model结果的路径

%%
p.all_trading_dates_ = h5read([a.single_test.base_data,'\securites_dates.h5'],'/date');     
p.all_trading_dates  = datenum_h5 (h5read([a.single_test.base_data,'\securites_dates.h5'],'/date'));  
p.stk_codes_         = h5read([a.single_test.base_data,'\securites_dates.h5'],'/stk_code'); 
p.stk_codes          = stk_code_h5(h5read([a.single_test.base_data,'\securites_dates.h5'],'/stk_code')); 

% 转换成SH600018这种格式
p.single_test.stk_codes    = p.stk_codes;
x = [];
for k = 1 : length(p.single_test.stk_codes)
    z = cell2mat(p.single_test.stk_codes(k));
    x = [x,cellstr(z([8:9,1:6]))]; %#ok<AGROW>
end
p.single_test.stk_codes1 = x;
%%
%%
% 需要处理的单因子存储的文件名
tgt_file = 'hl_21-1.h5';
tgt_tag = get_tag([a.single_test.descriptors,'\',tgt_file]);

% 读取复权价格表
price_table = h5_table(a.single_test.base_data,'stk_prices.h5','adj_prices');
rtn_table = price2rtn(price_table); % 从复权价格计算return, 在停牌日等异常点为0

% 读取股票交易状态
stk_status_table = h5_table(a.single_test.base_data,'stk_status.h5','stk_status');
is_suspended_table = h5_table(a.single_test.base_data,'suspended.h5','is_suspended');

% 把异常点改为NaN
rtn_table = del_suspended(rtn_table,stk_status_table,is_suspended_table);

% 所有的trading dates
trading_dates = p.all_trading_dates_;
trading_dates = datenum(trading_dates,'yyyymmdd');

%% 选择计算起始日的下标和间隔 %%
rebalance_dates = trading_dates(5000:end);
[rebalance_dates,~] = find_month_dates(1,rebalance_dates,'first'); % 每个月的第一个交易日

% 读取markcap
freecap_table = h5_table(a.single_test.base_data,'free_shares.h5','free_cap');

% 读取对应的因子数据]
style_table = h5_table(a.single_test.descriptors,tgt_file,tgt_tag);
% 将异常交易日改为NaN
style_table = del_suspended(style_table,stk_status_table,is_suspended_table);

% risk adjusted factor等等需要做中性的因子名
Ind_names=cell(1,36); % 行业因子名 Ind1, Ind2...
for i=1:36
    Ind_names(i) = {strcat('Ind',num2str(i))};
end
risk_factor_names = {'beta','tcap'}; % 风格因子名
risk_factor_names = [risk_factor_names,Ind_names];

% 设置CVX和Mosek
%cvx_solver Mosek;
%javaaddpath 'D:\Program Files\Mosek\8\tools\platform\win64x86\bin\mosekmatlab.jar'

% pure factor call
weight_table = pure_factor(a,rebalance_dates,style_table,freecap_table,risk_factor_names);
save('D:\Projects\scratch_data\single_test\pure_factor.mat','weight_table');

% factor mimicking portfolio call
%weight_table = factor_mimicking(a,rebalance_dates,style_table,freecap_table,risk_factor_names);
%save('D:\Projects\scratch_data\single_test\factor_mimicking.mat','weight_table');

% risk adjusted factor call
%adj_style_table = risk_adj_factor(a,rebalance_dates,style_table,freecap_table,risk_factor_names);

% simple single factor test call
%[nav_grp,weight_grp,nav_bench] = simple_test(5,rebalance_dates,rtn_table,adj_style_table,freecap_table);
%save('D:\Projects\scratch_data\single_test\risk_adj_test.mat','nav_grp','weight_grp','adj_style_table');