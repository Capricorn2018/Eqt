% 三张表取历史pit数据, 并且拆单季数据
start_dt = '20181228';
end_dt = '20190201';
n_rpt = 21;

% balancesheet
% out_path = 'D:/Projects/pit_data/mat/balancesheet/';
% data_file = 'D:/Projects/pit_data/origin_data/asharebalancesheet.txt';
% sample_file = 'D:/Projects/pit_data/origin_data/sample_asharebalancesheet.csv';
% data = preprocessing(data_file,sample_file);
% pit_data(data, start_dt, end_dt, n_rpt, out_path, false);

% income
out_path = 'D:/Projects/pit_data/mat/income/';
data_file = 'D:/Projects/pit_data/origin_data/ashareincome.txt';
sample_file = 'D:/Projects/pit_data/origin_data/sample_ashareincome.csv';
data = preprocessing(data_file,sample_file);
pit_data(data, start_dt, end_dt, n_rpt,out_path, true);

% cashflow
% out_path = 'D:/Projects/pit_data/mat/cashflow/';
% data_file = 'D:/Projects/pit_data/origin_data/asharecashflow.txt';
% sample_file = 'D:/Projects/pit_data/origin_data/sample_asharecashflow.csv';
% data = preprocessing(data_file,sample_file);
% pit_data(data, start_dt, end_dt, n_rpt, out_path, true);