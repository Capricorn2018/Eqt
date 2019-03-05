% 三张表取历史pit数据, 并且拆单季数据
% start_dt = '20041231';
% end_dt = '20190201';
% n_rpt = 21;
% type = 'balance';
function []=do_pit(start_dt, end_dt, n_rpt, type)

    % balancesheet
    if(strcmp(type,'balancesheet'))
        out_path = 'D:/Projects/pit_data/mat/balancesheet/';
        data_file = 'D:/Projects/pit_data/origin_data/asharebalancesheet.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_asharebalancesheet.csv';
        data = preprocessing(data_file,sample_file);
        %load('D:/Projects/pit_data/origin_data/asharebalancesheet.mat');
        pit_reports(data, start_dt, end_dt, n_rpt, out_path, false);
    end

    % income
    if(strcmp(type,'income'))
        out_path = 'D:/Projects/pit_data/mat/income/';
        data_file = 'D:/Projects/pit_data/origin_data/ashareincome.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_ashareincome.csv';
        data = preprocessing(data_file,sample_file);        
        %load('D:/Projects/pit_data/origin_data/ashareincome.mat');
        pit_reports(data, start_dt, end_dt, n_rpt,out_path, true);
    end

    % cashflow
    if(strcmp(type,'cashflow'))
        out_path = 'D:/Projects/pit_data/mat/cashflow/';
        data_file = 'D:/Projects/pit_data/origin_data/asharecashflow.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_asharecashflow.csv'; 
        data = preprocessing(data_file,sample_file);
        %load('D:/Projects/pit_data/origin_data/asharecashflow.mat');
        pit_reports(data, start_dt, end_dt, n_rpt, out_path, true);
    end
    
    % capitalization
    if(strcmp(type,'capitalization'))
        out_path = 'D:/Projects/pit_data/mat/capitalization/';
        data_file = 'D:/Projects/pit_data/origin_data/asharecapitalization.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_asharecapitalization.csv'; 
        data = readtable(data_file,'TreatAsEmpty','\N','ReadVariableNames',false,'FileEncoding','UTF-8');
        sample = readtable(sample_file,'TreatAsEmpty','\N','FileEncoding','UTF-8');
        data.Properties.VariableNames = sample.Properties.VariableNames;
        %load('D:/Projects/pit_data/origin_data/asharecapitalization.mat');
        pit_capital(data, start_dt, end_dt, out_path);
    end
    
    % eodprices
    if(strcmp(type,'eodprices'))
        out_path = 'D:/Projects/pit_data/mat/eodprices/';
        data_file = 'D:/Projects/pit_data/origin_data/ashareeodprices.txt';
        sample_file = 'D:/Projects/pit_data/origin_data/sample_ashareeodprices.csv'; 
        data = readtable(data_file,'TreatAsEmpty','\N','ReadVariableNames',false,'FileEncoding','UTF-8');
        sample = readtable(sample_file,'TreatAsEmpty','\N','FileEncoding','UTF-8');
        data.Properties.VariableNames = sample.Properties.VariableNames;
        %load('D:/Projects/pit_data/origin_data/ashareeodprices.mat');
        pit_close(data, start_dt, end_dt, out_path);
    end
    
end