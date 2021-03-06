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
    
for i=1:length(c)
    
    tgt_file = cell2mat(c(i));
    tgt_tag = get_tag([a.single_test.descriptors,'\',tgt_file]);

    % 读取对应的因子数据
    style_table = h5_table(a.single_test.descriptors,tgt_file,tgt_tag);
    % 将异常交易日改为NaN
    style_table = del_suspended(style_table,stk_status_table,is_suspended_table);

    %[nav_grp,weight_grp,nav_bench] = simple_test(N_grp,rebalance_dates,rtn_table,style_table,freecap_table);
    [nav_grp,weight_grp,nav_bench] = sector_neutral_test(N_grp,rebalance_dates,rtn_table,style_table,sectors_table,freecap_table); 

    % lag 10 day ic
    [ic, ic_ir, fr] = style_stats(rebalance_dates, style_table, rtn_table, lag);

    [ls_rtn,ls_nav,mean_ret,hit_ratio,ls_ir,max_dd] = grp_stats(rebalance_dates,nav_grp,nav_bench,lag);

    save(['D:\Projects\scratch_data\single_test\',file2name(tgt_file),'.mat'],'nav_grp','weight_grp',...
                                                                    'nav_bench','ic','ic_ir','fr','ls_rtn','ls_nav',...
                                                                    'mean_ret','hit_ratio','ls_ir','max_dd');
    saveas(gcf,['D:\Projects\scratch_data\single_figures\',file2name(tgt_file),'.jpg']);
    
end