% ��򵥵ĵ����Ӳ���, �õ����ӷ���ֱ������ʷ��������
% rtn_table��ÿֻ��Ʊ��ʷÿ�ո�Ȩ������table, ��һ���Ƕ�Ӧ������int
% a: �洢����·��
% tgt_tag: ��������
% tgt_file: ��ȡ�������ݵ��ļ�����
% rebalance_dates: һ��array, ���������Ҫ�����ֵ�����double
% rtn_table: һ��table, ��һ��DATEN��ÿһ��������double, ���������ÿ����Ʊ��ÿ�ո�Ȩ����

function [nav_grp,weight_grp] = naive_test(a,tgt_tag,tgt_file,rebalance_dates,rtn_table)
    
    %%%%% ������� %%%%%%%
    N_grp = 10;

    T = height(rtn_table);
    N = width(rtn_table)-1;
   
    % �����ո���
    N_reb = size(rebalance_dates,1);
    %rebalance_dates = table2array(rtn_table(rebalance_idx,1));
    
    % ��ȡ��Ӧ����������
    style = h5read([a.output_data_path,'\',tgt_file],['/',tgt_tag]);
        
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

        %[~,idx] = sort(style(j,:),direction);
        
        % cross sectional style, �������ӽ���
        cs = squeeze(style(j,:));

        % �������ӷǿյĹ�Ʊ����
        n_stk = length(cs(~isnan(cs)));
        
        % ����������ֵȫΪ��ֵ��Ĭ�Ͽղ�
        if(n_stk==0)
            continue;
        end
        
        % �������Ļ��ֵ�
        quantile_grp = [-Inf,quantile(cs,N_grp-1),Inf];
        
        % ��ÿһ���������simulated_nav
        for grp=1:N_grp            
            
            % �ж���Щ��Ʊ�ڵ�grp��������
            is_in_grp = cs>quantile_grp(grp) & cs<=quantile_grp(grp+1);
            
            % �����ڹ�Ʊ����
            n_in_grp = length(cs(is_in_grp));
            
            % ��������û�й�Ʊ��Ĭ��Ȩ�ض�Ϊ0
            if(n_in_grp==0)
                continue;
            end
            
            % �����ȼ������ڵ�Ȩ������
            w(grp,i,is_in_grp) = 1./n_in_grp;
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