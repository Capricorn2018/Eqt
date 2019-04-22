% ���ű�ȡ��ʷpit����, ���Ҳ𵥼�����
% start_dt = '20041231';
% end_dt = '20190201';
% n_rpt = 21;
% type = 'balance';
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
        
        pit_close(data, start_dt, end_dt, out_path);
        
        x = load('D:/Projects/pit_data/origin_data/asharecaitalization.mat');
        cap = x.data;
        data = join(data,cap,'Keys',{'s_info_windcode'},'RightVariables',{'float_a_shr'});
        
        data.s_dq_pctchange(data.s_dq_amount==0) = NaN;
        stk_codes = data.s_info_windcode;
        code_map = table();
        code_map.stk_codes = unique(stk_codes);
        code_map.stk_num = (1:height(code_map))';
        data = join(data,code_map,'LeftKeys',{'s_info_windcode'},'RightKeys',{'stk_codes'});
        Lia = ismember(data.Properties.VariableNames,{'s_info_windcode','stk_codes'});
        data = data(:,~Lia); %#ok<NASGU>
        
        save('D:/Projects/pit_data/origin_data/ashareeodprices.mat','data','code_map');
    end
    
end