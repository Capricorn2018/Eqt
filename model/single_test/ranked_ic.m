function cor = ranked_ic(style, r)

    not_nan = (~isnan(style)) & (~isnan(r));
    
    style = style(not_nan);
    r = r(not_nan);

    cor = corr(style,r,'type','Kendall');

end