function X = replace_nan_to_z(X,z)
      t = table2array(X);
      t(isnan(t)) = z;
      
      X = array2table(t,'RowNames',X.Properties.RowNames,'VariableNames',X.Properties.VariableNames);
end