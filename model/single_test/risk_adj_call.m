%%
a.project_path       = 'D:\Projects\Eqt'; 
cd(a.project_path); addpath(genpath(a.project_path));
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
tgt_tag = file2tag(tgt_file); % 取变量名

adj_prices = h5read([a.single_test.base_data,'\stk_prices.h5'],'/adj_prices')';
rtn_array = adj_prices(2:end,:)./adj_prices(1:end-1,:) - 1;

stk_status   = h5read([a.single_test.base_data,'\stk_status.h5'],'/stk_status')'; 
is_suspended = double(h5read([a.single_test.base_data,'\suspended.h5'],'/is_suspended')');

is_suspended(isnan(stk_status)) = NaN;
is_suspended(is_suspended==1) = NaN;
is_suspended(isnan(is_suspended)) =1;

is_suspended = is_suspended(2:end,:);

% 把当日停牌的日期收益全都设为空值, 以避免后续单因子分析时造成扰动
rtn_array(is_suspended==1) = NaN;

trading_dates = p.all_trading_dates_(2:end);
trading_dates = datenum(trading_dates,'yyyymmdd');

rtn_table = [ array2table(trading_dates), array2table(rtn_array)];
rtn_table.Properties.VariableNames = ['DATEN',p.single_test.stk_codes1];

%% 选择计算起始日的下标和间隔 %%
rebalance_dates = trading_dates(5000:end);
[rebalance_dates,~] = find_month_dates(1,rebalance_dates,'first'); % 每个月的第一个交易日

freecap = h5read([a.single_test.base_data,'\free_shares.h5'],'/free_cap');
freecap_table = [ array2table(trading_dates), array2table(freecap(:,2:end)') ];
freecap_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

% 读取对应的因子数据
style = h5read([a.single_test.descriptors,'\',tgt_file],['/',tgt_tag]);
style = style(2:end,:);
style(is_suspended==1) = NaN;
style_table = [array2table(trading_dates), array2table(style)];
style_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

Ind_names=cell(1,36);
for i=1:36
    Ind_names(i) = {strcat('Ind',num2str(i))};
end
risk_factor_names = {'beta','tcap'};
risk_factor_names = [risk_factor_names,Ind_names];

% 设置CVX和Mosek
%cvx_solver Mosek;
%javaaddpath 'D:\Program Files\Mosek\8\tools\platform\win64x86\bin\mosekmatlab.jar'
weight_table = pure_factor(a,rebalance_dates,style_table,freecap_table,risk_factor_names);
save('D:\Projects\scratch_data\single_test\pure_factor.mat','weight_table');

%weight_table = factor_mimicking(a,rebalance_dates,style_table,freecap_table,risk_factor_names);
%save('D:\Projects\scratch_data\single_test\factor_mimicking.mat','weight_table');

%adj_style_table = risk_adj_factor(a,rebalance_dates,style_table,freecap_table,risk_factor_names);

%[nav_grp,weight_grp,nav_bench] = naive_test(5,rebalance_dates,rtn_table,adj_style_table,freecap_table);
%save('D:\Projects\scratch_data\single_test\risk_adj_test.mat','nav_grp','weight_grp','adj_style_table');