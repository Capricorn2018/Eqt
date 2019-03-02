function s=last_season(t)
% 给定一个yyyymmdd格式的整数格式日期, 算上个季度日期

    yr = floor(t/10000);
    dt = mod(t,10000);
    
    if(dt==331)
        s = round((yr-1)*10000+1231,0);
    else
        if (dt==630)
            s = round(yr*10000+331,0);
        else
            if(dt==930)
                s = round(yr*10000+630,0);
            else
                if(dt==1231)
                    s = round(yr*10000+930,0);
                else
                    s = nan;
                end
            end
        end
    end

end