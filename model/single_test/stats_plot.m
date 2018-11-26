function stats_plot(rebalance_dates,nav_grp,nav_bench)

%     N_grp = size(nav_grp,2)-1;
%     
%     for grp = 1:N_grp
% 
%         eval(['nav_grp_',num2str(grp),'=nav_grp(:,',num2str(grp+1),');']);
%         cum_rtn = eval(['nav_grp_',num2str(grp)]);
%         cum_rtn = table2array(cum_rtn);
% 
%         plot(cum_rtn);
%         hold on;
%         
%     end
% 
%     hold off;
    
    % rebalance_dateתΪcellstr��������
    rebalance_str = cellstr(num2str(rebalance_dates));
    
    % ������������rebalance_str��������
    nav_grp.Properties.RowNames = cellstr(num2str(nav_grp.DATEN));
    nav_bench.Properties.RowNames = cellstr(num2str(nav_grp.DATEN));
    
    % ȡ��nav�ڶ�Ӧ�����յ�ֵ
    reb_nav = table2array(nav_grp(rebalance_str,2:end));
    
    % ������������
    reb_rtn = reb_nav(2:end,:) ./ reb_nav(1:end-1,:) - 1;
    
    % benchmark����������
    bench = table2array(nav_bench(rebalance_str,2:end));
    bench_rtn = bench(2:end,:) ./ bench(1:end-1,:) - 1;
    
    % ���䳬��
    excess_rtn = reb_rtn - repmat(bench_rtn,1,size(reb_rtn,2));
    
    % ���䳬���ֵ
    grp_mean = mean(excess_rtn,1);
    
    % barplot
    bar(grp_mean);
    
end