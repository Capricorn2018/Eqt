a.data = 'D:/Capricorn/fdata';
a.output_data_path = 'D:/Projects/pit_data/mat/alpha_factors/XY';
a.input_data_path = 'D:/Projects/pit_data/mat/alpha_factors';

%%  模型的基准;T和N，都由securites_dates.h5 来决定
p.all_trading_dates_ = h5read([a.data,'\base_data\securites_dates.h5'],'/date');
p.all_trading_dates = datenum_h5 (h5read([a.data,'\base_data\securites_dates.h5'],'/date'));      T = length(p.model.all_trading_dates);
p.stk_codes_         = h5read([a.data,'\base_data\securites_dates.h5'],'/stk_code'); 
p.stk_codes          = stk_code_h5(h5read([a.data,'\base_data\securites_dates.h5'],'/stk_code')); 

asset_turnover(a,p);

bp_lr(a,p);

cash2profit(a,p);

cashyield_ttm(a,p);

costs2sales(a,p);

% current_ratio(a,p);

% debt2equity(a,p);

ep_lyr(a,p);

ep_sq(a,p);

ep_ttm(a,p);

gross_margin(a,p);

oper_margin(a,p);

oper_profit_yoy(a,p);

oper_rev_ltg(a,p);

oper_rev_yoy(a,p);

profit_ltg(a,p);

profit_yoy(a,p);

roa_ttm(a,p);

roe_ttm(a,p);

% sales2ev(a,p);

sp_ttm(a,p);
