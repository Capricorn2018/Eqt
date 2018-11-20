function k = deblank_stk(c)
      k  = cell(length(c),1);
      for i  = 1 : length(c)
        k{i,1} = deblank(c{i,1});
      end
end