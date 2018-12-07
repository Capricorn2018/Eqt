N_grp=5;
lag=0;

%%
a.project_path       = 'D:\Projects\Eqt'; 
cd(a.project_path); addpath(genpath(a.project_path));
%%

start_dt = datenum(2010,01,01);
[a,p,stk_status_table,is_suspended_table,...
              rtn_table,freecap_table,sectors_table,rebalance_dates] = set_single_test(start_dt);

c = get_file_names(a.single_test.descriptors);

% risk adjusted factor等等需要做中性的因子名
Ind_names=cell(1,36); % 行业因子名 Ind1, Ind2...
for i=1:36
    Ind_names(i) = {strcat('Ind',num2str(i))};
end
risk_factor_names = {'beta','tcap'}; % 风格因子名
risk_factor_names = [risk_factor_names,Ind_names];


for i = 1:1%length(c)
    
    tgt_file = cell2mat(c(i));
    tgt_tag = get_tag([a.single_test.descriptors,'\',tgt_file]);

    % 读取对应的因子数据
    style_table = h5_table(a.single_test.descriptors,tgt_file,tgt_tag);
    % 将异常交易日改为NaN
    style_table = del_suspended(style_table,stk_status_table,is_suspended_table);
    
    weight_table = pure_factor(a,rebalance_dates,style_table,freecap_table,risk_factor_names);
    
%     adj_style_table = risk_adj_factor(a,rebalance_dates,style_table,freecap_table,risk_factor_names);
% 
%     [nav_grp,weight_grp,nav_bench] = simple_test(5,rebalance_dates,rtn_table,adj_style_table,freecap_table);
%     % lag 10 day ic
%     [ic, ic_ir, fr] = style_stats(rebalance_dates, style_table, rtn_table, lag);
% 
%     [ls_rtn,ls_nav,mean_ret,hit_ratio,ls_ir,max_dd] = grp_stats(rebalance_dates,nav_grp,nav_bench,lag);
% 
%     save(['D:\Projects\scratch_data\risk_adj_test\',file2name(tgt_file),'.mat'],'nav_grp','weight_grp',...
%                                                                     'nav_bench','ic','ic_ir','fr','ls_rtn','ls_nav',...
%                                                                     'mean_ret','hit_ratio','ls_ir','max_dd');
%     saveas(gcf,['D:\Projects\scratch_data\risk_adj_figures\',file2name(tgt_file),'.jpg']);
    
end


% 设置CVX和Mosek
%cvx_solver Mosek;
%javaaddpath 'D:\Program Files\Mosek\8\tools\platform\win64x86\bin\mosekmatlab.jar'

% pure factor call
%weight_table = pure_factor(a,rebalance_dates,style_table,freecap_table,risk_factor_names);
%save('D:\Projects\scratch_data\single_test\pure_factor.mat','weight_table');

% factor mimicking portfolio call
%weight_table = factor_mimicking(a,rebalance_dates,style_table,freecap_table,risk_factor_names);
%save('D:\Projects\scratch_data\single_test\factor_mimicking.mat','weight_table');

% risk adjusted factor call
% adj_style_table = risk_adj_factor(a,rebalance_dates,style_table,freecap_table,risk_factor_names);

% simple single factor test call
% [nav_grp,weight_grp,nav_bench] = simple_test(5,rebalance_dates,rtn_table,adj_style_table,freecap_table);
% save('D:\Projects\scratch_data\single_test\risk_adj_test.mat','nav_grp','weight_grp','adj_style_table');