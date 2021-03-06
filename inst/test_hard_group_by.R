library(data.table)
library(magrittr)
library(future)
library(fst)
library(disk.frame)

#nworkers = parallel::detectCores(logical=F)
nworkers = parallel::detectCores()
plan(multiprocess, workers = nworkers, gc = T)
options(future.globals.maxSize=Inf)

ramlim = 15*1024^3
# sort by algorithm
shardby = "acct_id"
N = 1e7
K = 100
tmpdir = "tmphardgroupby"
dir.create(tmpdir)
pt = proc.time()
system.time(future_lapply(1:(nworkers*3), function(ii) {
  dt = data.table(
    acct_id = sample(sprintf("id%010d",1:(N/K)), N, TRUE), # small groups (char)
    v3 =  sample(round(runif(100,max=100),4), N, TRUE) # numeric e.g. 23.5749
  )
  
  write.fst(dt, file.path(tmpdir, paste0(ii, ".fst")), 100)
  # do not let write.fst be the last as it return the full data
  gc()
  NULL
}))
cat(timetaken(pt),"\n")

df <- disk.frame("tmphardgroupby")




