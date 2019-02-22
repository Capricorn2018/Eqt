function data = preprocessing(data_file,sample_file)
% data = readtable('D:/Projects/pit_data/origin_data/asharebalancesheet.txt','TreatAsEmpty','\N','ReadVariableNames',false);
% sample = readtable('D:/Projects/pit_data/origin_data/sample_asharebalancesheet.csv','TreatAsEmpty','\N');

    data = readtable(data_file,'TreatAsEmpty','\N','ReadVariableNames',false);
    sample = readtable(sample_file,'TreatAsEmpty','\N');
    
    data.Properties.VariableNames = sample.Properties.VariableNames;
    
    ss = get_season(data.report_period);
    
    data.season = ss;
    data = data(ss~=0,:);
    
end

function ss = get_season(report_period)

    dt = mod(report_period,10000); % ÈÕÆÚ
    
    ss = zeros(size(report_period,1),1);
    ss(dt==331) = 1;
    ss(dt==630) = 2;
    ss(dt==930) = 3;
    ss(dt==1231)= 4;    

end

