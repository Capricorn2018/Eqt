% 2018-11-21: ��Ҫ����style�ǲ�����ͣ�����Ѿ���ΪNaN, ������ǵĻ�Ҫ��code

function [ic, ic_ir] = style_ic(rebalance_dates, style_table, rtn_table)

    % rebalance_dates��cellstr�������ʹ���ַ�������
    rebalance_str = cellstr(num2str(rebalance_dates));
    
    % ���������ֵ��ַ���Ϊ��������������
    style_table.Properties.RowNames = cellstr(num2str(rtn_table.DATEN));
    
    % ���ַ�������ȡ�õ����յ�style
    style = table2array(style_table(rebalance_str,2:end));
    
    % ��daily returnת��daily nav, ����NaN�����ڰ�nav���䴦��
    nav = rtn2nav(rtn_table);
    
    % תtable, ʹ���������ֵ��ַ�����Ϊ������������
    nav_table = array2table(nav,'RowNames',style_table.Properties.RowNames);
    
    % ȡ�õ����յ�nav, �����ڼ����ڼ�����
    nav_reb = nav_table(rebalance_str,:);
    nav_reb = table2array(nav_reb);
    rtn_reb = nav_reb(2:end,:)./nav_reb(1:end-1,:) - 1;
    
    % ��ʼ�����
    ic = zeros(size(rtn_reb,1)-1,1);
    
    for i = 1:length(ic)
        % ��spearman rho��ranked ic
        ic(i) = spearman_rho(style(i,:),rtn_reb(i,:));
    end
    
    % ����ic/std(ic)���Ժ���ic���ȶ�����
    ic_ir = mean(ic)/std(ic);
    
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


% ����kendall tau����ranked ic, style���������ӽ���, r����һ���������
function cor = spearman_rho(style, r)

    % Ѱ��style��r�����ǿ�ֵ��λ��
    not_nan = (~isnan(style)) & (~isnan(r));
    
    % ȥ����ֵ���style��r
    style_num = style(not_nan);
    r_num = r(not_nan);

    % ����Kendall tau
    cor = corr(style_num',r_num','type','Spearman');

end