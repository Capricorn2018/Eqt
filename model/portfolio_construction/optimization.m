% ���㴿�������Ȩ��, ����style�ı�¶��1, risk factor����ҵ��¶��Ϊ0����С�������
%%
% ��ֻ����һ��ָ���ɷַ�Χ��������, ��ֻ��Ҫ��style_table�е�����Ʊ����ΪNaN����
%% ����
% ���и�����, ����style�ǵ���������̬��, risk factorsȴ����risk֮ǰ��ȫ�г���Χ������̬��
%%
function weight_table = optimization(a,p,rebalance_dates,risk_factor_names)
% rebalance_datesĬ����matlab����������

    % ��ʼ��weight
    weight = nan(length(rebalance_dates),length(p.optimization.stk_codes));    
    weight_table = [array2table(rebalance_dates),array2table(weight)];
    weight_table.Properties.VariableNames = ['DATEN',p.optimization.stk_codes1];
    
    % ����ѭ��
    for i=1:length(rebalance_dates)
        
       % �����ַ���
       date = datestr(rebalance_dates(i),'yyyy-mm-dd'); 
       % a.regression�Ƕ�ȡ�ع����þ�����ļ��е�ַ
       % ��ʱ����D:\Capricorn\model\risk\regression\
       filename = [a.optimization.regression,'\Index0_',date,'.mat'];
       
       % �ж��ļ��Ƿ����
       if(exist(filename,'file')==2)
           load(filename);
       else
           disp([filename,': not exist']);
           continue;
       end
       
       % try catch���⵱�ն�Ӧ�ķ������Ӳ�����
       try
           risk_factors = table2array(pre_reg(:,risk_factor_names));  %#ok<NODEF>
           factor_rtn = table2array(factor_rtn(1,risk_factor_names));
       catch
           disp('risk_factor_names: some factors are not in pre_reg or factor_rtn')
           continue;
       end
       
       % �����𹤷������������ļ���, ����py��������
       % cov����D;\Capricorn\model\dfquant_risk\cov\��
       % risk factors����D:\Capricorn\model\dfquant_risk\factors\��
       % spec����D:\Capricorn\model\dfquant_risk\spec��
       % �����ַ�������yyyymmdd��ʽ
       date = datestr(rebalance_dates(i),'yyyymmdd'); 
       cov_filename = [a.optimization.dfquant_risk,'\cov\cov_',date,'.csv'];
       factor_filename = [a.optimization.dfquant_risk,'\factors\risk_factors_',date,'.csv'];
       spec_filename = [a.optimization.dfquant_risk,'\spec\spec_',date,'.csv'];
       
       if(exist(cov_filename,'file')==2 && exist(factor_filename,'file')==2 && exist(spec_filename,'file')==2)
           cov = readtable(cov_filename);
           spec = readtable(spec_filename);
           factors = readtable(factor_filename);
           
           % �Ѷ����������е������ƴ�����ת��SH600018���ָ�ʽ
           stk_num = factors(2:end,1);
           stk_num = table2array(stk_num);
           stk_codes = df_stk_codes(stk_num);
           
           % ����������
           cov = table2array(cov(3:end,3:end));
           spec = table2array(spec(:,2));
           factors = table2array(factors(2:end,3:end));
           
           tbl_factors = array2table(factors,'RowNames',stk_codes);
           tbl_spec = array2table(spec,'RowNames',stk_codes);
           
           
       else
           disp('dfquant_risk: ', cov_filename,', ',factor_filename,', ',spec_filename,', do not exist')
           continue;
       end
       
       
       if(all(any(isnan(risk_factors),2)))
           disp('risk_factors are all nan');
           continue;
       end       
       
       % ���ջع�����еĹ�Ʊ����
       stk_codes = pre_reg.Properties.RowNames;
       
       % ��stk_codes�������𹤵����ӱ�¶����������������indexing
       factors = tbl_factors(stk_codes,:);
       factors = table2array(factors);
       spec = tbl_spec(stk_codes,1);
       spec = table2array(spec);
       
       % �Ż�������
       exp_bound = zeros(size(cov,1),1);
       active_bound = ones(size(factors,1),1) * 0.02;
       lambda = 20;
       
       % ����Ҫ����alpha_factors�͵��ռ����alpha_factor_rtn
       alpha_factors = risk_factors;
       alpha_factor_rtn = factor_rtn;
       
       %%                                         %%
       %% load_alpha(date,stk_codes,alpha_folder) %%
       %%                                         %%
       
       weight_table(i,stk_codes) = array2table(portfolio_construction(lambda,alpha_factors,alpha_factor_rtn',...
                                                                          cov,factors,spec,exp_bound,active_bound)');
        
       disp(date);
    end
        
end


% ���ļ���ȡ����alpha_factors��alpha_factor_rtn(��������Ȩ�أ�
function [alpha_factors,alpha_weight] = load_alpha(date,stk_codes,alpha_folder) %#ok<DEFNU>
    
    filename = [alpha_folder,'/alpha_',date,'.mat'];
    load(filename); % ��ȡ����alpha, ��alpha_weight
    
    alpha_stk = alpha.stk_codes; %#ok<NODEF>
    
    for i=1:length(alpha_stk)
        
        alpha_stk{i} = alpha_stk{i}(1:6); % ȡǰ6λ����
        
    end
    
    alpha_stk = df_stk_codes(alpha_stk);
    
    alpha_factors = nan(length(stk_codes),size(alpha,2));
    
    [Lia,Locb] = ismember(alpha_stk,stk_codes);
    alpha_factors(Locb(Locb>0),:) = alpha(Lia,:);
    
    if ~exist(alpha_weight,'var') %#ok<NODEF>
        N = size(alpha,2);
        flag = nan(1,N);
        for j = 1:N
            flag(j) = true;
            if all(isnan(alpha(:,j)))
                N = N-1;
                flag(j) = false;
            end
        end
        alpha_weight = ones(size(alpha,2),1)/N;
        alpha_weight(~flag) = 0;
    end
    
end


% ����alpha���ӱ�¶, ��������, �������ӱ�¶, ��������cov, ���ʷ�������
% ����exposure bound�����ӱ�¶������, active_bound����ֻ��Ʊƫ���׼����
% �Ż����
function weight = portfolio_construction(lambda, alpha_factors, alpha_factors_rtn,...
                                            factor_cov, exposure, spk, exp_bound, active_bound)
% lambda: �������ϵ��
% alpha_factors: alpha���ӱ�¶���� alpha_factors_rtn: ��Ӧ��alpha������������
% factor_cov, exposure, spk: ����ģ���е�����cov, ���ӱ�¶����, �����������
% exp_bound��ÿ���������ӱ�¶��������, active_bound: ��ֻ��Ʊƫ���׼������������
    
    weight = zeros(length(spk),1); % �����ʼ��
    
    % ȥ��nan
    not_nan = ~any(isnan(exposure),2) & ~isnan(spk) & ~any(isnan(alpha_factors),2);
    exposure = exposure(not_nan,:);
    spk = spk(not_nan);
    alpha_factors = alpha_factors(not_nan,:);
    
    active_bound = active_bound(not_nan);
        
    % ��ȡ��Ч�����ӱ�¶constraints, ��Щ���ӿ��ܲ�����
    bound_idx = exp_bound<Inf;
    bound_mtx = exposure(:,bound_idx); % constraints�еı�¶����
    bound = exp_bound(bound_idx); % ��Ӧ��constraint��������
    

    % ���ﻹҪ����ȥNaN        
    n = length(spk); %#ok<NASGU>
    cvx_begin
        variable x(n)
        maximize(alpha_factors_rtn' * alpha_factors' * x - lambda * quad_form(exposure' * x,factor_cov) - lambda * sum(spk .* x .* x))
        subject to
        	%x >= 0; %#ok<VUNUS>
            sum(x) == 0; %#ok<EQEFF>
            -bound <= bound_mtx' * x <= bound; %#ok<VUNUS>
            -active_bound <= x <= active_bound; %#ok<VUNUS>
    cvx_end

    weight(not_nan) = x;

end

% �Ӷ����𹤵�ģ�ͽ���ж�ȡ�Ĺ�Ʊ����תΪSH600018���ָ�ʽ
function stk_codes = df_stk_codes(stk_num)

    stk_codes = cell(length(stk_num),1);
    for i=1:length(stk_num)
        stk_str = num2str(stk_num(i));
        if(length(stk_str)<6)
            stk_str = [repmat('0',1,8-length(stk_str)),stk_str]; %#ok<AGROW>
            stk_str(1:2) = 'SZ';
        else
            if(stk_str(1)=='6' || stk_str(1)=='T') % ���и�T00018���ϸۼ����������, ��������������Ӧ��ûӰ��
                stk_str = ['SH',stk_str]; %#ok<AGROW>
            else
                stk_str = ['SZ',stk_str]; %#ok<AGROW>
            end
        end
        stk_codes(i) = {stk_str};
    end

end

