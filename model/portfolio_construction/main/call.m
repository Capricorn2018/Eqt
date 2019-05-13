% 需要做优化的日期序列
rebalance_dates % 这个也应该是从setting文件里面导入

% 先确定universe
% 从excel或是什么数据源读取每日universe
universe % 这个存在一个list里面, 要对应到每个rebalance_dates

% 然后确定需要的alpha因子文件
% alpha因子的名称, 可以在存参数的表里面再弄一个因子名称和文件地址的映射表
factor_names = {'ep_lyr'}; 

% 按日循环算weights
portfolio_const