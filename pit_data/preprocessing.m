function data = preprocessing(data_file,sample_file)
% data = readtable('D:/Projects/pit_data/asharebalancesheet.txt','TreatAsEmpty','\N','ReadVariableNames',false);
% sample = readtable('D:/Projects/pit_data/origin_data/sample_asharebalancesheet.csv','TreatAsEmpty','\N');

    data = readtable(data_file,'TreatAsEmpty','\N','ReadVariableNames',false);
    sample = readtable(sample_file,'TreatAsEmpty','\N');

    data.Properties.VariableNames = sample.Properties.VariableNames;
end

