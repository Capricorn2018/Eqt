% 需要做优化的日期序列
p.rebalance_dates % 这个也应该是从setting文件里面导入

% 先确定universe
% 从excel或是什么数据源读取每日universe
p.universe % 这个存在一个list里面

% 然后确定需要的alpha因子文件
p.alpha_names = {'ep_lyr'}; % 这里就用文件名，最好是以后从setting文件里面导入


% 按日循环算weights
portfolio_construction