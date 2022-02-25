
setwd("C:/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk/Do Files/P-val correction")
load("Adjust.RData")
###############################################
###############################################/

#Internal Standardization ENDLINE# 

# Load and prepare data
#----------------------

## Distribtuion of nulls 

cog_null_mat<- data.matrix(read.csv(file="C:/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk/Output/Tables/pvalues/NullDist_rw_fooddiv1.csv", 
                                    header=TRUE, sep=","))

## Actual T stats ## 

cog_t_mat<- data.matrix(read.csv(file="C:/Users/lucy_k/Dropbox/IFS/CDGP_analysis/15 paper_lk/Output/Tables/pvalues/ActualTs_rw_fooddiv1.csv", 
                                    header=TRUE, sep=","))

main_impacts<-p.val.adj(cog_t_mat, cog_null_mat)
#write.csv(main_impacts, "C:/Dropbox/ECD Analysis/Midline EPP/Data/RW distributions/wppsi_subscales.csv")

