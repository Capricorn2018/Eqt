function  t = get_tag(file_name)


   f = h5info(file_name);
   for i  = 1 :length(f.Datasets)
      x = deblank(f.Datasets(i).Name);
      if (~strcmp(x,'date'))&&(~strcmp(x,'stk_code'))
          t = x; 
          return;
      end
   end
   
end



