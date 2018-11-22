% ��򵥵ĵ����Ӳ���, �õ����ӷ���ֱ������ʷ��������
% rtn_table��ÿֻ��Ʊ��ʷÿ�ո�Ȩ������table, ��һ���Ƕ�Ӧ������int
% N_grp: ����ĸ���, һ����5�鼴��
% rebalance_dates: һ��array, ���������Ҫ�����ֵ�����double
% rtn_table: һ��table, ��һ��DATEN��ÿһ��������double, ���������ÿ����Ʊ��ÿ�ո�Ȩ����

% 2018-11-21: ��Ҫ����style�ǲ�����ͣ�����Ѿ���ΪNaN, ������ǵĻ�Ҫ��code

function [nav_grp,weight_grp,nav_bench] = sector_neutral_test(N_grp,rebalance_dates,rtn_table,style_table,sectors_table,markcap_table)
    
    T = height(rtn_table);
    N_stk = width(rtn_table)-1;
   
    % �����ո���
    N_reb = size(rebalance_dates,1);
    
    style = style_table(:,2:end);
    style = table2array(style);
    
    sectors = sectors_table(:,2:end);
    sectors = table2array(sectors);
    
    markcap = markcap_table(:,2:end);
    markcap = table2array(markcap);
        
    % w�����洢Ȩ��
    w = zeros(N_grp,N_reb,N_stk);
    bench_w = zeros(N_reb,N_stk);
    
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
        
        % �������й�Ʊ��Ӧ����ҵ
        sec = sectors(j,2:end);
        
        % �������й�Ʊ��������ͨ��ֵ
        cap = markcap(j,2:end);
        
        % �õ��չ�Ʊ��������ͨ��ֵ�����׼Ȩ��
        bench_w(i,~isnan(cap)) = cap(~isnan(cap)) ./ nansum(cap);
                
        % תΪ������
        cs = cs';
        sec = sec';
        cap = cap';
        
        % ����һ��table, ��grpstats����ͳ����ҵ����ҵ����ֵ
        tbl = [array2table(sec),array2table(cap)];
        stats = grpstats(tbl,'sec','nansum');
        sector_names = stats.sec; % ȡ����ҵ�б�        
        sector_weight = stats.nansum_cap ./ sum(stats.nansum_cap); % ����ҵ����ֵռ�ȼ������ҵ����
        
        % �������ӷǿյĹ�Ʊ����
        n_stk = length(cs(~isnan(cs)));
        
        % ����������ֵȫΪ��ֵ��Ĭ�Ͽղ�
        if(n_stk==0)
            continue;
        end
        
        for k = 1:length(sector_names)
            
            % ���и���ҵ�Ĺ�Ʊ
            is_in_sector = (sec==sector_names(k));
            
            % ���������quantile_group����, ���������ҵ��ÿ��group��Ȩ��
            mtx = quantile_group(cs(is_in_sector),N_grp) .* sector_weight(k);
            
            % ��w��Ӧ�ý����ա�����ҵ��Ȩ�ظ���
            w(:,i,is_in_sector) = mtx';
            
        end
        
    end
    
    % ��ʼ�����, weight_grpΪһ��struct, ��ÿ����Ľ���ӽ�ȥ
    simulated_nav_grp = ones(T,N_grp);
    weight_grp = struct;
    
    % ��grp��Ľ��׳ɱ�table
    cost_table =[array2table(rebalance_dates),array2table(zeros(N_reb,N_stk))];
    cost_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
    
    % ����ѭ��, ģ�⾻ֵ
    group_names = cell(1,N_grp);
    for grp=1:N_grp
        % ��grp���Ȩ��table
        weights_table = [array2table(rebalance_dates),array2table(squeeze(w(grp,:,:)))];
        weights_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
        
        % ģ��nav������weight
        [simulated_nav,weight] = simulator(rtn_table,weights_table,cost_table); %#ok<ASGLU>
        
        % ��eval��weight_grp���struct��һ���ɷ�, ����Ϊ 'group1', 'group2',...
        group_names(1,grp) = {['group',num2str(grp)]};
        eval(['weight_grp.group',num2str(grp),'= table2array(weight);']);
        % ��ÿ�����nav�ز����������
        simulated_nav_grp(:,grp) = table2array(simulated_nav(:,2));
        
    end
    
    % ��׼������
    bench_w_table = [array2table(rebalance_dates),array2table(bench_w)];
    bench_w_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
    [nav_bench,~] = simulator(rtn_table,bench_w_table,cost_table);
    
    % �������, ����һ������double
    nav_grp = [rtn_table(:,1),array2table(simulated_nav_grp)];
    nav_grp.Properties.VariableNames = ['DATEN' group_names];
    
end


