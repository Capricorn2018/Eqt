function [a,p,stk_status_table,is_suspended_table,...
              rtn_table,freecap_table,sectors_table,rebalance_dates] = set_single_test(start_dt)
% �����Ӽ���������

    %%
%     a.project_path       = 'D:\Projects\Eqt'; 
%     cd(a.project_path); addpath(genpath(a.project_path));
    %%

    a.single_test.base_data  = 'D:\Capricorn\fdata\base_data';
    a.single_test.descriptors   = 'D:\Capricorn\descriptors';

    a.single_test.style = 'D:\Capricorn\model\risk\style'; % ��ȡrisk model��style/sector factor��·��
    a.single_test.regression = 'D:\Capricorn\model\risk\regression'; % ��ȡrisk model��regression�����·��
    a.single_test.dfquant_risk = 'D:\Capricorn\model\dfquant_risk'; % ��ȡ����֤ȯrisk model�����·��

    %%
    p.all_trading_dates_ = h5read([a.single_test.base_data,'\securites_dates.h5'],'/date');     
    p.all_trading_dates  = datenum_h5 (h5read([a.single_test.base_data,'\securites_dates.h5'],'/date'));  
    p.stk_codes_         = h5read([a.single_test.base_data,'\securites_dates.h5'],'/stk_code'); 
    p.stk_codes          = stk_code_h5(h5read([a.single_test.base_data,'\securites_dates.h5'],'/stk_code')); 

    % ת����SH600018���ָ�ʽ
    p.single_test.stk_codes    = p.stk_codes;
    x = [];
    for k = 1 : length(p.single_test.stk_codes)
        z = cell2mat(p.single_test.stk_codes(k));
        x = [x,cellstr(z([8:9,1:6]))]; %#ok<AGROW>
    end
    p.single_test.stk_codes1 = x;
    %%
    %%
    % ��Ҫ����ĵ����Ӵ洢���ļ���
%     tgt_file = 'hl_21-1.h5';
%     tgt_tag = get_tag([a.single_test.descriptors,'\',tgt_file]);

    % ��ȡ��Ȩ�۸��
    price_table = h5_table(a.single_test.base_data,'stk_prices.h5','adj_prices');
    rtn_table = price2rtn(price_table); % �Ӹ�Ȩ�۸����return, ��ͣ���յ��쳣��Ϊ0

    % ��ȡ��Ʊ����״̬
    stk_status_table = h5_table(a.single_test.base_data,'stk_status.h5','stk_status');
    is_suspended_table = h5_table(a.single_test.base_data,'suspended.h5','is_suspended');

    % ���쳣���ΪNaN
    rtn_table = del_suspended(rtn_table,stk_status_table,is_suspended_table);

    % ���е�trading dates
    trading_dates = p.all_trading_dates_;
    trading_dates = datenum(trading_dates,'yyyymmdd');

    %% ѡ�������ʼ�յ��±�ͼ�� %%
    rebalance_dates = trading_dates(trading_dates>=start_dt);
    [rebalance_dates,~] = find_month_dates(1,rebalance_dates,'first'); % ÿ���µĵ�һ��������

    % ��ȡmarkcap
    freecap_table = h5_table(a.single_test.base_data,'free_shares.h5','free_cap');

    % ��ȡ��Ӧ����������
    % style_table = h5_table(a.single_test.descriptors,tgt_file,tgt_tag);
    % ���쳣�����ո�ΪNaN
    % style_table = del_suspended(style_table,stk_status_table,is_suspended_table);

    % ��ȡ��Ӧ������һ����ҵ����
    sectors_table = h5_table(a.single_test.base_data,'citics_stk_sectors_all.h5','citics_stk_sectors_1');
end

