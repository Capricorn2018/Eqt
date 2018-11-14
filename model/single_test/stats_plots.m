for grp = 1:N_grp

    eval(['nav_grp_',num2str(grp),'=nav_grp(:,',num2str(grp+1),');']);
    cum_rtn = eval(['nav_grp_',num2str(grp)]);
    cum_rtn = table2array(cum_rtn);

    plot(cum_rtn);
    hold on;
end

hold off;