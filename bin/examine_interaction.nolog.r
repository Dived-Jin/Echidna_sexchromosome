checkmdan <- function(dfs,tups){
	KLs = c()
	VLs = c()
	for (loc in tups){
		LocVdf = dfs[dfs$V8==loc,]
		LocV = LocVdf$V7
		if (length(LocV) >5){
			KLs = c(KLs,loc)
			addv = median(LocV)
			VLs = c(VLs,addv)
		}
	}
	dfm = data.frame(KLs,VLs)
	sortdfm = order(dfm$VLs)
	dfmsor = dfm[sortdfm,]
	ind=length(dfmsor$KLs)
	rechr1 = dfmsor$KLs[ind]
	rechrme1 = dfmsor$VLs[ind]
	if (ind >=2){
		rechr2 = dfmsor$KLs[ind-1]
		rechrme2 = dfmsor$VLs[ind-1]
	}else{
		
		rechr2 = "None"
		rechrme2 = 0
	}
	return(c(rechr1,rechr2,rechrme1,rechrme2))
}

ReadMark<- function(files){
	dta = read.table(files,sep="\t",h=F)
	reLs = dta$V1
	return(reLs)
}



args = commandArgs(T)
library(ggplot2)
library(ggsignif)

dat = read.table(args[1],h=F)
pdf(args[2], w=15,h=8)
Kfile1=args[3]
Kfile2=args[4]
imkey=args[5]

atuoLs=ReadMark(Kfile1)
AutouseLs=checkmdan(dat,atuoLs)
atuochr=AutouseLs[1]
atuochrm=AutouseLs[3]
SexLs=ReadMark(Kfile2)
SexKeyls=checkmdan(dat,SexLs)
SexMax = SexKeyls[1]
sexScen = SexKeyls[2]
sexMaxM = SexKeyls[3]
sexScenM = SexKeyls[4]
if (sexScen=="None"){
	comlis = list(c(atuochr,SexMax))
}else{
	comlis = list(c(atuochr,SexMax),c(SexMax,sexScen))
}
AtuoMaxdf=dat[dat$V8==atuochr,]
AtuoMaxdf_ls = AtuoMaxdf$V7
SexMaxdf=dat[dat$V8==SexMax,]
SexMaxdf_ls = SexMaxdf$V7
res <- wilcox.test(SexMaxdf_ls,AtuoMaxdf_ls, alternative ="greater")
pv1 = res$p.value
if ( sexScen != "None"){
	SexScendf = dat[dat$V8==sexScen,]
	SexScendf_ls = SexScendf$V7
	res1 <- wilcox.test(SexMaxdf_ls,SexScendf_ls, alternative ="greater")
	pv2 = res1$p.value
	print(paste(imkey,SexMax,sexMaxM,sexScen,sexScenM,atuochr,atuochrm,pv1,pv2,sep=" "))
}else{
	print(paste(imkey,SexMax,sexMaxM,"None","None",atuochr,atuochrm,pv1,"None",sep=' '))
}

ggplot(dat, aes(x=V8, y=V7)) + geom_violin(width=1,outlier.shape = NA) + labs(x='region', y='interaction(log10)') + theme(panel.background = element_rect(fill = "white"),axis.line.x=element_line(colour="black"),axis.line.y=element_line(colour="black")) + coord_cartesian(ylim=c(-2, 2))+theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))+geom_signif(comparisons=comlis,step_increase= 0.1,map_signif_level = F,test = t.test) + geom_boxplot(width=0.3)

dev.off()
