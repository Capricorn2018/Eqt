clear;clc;
project_path       = 'D:\Projects\Eqt'; 
cd(project_path); addpath(genpath(project_path));
%%
s = h5read('D:\Capricorn\fdata\base_data\citics_stk_sectors_all.h5','/citics_stk_sectors_3')';
%s1 = h5read('D:\Capricorn\fdata\base_data\citics_stk_sectors_all.h5','/citics_stk_sectors_1')';
x = readtable('D:\Projects\Eqt\files\sectors.xlsx');
free_cap  = h5read('D:\Capricorn\fdata\base_data\free_shares.h5','/free_cap')'*10000/100000000;
stk_status    = h5read('D:\Capricorn\fdata\base_data\stk_status.h5','/stk_status')';     
s = s.*stk_status;
free_cap = free_cap.*stk_status;
%%
risk_sector  = sort(unique(x.Risk));
alpha_sector  = sort(unique(x.Alpha));

sector_table = cell(length(risk_sector),1+1+length(x.Risk)-length(risk_sector));
sector_code  = NaN(length(risk_sector),length(risk_sector));
tmp = zeros(length(risk_sector),1);
for i  = 1 : length(risk_sector)
    sector_table{i,2} = risk_sector{i,1};
    id = find(strcmp(x.Risk,risk_sector{i,1}));
    tmp(i,1) = length(id);
    sector_table{i,1} = x.Alpha(id(1));
    for j = 1 : length(id)
        sector_table{i,2+j} = x.l3(id(j));
        sector_code(i,j) = x.l3num(id(j));
    end
end
writetable(cell2table(sector_table), [project_path,'\files\sector_table.csv'],'WriteVariableNames',false);
writetable(array2table(sector_code),[project_path,'\files\sector_codes.csv'],'WriteVariableNames',false);
%%
all_trading_dates = datenum_h5 (h5read('D:\Capricorn\fdata\base_data\securites_dates.h5','/date'));    
T = length(all_trading_dates);
stk_codes         = stk_code_h5(h5read('D:\Capricorn\fdata\base_data\securites_dates.h5','/stk_code'));  
N = length(stk_codes);

[freecap_count,numb_count] = deal(zeros(T,length(unique(x.l3num))));
all_lv3 = sort(unique(x.l3num));

coutfun = @(x)(sum(x>0));
for i  = 1 : T
    [G,R] = findgroups(s(i,:));
    freecap_count(i,ismember(all_lv3,R)) = splitapply(@nansum,free_cap(i,:),G);
    numb_count(i,ismember(all_lv3,R)) = splitapply(coutfun,free_cap(i,:),G);
end
%%
idx  = all_trading_dates>datenum(2005,1,1);
freecap_count = freecap_count(idx,:); freecap_count(freecap_count==0)=NaN;
numb_count = numb_count(idx,:);numb_count(numb_count==0)=NaN;

stats = zeros(length(risk_sector),4);


for i  = 1 : length(risk_sector)
    x1 = sector_code(i,:);
    x2 = x1(~isnan(x1));
    idx = ismember(all_lv3,x2);
    stats(i,1)  = mean(nansum(freecap_count(:,idx),2));
    stats(i,2)  = nansum(freecap_count(end,idx));
    stats(i,3)  = mean(nansum(numb_count(:,idx),2));
    stats(i,4)  = nansum(numb_count(end,idx));
end

mkdir_('D:\Projects\Eqt\files\tmp');
H = [table(risk_sector),array2table(stats)];
H.Properties.VariableNames ={'sector','avg_size','current_size','avg_numb','current_numb'};
writetable(H,[project_path,'\files\tmp\sectors_stat.csv']);

K = table(stk_codes,s(end,:)',free_cap(end,:)');
writetable(K,[project_path,'\files\tmp\test.csv']);