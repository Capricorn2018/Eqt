N_grp=5;
lag=0;

%%
a.project_path       = 'D:\Projects\Eqt'; 
cd(a.project_path); addpath(genpath(a.project_path));
%%

start_dt = datenum(2010,01,01);
[a,p,rebalance_dates] = set_optimization(start_dt);

% �Ż���alpha�����ڶ�ȡtable�е�����
alpha_factor_names = {'bp','earning_quality','earning_variability','growth','leverage','momentum','profitability','uncertain','volatility','yield'}; % ���������

weight_table = optimization(a,p,rebalance_dates);

% ����Ҫ���Ͼ���������������
% rtn_table ����ʹ��������Ҳ�������������
% cost_table �ȶ���0
% [simulated_nav,weight] = simulator(rtn_table,weight_table,cost_table)


% ��ȡ��Ȩ�۸��
price_table = h5_table('D:/Capricorn/fdata/base_data','stk_prices.h5','adj_prices');
rtn_table = price2rtn(price_table); % �Ӹ�Ȩ�۸����return, ��ͣ���յ��쳣��Ϊ0
rtn_stk = h5read('D:/Capricorn/fdata/base_data/stk_prices.h5','/stk_code');

% ��ȡ��Ʊ����״̬
stk_status_table = h5_table('D:/Capricorn/fdata/base_data','stk_status.h5','stk_status');
is_suspended_table = h5_table('D:/Capricorn/fdata/base_data','suspended.h5','is_suspended');

% ���쳣���ΪNaN
% rtn_table = del_suspended(rtn_table,stk_status_table,is_suspended_table);

tmp_rtn = [rtn_table(:,'DATEN'), array2table(nan(height(rtn_table),width(weight_table)-1))];
tmp_rtn.Properties.VariableNames = weight_table.Properties.VariableNames;

[Lia,Locb] = ismember(tmp_rtn.Properties.VariableNames,rtn_table.Properties.VariableNames);

tmp_rtn(:,Lia) = rtn_table(:,Locb(Locb>0)); 
rtn_table = tmp_rtn;

N = width(rtn_table)-1;
   
% �����ո���
N_reb = size(rebalance_dates,1);

% ��grp��Ľ��׳ɱ�table
cost_table =[array2table(rebalance_dates),array2table(zeros(N_reb,N))];
cost_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

[simulated_nav,weight] = simulator(rtn_table,weight_table,cost_table);