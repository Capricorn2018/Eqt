################## preprocessing

#data <- read.csv('D:/Projects/pit_data/origin_data/asharebalancesheet.txt',sep='\t',na.strings='\\N',header=F)

#sample <- read.csv('D:/Projects/pit_data/origin_data/sample_asharebalancesheet.csv')

#colnames(data) <- colnames(sample)

#data <- data[!is.na(data$actual_ann_dt) & !is.na(data$s_info_windcode) & !is.na(data$report_period),]

#data$s_info_windcode <- as.character(data$s_info_windcode)

################## end

calender <- w.tdays("2004-12-31","2018-12-31")
calender <- calender$Data$DATETIME
yr <- substr(calender,1,4)
mth <- substr(calender,6,7)
dy <- substr(calender,9,10)
calender <- paste(yr,mth,dy,sep='')
calender <- as.integer(calender)

dt <- calender[1]
n_rpt <- 20

data <- data[!is.na(data$actual_ann_dt) & !is.na(data$report_period) & !is.na(data$s_info_windcode),]
data$rank_rpt <- rep(0,nrow(data))
data$rank_ann <- rep(0,nrow(data))

data_last <- data[data$actual_ann_dt<=dt,]

idx <- order(data_last$s_info_windcode, data_last$report_period, data_last$actual_ann_dt,decreasing=F)

data_last <- data_last[idx,]

rownames(data_last) <- 1:nrow(data_last)

rank_rpt <- by(data_last,data_last$s_info_windcode,FUN=function(x) nrow(x)+1-rank(x$report_period,ties.method = 'max',na.last=F))
if(typeof(rank_rpt)=='list'){
  rank_rpt <- do.call(c,rank_rpt)
}
#rank_rpt <- rank_rpt[!is.na(rank_rpt)]

rank_ann <- by(data_last,list(data_last$report_period,data_last$s_info_windcode),FUN=function(x) nrow(x)+1-rank(x$actual_ann_dt,ties.method = 'max',na.last=F))
if(typeof(rank_ann)=='list'){  
  rank_ann <- do.call(c,rank_ann)
}
#rank_ann <- rank_ann[!is.na(rank_ann)]

data_last$rank_rpt <- rank_rpt
data_last$rank_ann <- rank_ann

data_last <- data_last[data_last$rank_rpt <= n_rpt & data_last$rank_ann==1,]

#save('data_last',file=paste('D:/Projects/pit_data/data_last/pit_data_',dt,'.RData',sep=''))
write.csv(data_last,
          file=paste('D:/Projects/pit_data/data_last/pit_data_',dt,'.csv',sep=''))

########################

s <- Sys.time()

for (i in 2:length(calender)){
  
  dt <- calender[i]
  
  update <- data[data$actual_ann_dt==dt,]
  
  if(nrow(update)>0){
  
    update_tickers <- levels(as.factor(update$s_info_windcode))
    
    is_in <- data_last$s_info_windcode %in% update_tickers
    
    tmp_data <- rbind(data_last[is_in,],update)
    
    idx <- order(tmp_data$s_info_windcode, tmp_data$report_period, tmp_data$actual_ann_dt,decreasing=F)
    
    tmp_data <- tmp_data[idx,]
    
    rank_rpt <- by(tmp_data,tmp_data$s_info_windcode,FUN=function(x) nrow(x)+1-rank(x$report_period,ties.method = 'max',na.last=F))
    if(typeof(rank_rpt)=='list'){
      rank_rpt <- do.call(c,rank_rpt)
    }
    #rank_rpt <- rank_rpt[!is.na(rank_rpt)]
    
    rank_ann <- by(tmp_data,list(tmp_data$report_period,tmp_data$s_info_windcode),FUN=function(x) nrow(x)+1-rank(x$actual_ann_dt,ties.method = 'max',na.last=F))
    if(typeof(rank_ann)=='list'){
       rank_ann <- do.call(c,rank_ann)
    }
    #rank_ann <- rank_ann[!is.na(rank_ann)]
    
    tmp_data$rank_rpt <- rank_rpt
    tmp_data$rank_ann <- rank_ann
    
    data_next <- rbind(data_last[!is_in,],tmp_data)
    
    data_last <- data_next
  
  }
  
  #save('data_last',file=paste('D:/Projects/pit_data/data_last/pit_data_',dt,'.RData',sep=''))
  write.csv(data_last,
            file=paste('D:/Projects/pit_data/data_last/pit_data_',dt,'.csv',sep=''))
  
  
  print(dt)
}

e <- Sys.time()

print(e-s)







