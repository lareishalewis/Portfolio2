library(tidyverse)
library(pwr)
library(dplyr)

#1.Power curve of a t-test with a fixed sample size of 25.
es <- NULL
es <- seq(.1,1.5,.1)
pwr.out <- NULL


for(i in 1:length(es)) {
  pwr_out_test <- pwr.t.test(d=es[i],n=25,sig.level=.05,type="two.sample")$power
  pwr_eff_data <- data.frame(pwr=pwr_out_test,effect_size=es[i])
  pwr.out <- rbind(pwr.out,pwr_eff_data)
}


ggplot(pwr.out,aes(effect_size,pwr))+
  geom_line()+
  geom_point()+
  theme_bw()+
  geom_hline(yintercept = .8,lty=2,col="red")+
  labs(title="Power vs Effect Size, Sample Size=25",
       subtitle = "Two sample t-test",
       x="Effect Size",
       y="Power")
#2.Power curve of a t-test with a fixed sample size of 100

effect.size <-NULL
effect.size <- seq(.1,2.0,.1)
pwr.out <- NULL


for(i in 1:length(effect.size)) {
  pwr.out.test1 <- pwr.t.test(d=effect.size[i],n=100,sig.level=.05,type="two.sample")$power
  data_pwr_eff <- data.frame(pwr=pwr.out.test1,effect_size=effect.size[i])
  pwr.out <- rbind(pwr.out,data_pwr_eff)
}


ggplot(pwr.out,aes(effect_size,pwr))+
  geom_line()+
  geom_point()+
  theme_bw()+
  geom_hline(yintercept = .8,lty=2, col="red")+
  labs(title="Power vs Effect Size, Sample Size=100",
       subtitle = "Two sample t-test",
       x="Effect Size",
       y="Power")

#3.Generate a power curve for a 2 proportion test with a fixed sample size of 30
pwr.2p.test(h=.5,n=30,sig.level=0.05)

effect = NULL
effect <- seq(.1, 1.5, .1)
power.output <- NULL

for(i in 1:length(effect)) {
  pwrout <- pwr.2p.test(h=effect[i],n=30,sig.level=0.05)$power
  dataset_pwr <- data.frame(pwr=pwrout,effect.size=effect[i])
  power.output <- rbind(power.output,dataset_pwr)
}

ggplot(power.output,aes(effect.size,pwr))+
  geom_line(color= "red")+
  geom_point()+
  theme_bw()+
#  geom_hline(yintercept = .8,lty=2, col="red")+
  labs(title="Effect Size vs Power, Sample Size= 30",
       subtitle="Two Proportions",
       x="Effect Size",
       y="Power")
#4.Generate a power curve for a 2 proportion test with a fixed sample size of 50
pwr.2p.test(h=.5,n=50,sig.level=0.05)

effect <- NULL
effect <- seq(.1, 1.5, .1)
power.output <- NULL

for(i in 1:length(effect)) {
  pwr_output <- pwr.2p.test(h=effect[i],n=50,sig.level=0.05)$power
  pwrData <- data.frame(pwr=pwr_output,effect.size=effect[i])
  power.output <- rbind(power.output,pwrData)
}

ggplot(power.output,aes(effect.size,pwr))+
  geom_line(color= "blue")+
  geom_point()+
  theme_bw()+
  geom_hline(yintercept = .8,lty=2,col="red")+
  labs(title="Effect Size vs Power, Sample Size= 50",
       subtitle="Two Proportions",
       x="Effect Size",
       y="Power")

#5.Generate and interpret the power curve for a t-test with a fixed sample size of 50 per group, power of 80% for values of the significance
#level between 0.01 and 0.10.

effect.size <- seq(.2,1.5,.1)
sig.levelseq= NULL
sig.levelseq <- seq(.01,.10,.03)
pwr.out.1 <- NULL


for(i in 1:length(effect.size)) {
  for(j in 1:length(sig.levelseq)) {
    testpwr.out <- pwr.t.test(d=effect.size[i], 
                           n=50,
                           sig.level=sig.levelseq[j],
                           type="two.sample")$power
    out1 <- data.frame(cohen.d = effect.size[i],
                       sig_level = sig.levelseq[j],
                       power=testpwr.out)
    pwr.out.1 <- rbind(pwr.out.1, out1)
  }
}   
ggplot(pwr.out.1,aes(cohen.d,power,group=sig_level,color=as.factor(sig_level)))+
  geom_line()+
  geom_point()+
  theme_bw()+
  geom_hline(yintercept = .8,lty=2, col="red")+
  labs(title="Power vs Effect Size, Sample Size=50",
       subtitle = "Two sample t-test",
       x="Effect Size",
       y="Power")

#6.Generate and interpret the power curve for a two proportion test with a fixed sample size of 60 per group, power 
#of 80% for values of the significance level between 0.01 and 0.10.

effect.size <- seq(.2,1.5,.1)
sig.levelseq= NULL
sig.levelseq <- seq(.01,.10,.03)
pwr.out.2 <- NULL


for(i in 1:length(effect.size)) {
  for(j in 1:length(sig.levelseq)) {
    testpwr.out.2 <- pwr.2p.test(h=effect.size[i], 
                              n=60,
                              sig.level=sig.levelseq[j])$power
    out1 <- data.frame(h.effect = effect.size[i],
                       sig_level = sig.levelseq[j],
                       power=testpwr.out.2)
    pwr.out.2 <- rbind(pwr.out.2, out1)
  }
}   
ggplot(pwr.out.2,aes(h.effect,power,group=sig_level,color=sig_level))+
  geom_line()+
  geom_point()+
  scale_color_viridis_c()+
  geom_hline(yintercept = .8,lty=2, col="red")+
  labs(title="Power vs Effect Size, Sample Size=60",
       x="Effect Size",
       y="Power")

#7.Generate and interpret the power curve for a t-test with power of 80%, effect size of 0.7 
#for values of the significance level between 0.01 and 0.10.


sig.levelseq1= NULL
sig.levelseq1 <- seq(.01,.10,.01)
sample.out.1 <- NULL


for(i in 1:length(sig.levelseq1)) {
    testss.out <- pwr.t.test(d=0.7, 
                              sig.level=sig.levelseq1[i],
                              power=.80,
                              type="two.sample")$n
    out1 <- data.frame(sig_level = sig.levelseq1[i],
                       samp.size=testss.out)
    sample.out.1 <- rbind(sample.out.1, out1)
  }
   
ggplot(sample.out.1,aes(sig_level,samp.size))+
  geom_line(color="red")+
  geom_point(color="blue")+
  theme_bw()+
  labs(title="Sample Size vs Significance Level, effect size= 0.7",
       subtitle = "Two sample t-test",
       x="Significance Level",
       y="Sample Size")+
  theme(plot.title=element_text(face="bold", color="blue"))+
  theme(axis.text.x = element_text(color = 'blue'))+
  theme(axis.text.y = element_text(color = 'blue'))
