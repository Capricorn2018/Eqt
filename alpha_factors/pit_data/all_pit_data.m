% 三张表取历史pit数据, 并且拆单季数据
% start_dt = '20041231';
% end_dt = '20190201';
% n_rpt = 21;
% type = 'balancesheet';
function []=all_pit_data(start_dt, end_dt, n_rpt, type)

    % balancesheet
    if(strcmp(type,'balancesheet'))
        out_path = 'D:/Projects/pit_data/mat/balancesheet';
        data_file = 'D:/Projects/pit_data/origin_data/asharebalancesheet.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_asharebalancesheet.csv';
        data = preprocessing(data_file,sample_file);
        pit_reports(data, start_dt, end_dt, n_rpt, out_path, false);
        save('D:/Projects/pit_data/origin_data/asharebalancesheet.mat','data');
    end

    % income
    if(strcmp(type,'income'))
        out_path = 'D:/Projects/pit_data/mat/income';
        data_file = 'D:/Projects/pit_data/origin_data/ashareincome.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_ashareincome.csv';
        data = preprocessing(data_file,sample_file);
        pit_reports(data, start_dt, end_dt, n_rpt,out_path, true);
        save('D:/Projects/pit_data/origin_data/ashareincome.mat','data');
    end

    % cashflow
    if(strcmp(type,'cashflow'))
        out_path = 'D:/Projects/pit_data/mat/cashflow';
        data_file = 'D:/Projects/pit_data/origin_data/asharecashflow.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_asharecashflow.csv'; 
        data = preprocessing(data_file,sample_file);        
        pit_reports(data, start_dt, end_dt, n_rpt, out_path, true);
        save('D:/Projects/pit_data/origin_data/asharecashflow.mat','data');
    end
    
    % capitalization
    if(strcmp(type,'capitalization'))
        out_path = 'D:/Projects/pit_data/mat/capitalization';
        data_file = 'D:/Projects/pit_data/origin_data/asharecapitalization.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_asharecapitalization.csv'; 
        data = readtable(data_file,'TreatAsEmpty','\N','ReadVariableNames',false,'FileEncoding','UTF-8');
        sample = readtable(sample_file,'TreatAsEmpty','\N','FileEncoding','UTF-8');
        data.Properties.VariableNames = sample.Properties.VariableNames;        
        pit_capital(data, start_dt, end_dt, out_path);
        save('D:/Projects/pit_data/origin_data/asharecapitalization.mat','data');
    end
    
    % eodprices
    if(strcmp(type,'eodprices'))
        out_path = 'D:/Projects/pit_data/mat/eodprices';
        data_file = 'D:/Projects/pit_data/origin_data/ashareeodprices.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_ashareeodprices.csv'; 
        data = readtable(data_file,'TreatAsEmpty','\N','ReadVariableNames',false,'FileEncoding','UTF-8');
        sample = readtable(sample_file,'TreatAsEmpty','\N','FileEncoding','UTF-8');
        data.Properties.VariableNames = sample.Properties.VariableNames;
        
        %pit_close(data, start_dt, end_dt, out_path);
        
        x = load('D:/Projects/pit_data/origin_data/asharecapitalization.mat');
        cap = x.data;
        data = outerjoin(data,cap,'LeftKeys',{'s_info_windcode','trade_dt'},'RightKeys',{'s_info_windcode','change_dt'},'RightVariables',{'float_a_shr'});
        
        data = sortrows(data,{'s_info_windcode','trade_dt'},{'descend','ascend'});
        data.float_a_shr = fill_shr(data.s_info_windcode,data.float_a_shr);
        
        dt = data.trade_dt;
        yr = floor(dt/10000);
        mt = floor((dt-yr*10000)/100);
        dy = dt-yr*10000-mt*100;
        data.DATEN = datenum(yr,mt,dy);
        
        tradestatus = data.s_dq_tradestatus;
        tradestatus = unique(tradestatus);
        status_map = table();
        status_map.tradestatus = tradestatus;
        status_map.tradestatus_num = (1:height(status_map))';
        data = outerjoin(data, status_map,'LeftKeys',{'s_dq_tradestatus'},'RightKeys',{'tradestatus'});
        
        colnames = {'s_info_windcode', ...
                        'DATEN', ...
                        'trade_dt', ...
                        's_dq_preclose', ...
                        's_dq_open', ...
                        's_dq_high', ...
                        's_dq_low', ...
                        's_dq_close', ...
                        's_dq_change', ...
                        's_dq_pctchange', ...
                        's_dq_volume', ...
                        's_dq_amount', ...
                        's_dq_adjpreclose', ...
                        's_dq_adjopen', ...
                        's_dq_adjhigh', ...
                        's_dq_adjlow', ...
                        's_dq_adjclose', ...
                        's_dq_adjfactor', ...
                        's_dq_avgprice', ...
                        'tradestatus_num'};
          
        data = data(:,colnames);
        
        data.s_dq_pctchange(data.s_dq_amount==0) = NaN;
        
        stk_codes = data.s_info_windcode;
        code_map = table();
        code_map.stk_codes = unique(stk_codes);
        code_map.stk_num = (1:height(code_map))';
        data = join(data,code_map,'LeftKeys',{'s_info_windcode'},'RightKeys',{'stk_codes'});
        Lia = ismember(data.Properties.VariableNames,{'s_info_windcode','stk_codes'});
        data = data(:,~Lia); %#ok<NASGU>
        
        save('D:/Projects/pit_data/origin_data/ashareeodprices.mat','data','code_map','status_map');
    end
    
end


function y = fill_shr(stk_codes,cap)

    y = nan(length(cap),1);

    [~,ia,ic] = unique(stk_codes);
    
    for i=1:length(ia)
        
        flag = (ic == ia(i));
        
        f = cap(flag);
        
        y(flag) = fillnan(f);
        
    end
    
end
