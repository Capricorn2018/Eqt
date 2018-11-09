
clear;clc;

project_path       = 'D:\Projects\Eqt'; 
cd(project_path); addpath(genpath(project_path));

%%
input_data_path    = 'D:\Capricorn';
output_data_path   = 'D:\Capricorn\model';

tic;
[p,a] = set_risk_model(project_path,input_data_path,output_data_path);
toc;
T = length(p.model.model_trading_dates);
%%
load('D:\Capricorn\model\risk\backtest\regression\regression_stats_Index0.mat');


f = factor_rtn_matrix(:,2:end);

risk_factors = [p.model.ind_names.Eng',p.style'];

for i  = 3318: T
%     c = cov(f(i-252:i,:));
%     save(['D:\Capricorn\model\risk\cov\Index0_',datestr(p.model.model_trading_dates(i),29),'.mat'],'c','risk_factors')
     
      load ([a.reggression,'\','Index',num2str(0),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],...
                     'factor_rtn','pre_reg','bm_weight_sector','bm_weight_stk','residuals','mdl'); 
                 
      stks = residuals.Properties.RowNames;
      [id,loc]  = ismember(p.model.stk_codes1,stks);
      
      q = residuals;
      q.spk =  nanstd( res_rtn_matrix(i-252:i,id),[],1)';
      q.Raw = [];
      save(['D:\Capricorn\model\risk\spk\Index0_',datestr(p.model.model_trading_dates(i),29),'.mat'],'q')
end
%%

T = length(p.model.model_trading_dates);
r2 = zeros(T,1);
load('D:\Capricorn\model\risk\backtest\regression\regression_stats_Index1.mat');
factor_rtn_matrix(isnan(factor_rtn_matrix))  = 0;
plot(cumprod(1 + factor_rtn_matrix(:,1))); hold on
plot(p.model.indexlev.(['index',num2str(1)])/1000)

for i  = 1: T
     load ([a.reggression,'\','Index',num2str(0),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'mdl'); 
     r2(i,1) = mdl.Rsquared.Ordinary;
end


