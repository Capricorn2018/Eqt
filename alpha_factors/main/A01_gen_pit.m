% 三张表取历史pit数据, 并且拆单季数据
start_dt = '20041231';
end_dt = '20190201';
n_rpt = 21;

type = 'balancesheet';
all_pit_data(start_dt, end_dt, n_rpt, type);

type = 'income';
all_pit_data(start_dt, end_dt, n_rpt, type);

type = 'cashflow';
all_pit_data(start_dt, end_dt, n_rpt, type);

type = 'capitalization';
all_pit_data(start_dt, end_dt, n_rpt, type);

type = 'eodprices';
all_pit_data(start_dt, end_dt, n_rpt, type);