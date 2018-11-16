% ��򵥵ĵ����Ӳ���, �õ����ӷ���ֱ������ʷ��������
% rtn_table��ÿֻ��Ʊ��ʷÿ�ո�Ȩ������table, ��һ���Ƕ�Ӧ������int
% a: �洢����·��
% tgt_tag: ��������
% tgt_file: ��ȡ�������ݵ��ļ�����
% rebalance_dates: һ��array, ���������Ҫ�����ֵ�����double
% rtn_table: һ��table, ��һ��DATEN��ÿһ��������double, ���������ÿ����Ʊ��ÿ�ո�Ȩ����

function [nav_grp,weight_grp] = sector_neutral_test(a,tgt_tag,tgt_file,rebalance_dates,rtn_table,sectors_table,freecap_table)
    
    %%%%% ������� %%%%%%%
    N_grp = 10;

    T = height(rtn_table);
    N = width(rtn_table)-1;
   
    % �����ո���
    N_reb = size(rebalance_dates,1);
    %rebalance_dates = table2array(rtn_table(rebalance_idx,1));
    
    % ��ȡ��Ӧ����������
    style = h5read([a.output_data_path,'\',tgt_file],['/',tgt_tag]);
    %sectors = table2array(sectors_table(:,2:end));
        
    % w�����洢
    w = zeros(N_grp,N_reb,N);
    
    % ÿ�������ռ������ڳֲ�Ŀ��
    for i=1:N_reb

        % ��rtn_table��Ӧ�����н�������Ѱ�ҵ����ն�Ӧ���±�j
        j = find(table2array(rtn_table(:,1))==rebalance_dates(i,1),1,'first');
        
        % ��Ҫȡǰһ������ӽ���, j=j-1
        if(j>1)
            j = j - 1;
        else
            continue;
        end
        
        % cross sectional style, �������ӽ���
        cs = squeeze(style(j,:));
        ss = table2array(sectors_table(j,2:end));
        freecap = table2array(freecap_table(j,2:end));
        
        cs = cs';
        ss = ss';
        freecap = freecap';
        
        tbl = [array2table(cs), array2table(ss)];

        % �������ӷǿյĹ�Ʊ����
        n_stk = length(cs(~isnan(cs)));
        
        % ����������ֵȫΪ��ֵ��Ĭ�Ͽղ�
        if(n_stk==0)
            continue;
        end
        
        % �������Ļ��ֵ�
        func = @(x) [-Inf,quantile(x,N_grp-1),Inf]';
        quantile_table = grpstats(tbl,'ss',func);
        quantile_array = table2array(quantile_table(:,3));
        quantile_table = array2table(quantile_array,'RowNames',quantile_table.Properties.RowNames);
        
        tbl = [array2table(ss), array2table(freecap)];
        sector_cap = grpstats(tbl,'ss','nansum');
        sector_cap_array = table2array(sector_cap(:,2:3));
        sector_weight = sector_cap_array(:,2) ./ sum(sector_cap_array(:,2));
        sector_weight = array2table(sector_weight,'RowNames',sector_cap.Properties.RowNames);
        
        % ��ÿһ���������simulated_nav
        for grp=1:N_grp            
            
            % �ж���Щ��Ʊ�ڵ�grp��������
            lower_bound = NaN(length(ss),1);
            upper_bound = NaN(length(ss),1);
            is_in_grp = false(length(ss),1);
            
            sectors_str = num2str(ss);
            sectors_str = cellstr(sectors_str);
            
            lower_bound(~isnan(ss)) = table2array(quantile_table(sectors_str(~isnan(ss)),grp));
            upper_bound(~isnan(ss)) = table2array(quantile_table(sectors_str(~isnan(ss)),grp+1));
            
            is_in_grp(~isnan(ss)) = cs(~isnan(ss))>lower_bound(~isnan(ss)) & cs(~isnan(ss))<=upper_bound(~isnan(ss));
                                   
            tbl = [array2table(ss),array2table(is_in_grp)];
            grp_sector_count = grpstats(tbl,'ss','nansum');
            sector_weight_array = table2array(sector_weight(:,1)) ./ table2array(grp_sector_count(:,3));
            sector_weight = array2table(sector_weight_array,'RowNames',sector_weight.Properties.RowNames);
            
            % �����ȼ������ڵ�Ȩ������
            w_table = sector_weight(sectors_str(is_in_grp),1);
            w(grp,i,is_in_grp) = table2array(w_table);
        end

    end
    
    % ��ʼ�����, weight_grpΪһ��struct, ��ÿ����Ľ���ӽ�ȥ
    simulated_nav_grp = ones(T,N_grp);
    weight_grp = struct;
    
    % ����ѭ��, ģ�⾻ֵ
    group_names = cell(1,N_grp);
    for grp=1:N_grp
        % ��grp���Ȩ��table
        weights_table = [array2table(rebalance_dates),array2table(squeeze(w(grp,:,:)))];
        weights_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
        % ��grp��Ľ��׳ɱ�table
        cost_table =[array2table(rebalance_dates),array2table(zeros(N_reb,N))];
        cost_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

        % ģ��nav������weight
        [simulated_nav,weight] = simulator(rtn_table,weights_table,cost_table); %#ok<ASGLU>
        
        % ��eval��weight_grp���struct��һ���ɷ�, ����Ϊ 'group1', 'group2',...
        group_names(1,grp) = {['group',num2str(grp)]};
        eval(['weight_grp.group',num2str(grp),'= table2array(weight);']);
        % ��ÿ�����nav�ز����������
        simulated_nav_grp(:,grp) = table2array(simulated_nav(:,2));
        
    end
    
    % �������, ����һ������double
    nav_grp = [rtn_table(:,1),array2table(simulated_nav_grp)];
    nav_grp.Properties.VariableNames = ['DATEN' group_names];
    
end
