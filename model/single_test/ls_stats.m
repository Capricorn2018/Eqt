% �����������ͳ�Ƶ����ӷ�����longһ��shortһ��ľ�ֵ����״̬
% rebalance_dates: һ��datenum, ��������ÿ����������
% nav_grp: һ��table, ��һ����datenum, ����ÿһ����һ�������nav
% ls_rtn: long��һ��short���һ���ÿ����������
% ls_nav: long��һ��short���һ��ľ�ֵ����
% mean_rt: �����������ƽ������
% hit_ratio: �����ϵ�����ʤ��
% ls_ir: ���Ե�IR
% max_dd: ���Ե����س�

function [ls_rtn,ls_nav,mean_ret,hit_ratio,ls_ir,max_dd] = ls_stats(rebalance_dates,nav_grp)

    % ��rebalance_dates��Ϊcellstr����������ַ�������
    rebalance_str = cellstr(num2str(rebalance_dates));
    
    % ��һ���nav��return
    nav1 = table2array(nav_grp(:,2));
    rtn1 = nav1(2:end) ./ nav1(1:end-1) - 1;
    
    % ���һ���nav��return
    navN = table2array(nav_grp(:,width(nav_grp)));
    rtnN = navN(2:end) ./ navN(1:end-1) - 1;
    
    % ls��ÿ��return
    daily_rtn = (1 - rtn1 + rtnN);
    
    % ls��ÿ��nav
    ls = cumprod(daily_rtn);
    ls = [array2table(nav_grp.DATEN), array2table(ls)];
    ls.Properties.RowNames = cellstr(num2str(nav_grp.DATEN));
    ls.Properties.VariableNames = {'DATEN', 'nav'};
    
    % ���ַ�������ȡ��Ӧ�����յ�nav
    ls_nav = ls(rebalance_str);
    
    % ������֮��ls��ϵ�return
    ls_rtn = ls_nav(2:end) ./ ls_nav(1:end-1) - 1;
    
    % ƽ�����ڼ��������
    mean_ret = mean(ls_rtn);
    
    % ��(�ܡ���)ʤ��
    hit_ratio = length(ls_rtn(ls_rtn>0))/length(ls_rtn);
    
    % ls��ϵ�information ratio
    ls_ir = mean(daily_rtn)/std(daily_rtn)*sqrt(250);
    
    % �������س�
    [~, max_dd] = get_DD_table(ls.DATEN,ls.nav);
    max_dd = min(max_dd);

end
