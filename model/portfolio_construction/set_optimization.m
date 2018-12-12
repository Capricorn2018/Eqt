function [a,p,rebalance_dates] = set_optimization(start_dt)
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
        %%
%     a.project_path       = 'D:\Projects\Eqt'; 
%     cd(a.project_path); addpath(genpath(a.project_path));
    %%
    
    a.optimization.base_data  = 'D:\Capricorn\fdata\base_data';
    
    a.optimization.style = 'D:\Capricorn\model\risk\style'; % ��ȡrisk model��style/sector factor��·��
    a.optimization.regression = 'D:\Capricorn\model\risk\regression'; % ��ȡrisk model��regression�����·��
    a.optimization.dfquant_risk = 'D:\Capricorn\model\dfquant_risk'; % ��ȡ����֤ȯrisk model�����·��

    %%

    % ת����SH600018���ָ�ʽ
    p.optimization.stk_codes    = stk_code_h5(h5read([a.optimization.base_data,'\securites_dates.h5'],'/stk_code'));
%     x = [];
%     for k = 1 : length(p.optimization.stk_codes)
%         z = cell2mat(p.optimization.stk_codes(k));
%         x = [x,cellstr(z([8:9,1:6]))]; %#ok<AGROW>
%     end
    p.optimization.stk_codes1 = stkcodes2colnames(p.optimization.stk_codes);
    %%
    %%
    
    p.optimization.all_trading_dates_ = h5read([a.optimization.base_data,'\securites_dates.h5'],'/date');     
    p.optimization.all_trading_dates  = datenum_h5 (h5read([a.optimization.base_data,'\securites_dates.h5'],'/date'));  
    
    % ���е�trading dates
    trading_dates = p.optimization.all_trading_dates;

    %% ѡ�������ʼ�յ��±�ͼ�� %%
    rebalance_dates = trading_dates(trading_dates>=start_dt);
    [rebalance_dates,~] = find_month_dates(1,rebalance_dates,'first'); % ÿ���µĵ�һ��������
    
    
    % ����CVX��Mosek
    cvx_solver Mosek;
    javaaddpath 'D:\Program Files\Mosek\8\tools\platform\win64x86\bin\mosekmatlab.jar'

end

