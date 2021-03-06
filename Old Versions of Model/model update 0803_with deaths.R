# set working directory

setwd("C:/Users/buchwala/Documents/R/COVID")

# load packages

library(deSolve)

# read in Colorado age-group population spreadsheet and age parameter spreadsheet

pop <- read.csv('./pop.csv')
scen <- read.csv('./Model params_0804.csv')

# build SEIR model as an R function

seird <- function(t, x, parms) {
  
  with(as.list(c(parms, x)), {
    
    # change over time in efficacy of % mag SD among specific age groups
    ef1 <- ifelse(t<t2, mag1, ifelse(t<t3, mag2, ifelse(t<t4, mag3, ifelse(t<t4a, mag4, ifelse(t<t5, mag4a,
           ifelse(t<t5a, mag5, ifelse(t<t5b, mag5a, ifelse(t<t6, mag5b, ifelse(t<t6a, mag6,
           ifelse (t<t6b, mag6a, ifelse(t<t6c, mag6b, ifelse(t<t7, mag6c, ifelse(t<t7a, mag7, ifelse (t<t7b, mag7a,
           ifelse(t<ttraj, mag7b, ifelse(t <tproject, traj, ef1_3))))))))))))))))
    ef2 <- ifelse(t<tproject, ef1, ifelse (t<tschool, ef2_2, ef2_3))
    ef3 <- ifelse(t<tproject, ef1, ifelse (t<tschool, ef3_2, ef3_3))
    ef4 <- ifelse(t<tproject, ef1, ifelse (t<tschool, ef4_2, ef4_3))    #ef4 <- ifelse(t<t7, ef1, (ef1*(1-ef4p)) + (ef4p*0.8)) #ef4p is the proportion of adults over 65 practicing high (80%) social distancing
    
    siI <- ifelse (t < t1, 0, siI) ##Turn on symptomatics that self-isolate after 03/05
    ramp <-ifelse(t < 129, 0, ifelse(t<134,(t-129)*ramp, 4.4*ramp)) #For ramp up in case isolation : increases proportion of symptomatic case isoaltion over time
    maska <- ifelse(t< 73, 0, ifelse(t< t4,maska, ifelse (t<t7, maskb, maskc)))
    CT  <- ifelse(t < t7, 0, pCT)
    #temp <- ifelse (t > 1, ifelse(temp_on == 1, temptheory$temp.param[[t]],1), 1)
    temp <-ifelse(temp_on == 1, 0.5*cos((t+45)*0.017)+1.5, 1)
    
    dS1  <-    - (I1+I2+I3+I4)*(beta*temp*(1-(maska*0.03))*lambda*S1*(1-(siI+ramp))*(1-ef1))/N - (beta*temp*S1*(1-(maska*0.2667))*(A1+A2+A3+A4)*(1-ef1))/N 
    dE1  <-    - E1/alpha   + (I1+I2+I3+I4)*(beta*temp*(1-(maska*0.03))*lambda*S1*(1-(siI+ramp))*(1-ef1))/N + (beta*temp*S1*(1-(maska*0.2667))*(A1+A2+A3+A4)*(1-ef1))/N 
    dI1  <- (E1*pS1)/alpha - I1*(gamma) -  I1*pID*CT*kap*pi*om
    dII1 <-                         (I1+A1)*pID*CT*kap*pi*om - II1*gamma
    dIh1 <- I1*hosp1*gamma + II1*pS1*hosp1*gamma - Ih1*1/hlos1
    dA1  <- (E1*(1-pS1))/alpha - A1*gamma - A1*pID*CT*kap*pi*om
    dR1  <- (I1+II1*pS1)*(gamma*(1-hosp1-cc1-dnh1)) + A1*gamma 
    dRh1 <- (1-dh1)*Ih1*1/hlos1

    
    
    dIc <- ((I1+II1*pS1)*cc1 + (I2+II2*pS2)*cc2 + (I3+II3*pS3)*cc3 + (I4+II4*pS4)*cc4)*gamma - min(Ic,cap)*(1/9.2) - max(((Ic + ((I1+II1*pS1)*cc1 + (I2+II2*pS2)*cc2 + (I3+II3*pS3)*cc3 + (I4+II4*pS4)*cc4)*gamma)-cap),0)    
    dRc <- (1 - 0.2439)*min(Ic,cap)*(1/9.2)
    dD  <-      0.2439*min(Ic,cap)*(1/9.2) + max(((Ic + I1*cc1*gamma + I2*cc2*gamma + I3*cc3*gamma + I4*cc4*gamma)-cap),0) + Ih1*dh1*(1/hlos1) + Ih2*dh2*(1/hlos2) + Ih3*dh3*(1/hlos3) + Ih4*dh4*(1/hlos4) + (1/8)*(I1*dnh1 + I2*dnh2 + I3*dnh3 + I4*dnh4)
    
    dS2  <-    - (I1+I2+I3+I4)*(beta*temp*(1-(maska*0.03))*lambda*S2*(1-(siI+ramp))*(1-ef1))/N - (beta*temp*S2*(1-(maska*0.2667))*(A1+A2+A3+A4)*(1-ef1))/N 
    dE2  <-    - E2/alpha   + (I1+I2+I3+I4)*(beta*temp*(1-(maska*0.03))*lambda*S2*(1-(siI+ramp))*(1-ef1))/N + (beta*temp*S2*(1-(maska*0.2667))*(A1+A2+A3+A4)*(1-ef1))/N 
    dI2  <- (E2*pS2)/alpha - I2*(gamma) -  I2*pID*CT*kap*pi*om
    dII2 <-                         (I2+A2)*pID*CT*kap*pi*om - II2*gamma
    dIh2 <- I2*hosp2*gamma + II2*pS2*hosp2*gamma - Ih2*1/hlos2
    dA2  <- (E2*(1-pS2))/alpha - A2*gamma - A2*pID*CT*kap*pi*om
    dR2  <- (I2+II2*pS2)*(gamma*(1-hosp2-cc2-dnh2)) + A2*gamma 
    dRh2 <- (1-dh2)*Ih2*1/hlos2
  
    dS3  <-    - (I1+I2+I3+I4)*(beta*temp*(1-(maska*0.03))*lambda*S3*(1-(siI+ramp))*(1-ef1))/N - (beta*temp*S3*(1-(maska*0.2667))*(A1+A2+A3+A4)*(1-ef1))/N 
    dE3  <-    - E3/alpha   + (I1+I2+I3+I4)*(beta*temp*(1-(maska*0.03))*lambda*S3*(1-(siI+ramp))*(1-ef1))/N + (beta*temp*S3*(1-(maska*0.2667))*(A1+A2+A3+A4)*(1-ef1))/N 
    dI3  <- (E3*pS3)/alpha - I3*(gamma)  - I3*pID*CT*kap*pi*om
    dII3 <-                         (I3+A3)*pID*CT*kap*pi*om - II3*gamma
    dIh3 <- I3*hosp3*gamma + II3*pS3*hosp3*gamma - Ih3*1/hlos3
    dA3  <- (E3*(1-pS3))/alpha - A3*gamma - A3*pID*CT*kap*pi*om
    dR3  <- (I3+II3*pS3)*(gamma*(1-hosp3-cc3-dnh3)) + A3*gamma 
    dRh3 <- (1-dh3)*Ih3*1/hlos3
  
    dS4  <-    - (I1+I2+I3+I4)*(beta*temp*(1-(maska*0.03))*lambda*S4*(1-(siI+ramp))*(1-ef4))/N - (beta*temp*S4*(1-(maska*0.2667))*(A1+A2+A3+A4)*(1-ef4))/N 
    dE4  <-    - E4/alpha   + (I1+I2+I3+I4)*(beta*temp*(1-(maska*0.03))*lambda*S4*(1-(siI+ramp))*(1-ef4))/N + (beta*temp*S4*(1-(maska*0.2667))*(A1+A2+A3+A4)*(1-ef4))/N 
    dI4  <- (E4*pS4)/alpha - I4*(gamma)  - I4*pID*CT*kap*pi*om
    dII4 <-                         (I4+A4)*pID*CT*kap*pi*om - II4*gamma
    dIh4 <- I4*hosp4*gamma + II4*pS4*hosp4*gamma - Ih4*1/hlos4
    dA4  <- (E4*(1-pS4))/alpha - A4*gamma - A4*pID*CT*kap*pi*om
    dR4  <- (I4+II4*pS4)*(gamma*(1-hosp4-cc4-dnh4)) + A4*gamma 
    dRh4 <- (1-dh4)*Ih4*(1/hlos4)
  
    
    
    der <- c(dS1, dE1, dI1, dII1, dIh1, dA1, dR1, dRh1, 
             dIc, dRc, dD,
             dS2, dE2, dI2, dII2, dIh2, dA2, dR2, dRh2, 
             dS3, dE3, dI3, dII3, dIh3, dA3, dR3, dRh3, 
             dS4, dE4, dI4, dII4, dIh4, dA4, dR4, dRh4)
    
    list(der,
         It = I1 + I2 + I3 + I4,
         IIt = II1 + II2 + II3 + II4,
         Iht =Ih1 + Ih2 + Ih3 + Ih4 + Ic
         )
  })
}

