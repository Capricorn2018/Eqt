% 2018-11-21: ��Ҫ����style�ǲ�����ͣ�����Ѿ���ΪNaN, ������ǵĻ�Ҫ��code

function [ic, ic_ir, fr] = style_stats(rebalance_dates, style_table, rtn_table, lag)

    % rebalance_dates��cellstr�������ʹ���ַ�������
    rebalance_str = cellstr(num2str(rebalance_dates));
    
    % ���������ֵ��ַ���Ϊ��������������
    style_table.Properties.RowNames = cellstr(num2str(rtn_table.DATEN));
    
    % ���ַ�������ȡ�õ����յ�style
    style = table2array(style_table(rebalance_str,2:end));
    
    % ��daily returnת��daily nav, ����NaN�����ڰ�nav���䴦��
    nav = rtn2nav(rtn_table);
    
    % תtable, ʹ���������ֵ��ַ�����Ϊ������������
    nav_table = array2table([style_table.DATEN,nav],'VariableNames',style_table.Properties.VariableNames);
    
    % ȡ�õ����յ�nav, �����ڼ����ڼ�����
    [~,reb_idx,~] = intersect(nav_table.DATEN,rebalance_dates);
    nav_reb = table2array(nav_table);
    if(any(reb_idx(2:end) < reb_idx(1:end-1)+lag))
        disp('In sylte_stats.m: lag is too large!');
        return;
    end
    rtn_reb = nav_reb(reb_idx(2:end),2:end)./nav_reb(reb_idx(1:end-1)+lag,2:end) - 1;
    
    % ��ʼ�����
    ic = nan(size(rtn_reb,1)-1,1);
    fr = nan(size(rtn_reb,1)-1,1);
    
    for i = 1:length(ic)
        % ��spearman rho��ranked ic
        if(~all(isnan(style(i,:))))
            ic(i) = spearman_rho(style(i,:),rtn_reb(i,:));
            % �����Ӷ�δ�����������facror return�ع�
            fr(i) = regress(rtn_reb(i,:)',style(i,:)');
        end
    end
    
    % ����ic/std(ic)���Ժ���ic���ȶ�����
    ic_ir = nanmean(ic)/nanstd(ic);
    
end

% ��daily return��rtn_table�������Ӧ�Ĺ�Ʊÿ��nav
function nav = rtn2nav(rtn_table)

    % ȥ����һ�����ڲ�תarray
    rtn = rtn_table(:,2:end);
    rtn = table2array(rtn);
    
    % ��NaN�����ó�return=0
    rtn_delnan = rtn;
    rtn_delnan(isnan(rtn)) = 0;
    
    % ����ÿֻ��Ʊÿ�յĶ�Ӧnav, �Ե�һ��rebalance_datesΪ1
    nav = cumprod(rtn_delnan+1,1);
    
    % rtn_tableΪNaN������Ҳ��ΪNaN, ����kendall tau����ʱ�������ͣ��Ʊ
    nav(isnan(rtn)) = NaN;

end


% ����spearman rho����ranked ic, style���������ӽ���, r����һ���������
function cor = spearman_rho(style, r)

    % Ѱ��style��r�����ǿ�ֵ��λ��
    not_nan = (~isnan(style)) & (~isnan(r));
    
    % ȥ����ֵ���style��r
    style_num = style(not_nan);
    r_num = r(not_nan);

    % ����Kendall tau
    cor = corr(style_num',r_num','type','Spearman');

end