function quantile_grp_weight = quantile_group(x,N_grp)

    % �������Ļ��ֵ�
    q = [-Inf,quantile(x,N_grp-1),Inf]';
    
    % ��ʼ���������
    quantile_grp_weight = zeros(length(x),N_grp);
    
    % ����ѭ��
    for grp=1:N_grp
        
        % ����Ȩ�س�ʼ��
        w = zeros(length(x),1);
       
        % quantile interval����˵���Ҷ˵�
        left_interval = q(grp);
        right_interval = q(grp+1);
        
        % �������Ӧ��interval��û�е㣬��ֻ�����Ҷ˵�������Ǹ���Щ������Ȩ��
        if(all(~(x <= right_interval & x > left_interval)))
            % ����matlab��quantile������˵�յ�interval����û���ұߵĵ�
            
            % �ұ��������Щ����±�
            k_right = right_point(x,right_interval);
            
            % ��Щ���Ȩ��ƽ������
            w(k_right) = 1;
            w = w ./ sum(w);
            
            % �����ֵ
            quantile_grp_weight(:,grp) = w;
            
            % �������iteration
            continue;
        end
        
        % ���ڵĵ��ȶ�����һ����Ȩ��, ����������С���Ǹ�����Щ�����Ȩ�ؿ��������汻�޸�
        w(x <= right_interval & x > left_interval) = 1;
        
        % ���interval����������Ǹ�, ���ҵ�interval֮�����������Ǹ�����Щ����
        % Ȼ����interval���Ǳ�������Ȩ��, ��interval����С���Ǹ�����Щ�㣩����Ȩ��
        if(left_interval>-Inf)
            
            % �õ�interval�������������Ǹ�����±�
            k_left = left_point(x,left_interval);
            
            % ��Щ���ֵ
            x_left = x(k_left(1)); % ��ֹ������غϵ����

            % interval֮����С���Ǹ�����Щ����
            k_left_next = find_next(x,x_left);
            % ��Щ���ֵ
            x_left_next = x(k_left_next(1));  
            
            % ����left_interval����˵㣩��x_left_next��interval����С�ĵ㣩�ľ���
            % ռx_left�������interval����ĵ㣩��x_left_next��interval����С�ĵ㣩�ľ���ı�������Ȩ��
            w(k_left_next) = (x_left_next-left_interval)/(x_left_next-x_left);
        end
        
        if(right_interval<Inf)       
            
            % �õ�interval�ұ�����������Ǹ�����±�
            k_right = right_point(x,right_interval);
            % ��Щ���ֵ
            x_right = x(k_right(1)); % ��ֹ������غϵ����
            
            % interval�������Ǹ�����Щ������±�
            k_right_last = find_last(x,x_right);
            % ��Щ���ֵ
            x_right_last = x(k_right_last(1));
            
            % ����x_right_last��interval�����ĵ㣩��right_interval��interval�Ҷ˵㣩�ľ���
            % ռx_right_last��interval�����ĵ㣩��x_right���ұ���interval����ĵ㣩�ľ���ı�������Ȩ��
            w(k_right) = (right_interval-x_right_last)/(x_right-x_right_last);
        end
        
        % ��һ��       
        w = w ./ sum(w);
        
        % �����Ȩ�ؽ����ֵ
        quantile_grp_weight(:,grp) = w;
        
    end

end

% Ѱ���������������������˵�����ĵ�
function k = left_point(x,left_interval)

    y=x;
    
    if(left_interval>-Inf)
        % ������˵�ĵ㸳ֵΪ-Inf, ����maxȡ�±�
        y(x>left_interval) = -Inf;
        % �������Щ���ֵ
        [mx,~] = max(y);
        % ��Щ����±�
        k = find(x==mx);
    else
        % ����˵���-Inf, ˵��������
        k = NaN;
    end

end

% Ѱ�������Ҷ������������Ҷ˵�����ĵ�
function k = right_point(x,right_interval)

    y=x;
    
    if( right_interval < Inf)
        % С�ڵ����Ҷ˵�ĵ㸳ֵΪInf, ����minȡ�±�
        y(x<=right_interval) = Inf;
        % �������Щ����±�
        [mn,~] = min(y);
        % ��Щ����±�
        k = find(x==mn);
    else
        % ���Ҷ˵���Inf, ˵��������
        k = NaN;
    end

end

% Ѱ��x�д���point����С�㣨���ܲ�ֹһ�������±�
function k = find_next(x,point)

    y = x;
    
    % ������С�ڵ���point�ĵ㸳ֵΪInf�������ʹ��min
    y(x<=point) = Inf;
    
    % �����point���е��е���Сֵ
    [mn,~] = min(y);
    
    % ��Щ����±�
    k = find(x==mn);

end


% Ѱ��x��С��point�����㣨���ܲ�ֹһ�������±�
function k = find_last(x,point)

    y = x;
    
    % �Ѵ��ڵ���point�����е㸳ֵΪ-Inf�������ʹ��max
    y(x>=point) = -Inf;
    
    % ��С��point���е�����ֵ
    [mx,~] = max(y);

    % ��Щ����±�
    k = find(x==mx);
end