#temptheory <- read.csv('./temptheory.csv')

# rows (n) to represent scenario numbers
n <- as.numeric(nrow(scen)) 
covid_ts <- list() # empty data frame to hold the time series data

# run simulations from time 1 to 500, one simulation per scenario row for as many rows as we have

for(i in 1:n){
  # define parameters that will change
  
  parms <- c(beta = scen[i, c('beta')], # transmission rate
             gamma = 1/9,
             alpha = 4,
             Cp = pop[i, c('Cp')], # called back from population spreadsheet
             n1 = pop[i, c('n1')],
             n2 = pop[i, c('n2')],
             n3 = pop[i, c('n3')],
             n4 = pop[i, c('n4')],
             ef1_1 = scen[i,c('ef1_1')],
             ef1_2 = scen[i,c('ef1_2')],
             ef1_3 = scen[i,c('ef1_3')],
             ef4p =  scen[i,c("ef4p")], #proportion of adults over 65 social distancing at 80%
             ef2_1 = scen[i,c('ef2_1')],
             ef2_2 = scen[i,c('ef2_2')],
             ef2_3 = scen[i,c('ef2_3')],
             ef3_1 = scen[i,c('ef3_1')],
             ef3_2 = scen[i,c('ef3_2')],
             ef3_3 = scen[i,c('ef3_3')],
             ef4_1 = scen[i,c('ef4_1')],
             ef4_2 = scen[i,c('ef4_2')],
             ef4_3 = scen[i,c('ef4_3')],
             ef1 = 0,
             ef2 = 0,
             ef3 = 0,
             ef4 = 0,
             dh1 = 0, dh2 = 0, dh3 = 0.0045, dh4 = 0.0923,
             dc1 = 0.0417, dc2 = 0.0392, dc3 = 0.1543, dc4 = 0.3956,
             dnh1 = 0.000072, dnh2 = 0.000129, dnh3 = 0.0011355, dnh4 = 0.030285,
             hlos1 = scen[i,c('hlos1')],
             hlos2 = scen[i,c('hlos2')],
             hlos3 = scen[i,c('hlos3')],
             hlos4 = scen[i,c('hlos4')],
             cap = 1800,
             pS1 = scen[i,c('pS1')], ## proportion of infectious individuals symptomatic (0-19)
             pS2 = scen[i,c('pS2')], ## proportion of infectious individuals symptomatic (20-39)
             pS3 = scen[i,c('pS3')], ## proportion of infectious individuals symptomatic (40-64)
             pS4 = scen[i,c('pS4')], ## proportion of infectious individuals symptomatic (65+)
             pID = scen[i,c('pID')], ## proportion of infections identified
             siI = scen[i,c('siI')],## Proportion of symptomatic individuals self isolate
             lambda = scen[i,c('lambda')], ##difference in infectiousness symptomatic/asymptomatic
             hosp1 = scen[i,c('hosp1')], 
             cc1 = scen[i,c('cc1')],
             hosp2 = scen[i,c('hosp2')], 
             cc2 = scen[i,c('cc2')],
             hosp3 = scen[i,c('hosp3')], 
             cc3 = scen[i,c('cc3')],
             hosp4 = scen[i,c('hosp4')], 
             cc4 = scen[i,c('cc4')],
             mag1 = scen[i, c('mag1')],
             mag2 = scen[i, c('mag2')],
             mag3 = scen[i, c('mag3')],
             mag3a = scen[i, c('mag3a')],
             mag4 = scen[i, c('mag4')],
             mag4a = scen[i, c('mag4a')],
             mag4b = scen[i, c('mag4b')],
             mag5 = scen[i, c('mag5')],
             mag5a = scen[i, c('mag5a')],
             mag5b = scen[i, c('mag5b')],
             mag5c = scen[i, c('mag5c')],
             mag6 = scen[i, c('mag6')],
             mag6a = scen[i, c('mag6a')],
             mag6b = scen[i, c('mag6b')],
             mag6c = scen[i, c('mag6c')],
             mag7 = scen[i, c('mag7')],
             mag7a = scen[i, c('mag7a')],
             mag7b = scen[i, c('mag7b')],
             traj = scen[i, c("traj")],
             t1 = scen[i,c('t1')],
             t2 = scen[i,c('t2')],
             t3 = scen[i,c('t3')],
             t4 = scen[i,c('t4')],
             t4a = scen[i,c('t4a')],
             t5 = scen[i,c('t5')],
             t5a = scen[i,c('t5a')],
             t5b = scen[i,c('t5b')],
             t6 = scen[i,c('t6')],
             t6a = scen[i,c('t6a')],
             t6b = scen[i,c('t6b')],
             t6c = scen[i,c('t6c')],
             t6d = scen[i,c('t6d')],
             t7 = scen[i,c('t7')], 
             t7a = scen[i,c('t7a')],
             t7b = scen[i,c('t7b')],
             ttraj = scen[i,c('ttraj')], ###Changes weekly to two weeks before fitting date
             tproject = scen[i,c('tproject')], ###changes weekly to Friday after fitting date
             tpa = scen[i,c('tpa')],
             tschool = scen[i,c('tschool')],
             ramp = scen[i,c('ramp')],
             maska = scen[i,c('maska')],
             maskb = scen[i,c('maskb')],
             maskc = scen[i,c('maskc')], #proportion wearing masks for projections
             kap = scen[i,c("kap")], #average number of contacts traced per detected case
             pCT = scen[i,c("pCT")], #proportion of identified cases with contacts traced
             pi = scen[i,c("pi")], #probability a contact traced infected individual is isolated before infecting other susceptibles 
             om = scen[i,c("om")], #probability a contact traced individual is infected
             temp_on = scen[i,c("temp_on")]
  )
  
  dt      <- seq(0, 500, 1)
  
  inits      <- c(S1 = pop$n1 - 1, E1 = 0, I1 = 1, II1 = 0, Ih1 = 0, A1 = 0, R1 = 0, Rh1 = 0, Ic = 0, Rc = 0, D = 0,
                  S2 = pop$n2,     E2 = 0, I2 = 0, II2 = 0, Ih2 = 0, A2 = 0, R2 = 0, Rh2 = 0,
                  S3 = pop$n3,     E3 = 0, I3 = 0, II3 = 0, Ih3 = 0, A3 = 0, R3 = 0, Rh3 = 0,
                  S4 = pop$n4,     E4 = 0, I4 = 0, II4 = 0, Ih4 = 0, A4 = 0, R4 = 0, Rh4 = 0 )
  N  <- pop$Cp
  
  
  out <- lsoda(inits, dt, seird, parms = parms)
  covid_ts[[i]] <- as.matrix(out)
}

#library(dplyr)
all <-  as.data.frame(cbind(rep(1:n, each=501), do.call("rbind", covid_ts)))
all$scenario <- all$V1
all$V1 <- NULL

all.scen <- merge(scen, all, by = "scenario")
#all.scen.temp <- merge(all.scen, temp, by = "time")

write.csv(all.scen, './allscenarios_0804_deaths.csv', row.names = F)

# create incrementing date vector of length 500 for all scenarios

all.scen$date <- seq(from = as.Date("2020/1/24"), to = as.Date("2020/1/24") + 500, "days")

