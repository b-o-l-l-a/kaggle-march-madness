setwd("/Users/gbolla/Desktop/personal-git-projects/kaggle-march-madness/")
#install.packages('e1071')
#install.packages('dplyr')
#install.packages('reshape')
#install.packages('randomForest')
#install.packages('ROCR')

library(lattice)
library(e1071)
library(dplyr)
library(reshape)
library(randomForest)
library(ROCR)

teams <- read.csv("data/Teams.csv")
reg.season.compact <- read.csv("data/RegularSeasonCompactResults.csv")
reg.season.detailed <- read.csv("data/RegularSeasonDetailedResults.csv")
sample.submission <- read.csv("data/SampleSubmissionStage2.csv")
seasons <- read.csv("data/Seasons.csv")
tourney.compact <- read.csv("data/NCAATourneyCompactResults.csv")
tourney.detailed <- read.csv("data/NCAATourneyDetailedResults.csv")
seeds <- read.csv("data/NCAATourneySeeds.csv")
slots <- read.csv("data/NCAATourneySlots.csv")
coaches <- read.csv("data/TeamCoaches.csv")
conferences <- read.csv("data/TeamConferences.csv")
#massey.ordinals.2019 <- read.csv("data/MasseyOrdinals2019.csv")
massey.ordinals.historical <- read.csv("data/MasseyOrdinalsHistorical.csv")
#massey.ordinals.historical <- rbind(massey.ordinals.2019, massey.ordinals.historical)
#reg.season.2017 <- read.csv("Data/.csv")


cat("================================", "\n", "Regular Season Compact Data","\n","================================")
head(reg.season.compact, n = 20)

cat("================================", "\n", "Regular Season Detailed Data","\n","================================")
head(reg.season.detailed, n = 20)

cat("================================", "\n", "Season Data","\n","================================")
head(seasons, n = 20)

cat("================================", "\n", "Tourney Compact Data","\n","================================")
head(tourney.compact, n = 20)

cat("================================", "\n", "Tourney Detailed Data","\n","================================")
head(tourney.detailed, n = 20)

cat("================================", "\n", "Seeds Data","\n","================================")
head(seeds, n = 20)

cat("================================", "\n", "Slots Data","\n","================================")
head(slots, n = 20)

cat("================================", "\n", "Teams Data","\n","================================")
head(teams, n = 20)

cat("================================", "\n", "Coaches Data","\n","================================")
head(coaches, n = 20)

cat("================================", "\n", "Conference Data","\n","================================")
head(conferences, n = 20)

cat("================================", "\n", "Massey Ordinals 2019 Data","\n","================================")
head(massey.ordinals.historical[massey.ordinals.historical$Season == 2019], n = 20)

cat("================================", "\n", "Massey Ordinals Historical Data","\n","================================")
head(massey.ordinals.historical, n = 20)

#cat("================================", "\n", "2017 Season","\n","================================")
#head(reg.season.2017, n = 20)

#cat("================================", "\n", "Sample Submission","\n","================================")
#head(sample.submission, n = 20)



# ==============================
# Extract Season Long Averages 
# ==============================
aggregated.cols <- c("Score", "FGM", "FGA", "FGM3", "FGA3", "FTM", "FTA", "OR", "DR", "Ast", "TO", "Stl", "Blk", "PF")

detailed.seasons <- c(2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019) 


output.df <- data.frame(year       = integer(),
                        team.id    = integer(),
                        team.name  = character(),
                        conference = character(),
                        coach      = character(),
                        massey.avg = numeric(),
                        massey.imp = numeric(),
                        opp.massey.avg = numeric(),
                        Score.pg   = numeric(),
                        FGM.pg     = numeric(),
                        FGA.pg     = numeric(),
                        FGM3.pg    = numeric(),
                        FGA3.pg    = numeric(),
                        FTM.pg     = numeric(),
                        FTA.pg     = numeric(),
                        OR.pg      = numeric(),
                        DR.pg      = numeric(),
                        Ast.pg     = numeric(),
                        TO.pg      = numeric(),
                        Stl.pg     = numeric(),
                        Blk.pg     = numeric(),
                        PF.pg      = numeric(),
                        Score.se   = numeric(),
                        FGM.se     = numeric(),
                        FGA.se     = numeric(),
                        FGM3.se    = numeric(),
                        FGA3.se    = numeric(),
                        FTM.se     = numeric(),
                        FTA.se     = numeric(),
                        OR.se      = numeric(),
                        DR.se      = numeric(),
                        Ast.se     = numeric(),
                        TO.se      = numeric(),
                        Stl.se     = numeric(),
                        Blk.se     = numeric(),
                        PF.se      = numeric(),
                        Score.skew   = numeric(),
                        FGM.skew     = numeric(),
                        FGA.skew     = numeric(),
                        FGM3.skew    = numeric(),
                        FGA3.skew    = numeric(),
                        FTM.skew     = numeric(),
                        FTA.skew     = numeric(),
                        OR.skew      = numeric(),
                        DR.skew      = numeric(),
                        Ast.skew     = numeric(),
                        TO.skew      = numeric(),
                        Stl.skew     = numeric(),
                        Blk.skew     = numeric(),
                        PF.skew      = numeric(), 
                        
                        opp.Score.pg   = numeric(),
                        opp.FGM.pg     = numeric(),
                        opp.FGA.pg     = numeric(),
                        opp.FGM3.pg    = numeric(),
                        opp.FGA3.pg    = numeric(),
                        opp.FTM.pg     = numeric(),
                        opp.FTA.pg     = numeric(),
                        opp.OR.pg      = numeric(),
                        opp.DR.pg      = numeric(),
                        opp.Ast.pg     = numeric(),
                        opp.TO.pg      = numeric(),
                        opp.Stl.pg     = numeric(),
                        opp.Blk.pg     = numeric(),
                        opp.PF.pg      = numeric(),       
                        opp.Score.se   = numeric(),
                        opp.FGM.se     = numeric(),
                        opp.FGA.se     = numeric(),
                        opp.FGM3.se    = numeric(),
                        opp.FGA3.se    = numeric(),
                        opp.FTM.se     = numeric(),
                        opp.FTA.se     = numeric(),
                        opp.OR.se      = numeric(),
                        opp.DR.se      = numeric(),
                        opp.Ast.se     = numeric(),
                        opp.TO.se      = numeric(),
                        opp.Stl.se     = numeric(),
                        opp.Blk.se     = numeric(),
                        opp.PF.se      = numeric(), 
                        opp.Score.skew   = numeric(),
                        opp.FGM.skew     = numeric(),
                        opp.FGA.skew     = numeric(),
                        opp.FGM3.skew    = numeric(),
                        opp.FGA3.skew    = numeric(),
                        opp.FTM.skew     = numeric(),
                        opp.FTA.skew     = numeric(),
                        opp.OR.skew      = numeric(),
                        opp.DR.skew      = numeric(),
                        opp.Ast.skew     = numeric(),
                        opp.TO.skew      = numeric(),
                        opp.Stl.skew     = numeric(),
                        opp.Blk.skew     = numeric(),
                        opp.PF.skew      = numeric()          
                        )

for (team in 1:length(teams$TeamID)) {
#for (team in 1:15) {
  team.id <- teams[team, "TeamID"]
  team.name <- teams[teams$TeamID == team.id,]["TeamName"]
  
  print(paste("***** Calculating year-long stats for", team.name[,1], " *****"))
  
  for (year in 1:length(detailed.seasons)) {
    print(paste("Starting", detailed.seasons[year]))
    year.df <- reg.season.detailed[reg.season.detailed$Season == detailed.seasons[year],]
    massey.year.df <- massey.ordinals.historical[massey.ordinals.historical$Season == detailed.seasons[year],]
    #if (detailed.seasons[year] == 2019) {last_day <- 128} else {last_day <- 154}
    last_day <- 154
    coach <- coaches[(coaches$Season == detailed.seasons[year]) & (coaches$TeamID == team.id) & (coaches$LastDayNum == last_day),]["CoachName"]
    
    if (nrow(subset(year.df, subset = WTeamID == team.id | LTeamID == team.id)) > 0 
        && (nrow(subset(year.df, subset = WTeamID == team.id)))  > 0) {
      
      conference <- conferences[(conferences$TeamID == team.id) & (conferences$Season == detailed.seasons[year]),]["ConfAbbrev"]
      year.df.by.team <- subset(year.df, subset = WTeamID == team.id | LTeamID == team.id)  
      year.df.by.team["opp.TeamID"] <- ifelse(year.df.by.team$WTeamID == team.id, year.df.by.team$LTeamID, year.df.by.team$WTeamID)
      year.df.by.team["opp.massey.avg"] <- by(year.df.by.team, 1:nrow(year.df.by.team), function(row) {
        mean(massey.year.df[massey.year.df$TeamID == row$opp.TeamID, "OrdinalRank"])
        })
      opp.massey.avg <- mean(year.df.by.team$opp.massey.avg)
      row <- vector(mode = "list", length = length(aggregated.cols))
      
      for (col in 1:length(aggregated.cols)){
        avg.output.row.name <- paste(aggregated.cols[col], ".pg", sep="")
        se.output.row.name <- paste(aggregated.cols[col], ".se", sep="")
        skew.output.row.name <- paste(aggregated.cols[col], ".skew", sep="")
        opp.avg.output.row.name <- paste("opp.",aggregated.cols[col], ".pg", sep="")
        opp.se.output.row.name <- paste("opp.",aggregated.cols[col], ".se", sep="")
        opp.skew.output.row.name <- paste("opp.",aggregated.cols[col], ".skew", sep="")        
      
        win.stat.name <- paste("W", aggregated.cols[col], sep="")
        lose.stat.name <- paste("L", aggregated.cols[col], sep="")

      ## calc all stats for the team          
        win.stat  <-  aggregate(formula(bquote(.(as.name(win.stat.name))~WTeamID)),  subset(year.df.by.team, WTeamID == team.id), sum)[,win.stat.name]
        ifelse(nrow(subset(year.df, subset = LTeamID == team.id))  > 0, 
               lose.stat <- aggregate(formula(bquote(.(as.name(lose.stat.name))~LTeamID)), subset(year.df.by.team, LTeamID == team.id), sum)[,lose.stat.name],
               lose.stat <- 0)
        stat.pg <- (win.stat + lose.stat) / nrow(year.df.by.team)
        row[avg.output.row.name] <- stat.pg
        
        ## measure variance and skewness of each stat
        win.stat.list <- year.df.by.team[year.df.by.team$WTeamID == team.id ,win.stat.name]
        ifelse(nrow(subset(year.df, subset = LTeamID == team.id))  > 0,
                stat.list <- c(win.stat.list, year.df.by.team[year.df.by.team$LTeamID == team.id ,lose.stat.name]),
                stat.list <- win.stat.list
        )
        
        row[se.output.row.name] <- sqrt(var(stat.list))
        row[skew.output.row.name] <- skewness(stat.list)
      ## calc all stats for the opposing team   
        ifelse(nrow(subset(year.df, subset = LTeamID == team.id))  > 0, 
               opp.win.stat.sum <- sum(aggregate(formula(bquote(.(as.name(win.stat.name))~WTeamID)),  subset(year.df.by.team, LTeamID == team.id), sum)[,win.stat.name]),
               opp.win.stat.sum <- 0
        )
        
        opp.lose.stat.sum <- sum(aggregate(formula(bquote(.(as.name(lose.stat.name))~LTeamID)), subset(year.df.by.team, WTeamID == team.id), sum)[,lose.stat.name])
        opp.stat.pg <- (opp.win.stat.sum + opp.lose.stat.sum) / nrow(year.df.by.team)
        row[opp.avg.output.row.name] <- opp.stat.pg
        
        opp.lose.stat.list <- year.df.by.team[year.df.by.team$WTeamID == team.id ,lose.stat.name]
        ifelse(nrow(subset(year.df, subset = LTeamID == team.id))  > 0,
               opp.stat.list <- c(opp.lose.stat.list, year.df.by.team[year.df.by.team$LTeamID == team.id ,win.stat.name]), 
               opp.stat.list <- opp.lose.stat.list
        )
        row[opp.se.output.row.name] <- sqrt(var(opp.stat.list))
        row[opp.skew.output.row.name] <- skewness(opp.stat.list)      
      }
      
      massey.team.df       <- massey.year.df[massey.year.df$TeamID == team.id,]
      if (nrow(massey.team.df) > 0) {
        mid.season.massey.df <- massey.team.df[(massey.team.df$RankingDayNum < 45) & (massey.team.df$RankingDayNum > 15),]
        end.season.massey.df <- massey.team.df[massey.team.df$RankingDayNum >= 100,]
        start.massey.rating  <- mean(mid.season.massey.df[,"OrdinalRank"])
        end.massey.rating    <- mean(end.season.massey.df[,"OrdinalRank"])
        massey.improvement   <- start.massey.rating - end.massey.rating
      } else { 
        start.massey.rating <- NA
        end.massey.rating <- NA
        massey.improvement <- NA
      }
      
      output.df <- rbind(output.df, data.frame(
        year       = detailed.seasons[year],
        team.id    = team.id,
        team.name  = team.name,
        conference = conference,
        coach      = coach,
        massey.avg = end.massey.rating,
        massey.imp = massey.improvement,
        opp.massey.avg = opp.massey.avg,
        Score.pg   = row$Score.pg,
        FGM.pg     = row$FGM.pg,
        FGA.pg     = row$FGA.pg,
        FGM3.pg    = row$FGM3.pg,
        FGA3.pg    = row$FGA3.pg,
        FTM.pg     = row$FTM.pg,
        FTA.pg     = row$FTA.pg,
        OR.pg      = row$OR.pg,
        DR.pg      = row$DR.pg,
        Ast.pg     = row$Ast.pg,
        Stl.pg     = row$Stl.pg,
        TO.pg      = row$TO.pg,
        Blk.pg     = row$Blk.pg,
        PF.pg      = row$PF.pg,
        Score.se   = row$Score.se,
        FGM.se     = row$FGM.se,
        FGA.se     = row$FGA.se,
        FGM3.se    = row$FGM3.se,
        FGA3.se    = row$FGA3.se,
        FTM.se     = row$FTM.se,
        FTA.se     = row$FTA.se,
        OR.se      = row$OR.se,
        DR.se      = row$DR.se,
        Ast.se     = row$Ast.se,
        Stl.se     = row$Stl.se,
        TO.se      = row$TO.se,
        Blk.se     = row$Blk.se,
        PF.se      = row$PF.se,
        Score.skew   = row$Score.skew,
        FGM.skew     = row$FGM.skew,
        FGA.skew     = row$FGA.skew,
        FGM3.skew    = row$FGM3.skew,
        FGA3.skew    = row$FGA3.skew,
        FTM.skew     = row$FTM.skew,
        FTA.skew     = row$FTA.skew,
        OR.skew      = row$OR.skew,
        DR.skew      = row$DR.skew,
        Ast.skew     = row$Ast.skew,
        Stl.skew     = row$Stl.skew,
        TO.skew      = row$TO.skew,
        Blk.skew     = row$Blk.skew,
        PF.skew      = row$PF.skew,
## Now add opponent's summary statistics        
        opp.Score.pg   = row$opp.Score.pg,
        opp.FGM.pg     = row$opp.FGM.pg,
        opp.FGA.pg     = row$opp.FGA.pg,
        opp.FGM3.pg    = row$opp.FGM3.pg,
        opp.FGA3.pg    = row$opp.FGA3.pg,
        opp.FTM.pg     = row$opp.FTM.pg,
        opp.FTA.pg     = row$opp.FTA.pg,
        opp.OR.pg      = row$opp.OR.pg,
        opp.DR.pg      = row$opp.DR.pg,
        opp.Ast.pg     = row$opp.Ast.pg,
        opp.Stl.pg     = row$opp.Stl.pg,
        opp.TO.pg      = row$opp.TO.pg,
        opp.Blk.pg     = row$opp.Blk.pg,
        opp.PF.pg      = row$opp.PF.pg,
        opp.Score.se   = row$opp.Score.se,
        opp.FGM.se     = row$opp.FGM.se,
        opp.FGA.se     = row$opp.FGA.se,
        opp.FGM3.se    = row$opp.FGM3.se,
        opp.FGA3.se    = row$opp.FGA3.se,
        opp.FTM.se     = row$opp.FTM.se,
        opp.FTA.se     = row$opp.FTA.se,
        opp.OR.se      = row$opp.OR.se,
        opp.DR.se      = row$opp.DR.se,
        opp.Ast.se     = row$opp.Ast.se,
        opp.Stl.se     = row$opp.Stl.se,
        opp.TO.se      = row$opp.TO.se,
        opp.Blk.se     = row$opp.Blk.se,
        opp.PF.se      = row$opp.PF.se,
        opp.Score.skew   = row$opp.Score.skew,
        opp.FGM.skew     = row$opp.FGM.skew,
        opp.FGA.skew     = row$opp.FGA.skew,
        opp.FGM3.skew    = row$opp.FGM3.skew,
        opp.FGA3.skew    = row$opp.FGA3.skew,
        opp.FTM.skew     = row$opp.FTM.skew,
        opp.FTA.skew     = row$opp.FTA.skew,
        opp.OR.skew      = row$opp.OR.skew,
        opp.DR.skew      = row$opp.DR.skew,
        opp.Ast.skew     = row$opp.Ast.skew,
        opp.Stl.skew     = row$opp.Stl.skew,
        opp.TO.skew      = row$opp.TO.skew,
        opp.Blk.skew     = row$opp.Blk.skew,
        opp.PF.skew      = row$opp.PF.skew))
    }
  }
}

write.csv(output.df, "output_df.csv")

#### Prep df to make it suitable for predictions ####
output.df <- read.csv("output_df.csv")
## Tourney ##
tourney.df <- tourney.detailed[,c("Season", "WTeamID", "LTeamID")]
tourney.df$team.1 <- apply(tourney.df[,c("WTeamID", "LTeamID")], 1, max)
tourney.df$team.2 <- apply(tourney.df[,c("WTeamID", "LTeamID")], 1, min)
tourney.df$team.1.win <- ifelse(tourney.df$team.1 == tourney.df$WTeamID, 1, 0)

temp.1 <- left_join(tourney.df, output.df, by=c("Season" = "year", "team.1" = "team.id"))
team.1.col.names <- c("team.1.name", 
                            "team.1.conference", 
                            "team.1.coach", 
                            "team.1.massey.avg",
                            "team.1.massey.imp", 
                            "team.1.opp.massey.avg",
                            "team.1.o.score.pg", 
                            "team.1.o.fgm.pg", 
                            "team.1.o.fga.pg",
                            "team.1.o.fgm3.pg", 
                            "team.1.o.fga3.pg", 
                            "team.1.o.ftm.pg", 
                            "team.1.o.fta.pg", 
                            "team.1.o.or.pg", 
                            "team.1.o.dr.pg", 
                            "team.1.o.ast.pg", 
                            "team.1.o.stl.pg", 
                            "team.1.o.to.pg", 
                            "team.1.o.blk.pg", 
                            "team.1.o.pf.pg",

                            "team.1.o.score.se", 
                            "team.1.o.fgm.se", 
                            "team.1.o.fga.se",
                            "team.1.o.fgm3.se", 
                            "team.1.o.fga3.se", 
                            "team.1.o.ftm.se", 
                            "team.1.o.fta.se", 
                            "team.1.o.or.se", 
                            "team.1.o.dr.se", 
                            "team.1.o.ast.se", 
                            "team.1.o.stl.se", 
                            "team.1.o.to.se", 
                            "team.1.o.blk.se", 
                            "team.1.o.pf.se",
                            
                            "team.1.o.score.skew", 
                            "team.1.o.fgm.skew", 
                            "team.1.o.fga.skew",
                            "team.1.o.fgm3.skew", 
                            "team.1.o.fga3.skew", 
                            "team.1.o.ftm.skew", 
                            "team.1.o.fta.skew", 
                            "team.1.o.or.skew", 
                            "team.1.o.dr.skew", 
                            "team.1.o.ast.skew", 
                            "team.1.o.stl.skew", 
                            "team.1.o.to.skew", 
                            "team.1.o.blk.skew", 
                            "team.1.o.pf.skew",
                            
                            "team.1.d.score.pg", 
                            "team.1.d.fgm.pg", 
                            "team.1.d.fga.pg",
                            "team.1.d.fgm3.pg", 
                            "team.1.d.fga3.pg", 
                            "team.1.d.ftm.pg", 
                            "team.1.d.fta.pg", 
                            "team.1.d.or.pg", 
                            "team.1.d.dr.pg", 
                            "team.1.d.ast.pg", 
                            "team.1.d.stl.pg", 
                            "team.1.d.to.pg", 
                            "team.1.d.blk.pg", 
                            "team.1.d.pf.pg",
                            
                            "team.1.d.score.se", 
                            "team.1.d.fgm.se", 
                            "team.1.d.fga.se",
                            "team.1.d.fgm3.se", 
                            "team.1.d.fga3.se", 
                            "team.1.d.ftm.se", 
                            "team.1.d.fta.se", 
                            "team.1.d.or.se", 
                            "team.1.d.dr.se", 
                            "team.1.d.ast.se", 
                            "team.1.d.stl.se", 
                            "team.1.d.to.se", 
                            "team.1.d.blk.se", 
                            "team.1.d.pf.se",
                            
                            "team.1.d.score.skew", 
                            "team.1.d.fgm.skew", 
                            "team.1.d.fga.skew",
                            "team.1.d.fgm3.skew", 
                            "team.1.d.fga3.skew", 
                            "team.1.d.ftm.skew", 
                            "team.1.d.fta.skew", 
                            "team.1.d.or.skew", 
                            "team.1.d.dr.skew", 
                            "team.1.d.ast.skew", 
                            "team.1.d.stl.skew", 
                            "team.1.d.to.skew", 
                            "team.1.d.blk.skew", 
                            "team.1.d.pf.skew"
)

colnames(temp.1)[7:ncol(temp.1)] <- team.1.col.names

temp.2 <- left_join(tourney.df, output.df, by=c("Season" = "year", "team.2" = "team.id"))
team.2.col.names <-    c("team.2.name", 
                            "team.2.conference", 
                            "team.2.coach", 
                            "team.2.massey.avg",
                            "team.2.massey.imp", 
                            "team.2.opp.massey.avg",
                            "team.2.o.score.pg", 
                            "team.2.o.fgm.pg", 
                            "team.2.o.fga.pg",
                            "team.2.o.fgm3.pg", 
                            "team.2.o.fga3.pg", 
                            "team.2.o.ftm.pg", 
                            "team.2.o.fta.pg", 
                            "team.2.o.or.pg", 
                            "team.2.o.dr.pg", 
                            "team.2.o.ast.pg", 
                            "team.2.o.stl.pg", 
                            "team.2.o.to.pg", 
                            "team.2.o.blk.pg", 
                            "team.2.o.pf.pg",
                            
                            "team.2.o.score.se", 
                            "team.2.o.fgm.se", 
                            "team.2.o.fga.se",
                            "team.2.o.fgm3.se", 
                            "team.2.o.fga3.se", 
                            "team.2.o.ftm.se", 
                            "team.2.o.fta.se", 
                            "team.2.o.or.se", 
                            "team.2.o.dr.se", 
                            "team.2.o.ast.se", 
                            "team.2.o.stl.se", 
                            "team.2.o.to.se", 
                            "team.2.o.blk.se", 
                            "team.2.o.pf.se",
                            
                            "team.2.o.score.skew", 
                            "team.2.o.fgm.skew", 
                            "team.2.o.fga.skew",
                            "team.2.o.fgm3.skew", 
                            "team.2.o.fga3.skew", 
                            "team.2.o.ftm.skew", 
                            "team.2.o.fta.skew", 
                            "team.2.o.or.skew", 
                            "team.2.o.dr.skew", 
                            "team.2.o.ast.skew", 
                            "team.2.o.stl.skew", 
                            "team.2.o.to.skew", 
                            "team.2.o.blk.skew", 
                            "team.2.o.pf.skew",
                            
                            "team.2.d.score.pg", 
                            "team.2.d.fgm.pg", 
                            "team.2.d.fga.pg",
                            "team.2.d.fgm3.pg", 
                            "team.2.d.fga3.pg", 
                            "team.2.d.ftm.pg", 
                            "team.2.d.fta.pg", 
                            "team.2.d.or.pg", 
                            "team.2.d.dr.pg", 
                            "team.2.d.ast.pg", 
                            "team.2.d.stl.pg", 
                            "team.2.d.to.pg", 
                            "team.2.d.blk.pg", 
                            "team.2.d.pf.pg",
                            
                            "team.2.d.score.se", 
                            "team.2.d.fgm.se", 
                            "team.2.d.fga.se",
                            "team.2.d.fgm3.se", 
                            "team.2.d.fga3.se", 
                            "team.2.d.ftm.se", 
                            "team.2.d.fta.se", 
                            "team.2.d.or.se", 
                            "team.2.d.dr.se", 
                            "team.2.d.ast.se", 
                            "team.2.d.stl.se", 
                            "team.2.d.to.se", 
                            "team.2.d.blk.se", 
                            "team.2.d.pf.se",
                            
                            "team.2.d.score.skew", 
                            "team.2.d.fgm.skew", 
                            "team.2.d.fga.skew",
                            "team.2.d.fgm3.skew", 
                            "team.2.d.fga3.skew", 
                            "team.2.d.ftm.skew", 
                            "team.2.d.fta.skew", 
                            "team.2.d.or.skew", 
                            "team.2.d.dr.skew", 
                            "team.2.d.ast.skew", 
                            "team.2.d.stl.skew", 
                            "team.2.d.to.skew", 
                            "team.2.d.blk.skew", 
                            "team.2.d.pf.skew"
)

colnames(temp.2)[7:ncol(temp.2)] <- team.2.col.names

temp.2 <- temp.2[,7:ncol(temp.2)]

tourney.df <- cbind(temp.1, temp.2)

#### Create Reg Season DF

reg.season.neutral <- reg.season.detailed[(reg.season.detailed$WLoc == 'N') & reg.season.detailed$DayNum >= 45,]
reg.season.neutral$team.1 <- apply(reg.season.neutral[,c("WTeamID", "LTeamID")], 1, max)
reg.season.neutral$team.2 <- apply(reg.season.neutral[,c("WTeamID", "LTeamID")], 1, min)
reg.season.neutral$team.1.win <- ifelse(reg.season.neutral$team.1 == reg.season.neutral$WTeamID, 1, 0)
reg.season.neutral <- reg.season.neutral[,c("Season", "DayNum", "WTeamID", "LTeamID", "team.1", "team.2", "team.1.win")]

temp.1 <- left_join(reg.season.neutral, output.df, by=c("Season" = "year", "team.1" = "team.id"))
temp.2 <- left_join(reg.season.neutral, output.df, by=c("Season" = "year", "team.2" = "team.id"))

colnames(temp.1)[8:ncol(temp.1)] <- team.1.col.names
colnames(temp.2)[8:ncol(temp.2)] <- team.2.col.names

temp.2 <- temp.2[,8:ncol(temp.2)]

reg.season.neutral.pred.df <- cbind(temp.1, temp.2)
reg.season.neutral.pred.df[,c("team.1.massey.avg", "team.1.massey.imp", "team.2.massey.avg", "team.2.massey.imp")] <- NA
#reg.season.neutral.pred.df[,c("team.1.massey.avg", "team.1.massey.imp", "team.2.massey.avg", "team.2.massey.imp")] <- NA
#write.csv(reg.season.neutral.pred.df[,c("team.1.opp.massey.avg", "team.2.opp.massey.avg")], "opp_massey_avg.csv")
for (year in 1:length(detailed.seasons)) {
  season <- detailed.seasons[year]
  season.reg.season.neutral.pred.df <- subset(reg.season.neutral.pred.df, Season == season)
  season.massey.ordinals <- subset(massey.ordinals.historical, Season == season)
print(season)
 for (game in 1:nrow(season.reg.season.neutral.pred.df)) {
   if(game %% 100 == 0) {print(game)}
 #for (game in 1:15) {
   #season <- reg.season.neutral.pred.df[game,"Season"]
   dayNum <- season.reg.season.neutral.pred.df[game,"DayNum"]
   rowNum <- as.numeric(rownames(season.reg.season.neutral.pred.df[game,]))
   team.1.id <- season.reg.season.neutral.pred.df[game,"team.1"]
   team.2.id <- season.reg.season.neutral.pred.df[game,"team.2"]

   
   team.1.massey.avg <- mean(season.massey.ordinals[
                                                           (season.massey.ordinals$RankingDayNum < dayNum) & 
                                                           (season.massey.ordinals$RankingDayNum > dayNum - 30) &
                                                           (season.massey.ordinals$TeamID == team.1.id), c("OrdinalRank")]) 
    
   team.2.massey.avg <- mean(season.massey.ordinals[   
                                                           (season.massey.ordinals$RankingDayNum < dayNum) & 
                                                           (season.massey.ordinals$RankingDayNum > dayNum - 30) &
                                                           (season.massey.ordinals$TeamID == team.2.id), c("OrdinalRank")]) 
    
   team.1.massey.early <- mean(season.massey.ordinals[  (season.massey.ordinals$Season == season) & 
                                                           (season.massey.ordinals$RankingDayNum < dayNum - 30) & 
                                                           (season.massey.ordinals$TeamID == team.1.id), c("OrdinalRank")]) 
   team.1.massey.imp <- team.1.massey.early - team.1.massey.avg
   
   team.2.massey.early <- mean(season.massey.ordinals[  
                                                              (season.massey.ordinals$RankingDayNum < dayNum - 30) & 
                                                              (season.massey.ordinals$TeamID == team.2.id), c("OrdinalRank")]) 
   team.2.massey.imp <- team.2.massey.early - team.2.massey.avg
  
   reg.season.neutral.pred.df[rowNum,c("team.1.massey.avg")] <- team.1.massey.avg
   reg.season.neutral.pred.df[rowNum,c("team.2.massey.avg")] <- team.2.massey.avg
   
   if(!is.nan(team.1.massey.imp) & !is.nan(team.2.massey.imp)){
     reg.season.neutral.pred.df[rowNum,c("team.1.massey.imp")] <- team.1.massey.imp  
     reg.season.neutral.pred.df[rowNum,c("team.2.massey.imp")] <- team.2.massey.imp  
   } else {
     reg.season.neutral.pred.df[rowNum,c("team.1.massey.imp")] <- 0  
     season.reg.season.neutral.pred.df[rowNum,c("team.2.massey.imp")] <- 0 
   }
 }
}

## Combine reg season and tourney ##
tourney.df["DayNum"] <- 150
full.pred.df <- rbind(tourney.df, reg.season.neutral.pred.df)
full.pred.df[,"team.1.win"] <- as.factor(full.pred.df[,"team.1.win"])
full.pred.df <- na.omit(full.pred.df)

# offensive differences
full.pred.df$o.ppg.diff <- full.pred.df$team.1.o.score.pg - full.pred.df$team.2.o.score.pg
full.pred.df$o.fgm.diff <- full.pred.df$team.1.o.fgm.pg - full.pred.df$team.2.o.fgm.pg
full.pred.df$o.fga.diff <- full.pred.df$team.1.o.fga.pg - full.pred.df$team.2.o.fga.pg
full.pred.df$o.fgm3.diff <- full.pred.df$team.1.o.fgm3.pg - full.pred.df$team.2.o.fgm3.pg
full.pred.df$o.fga3.diff <- full.pred.df$team.1.o.fga3.pg - full.pred.df$team.2.o.fga3.pg
full.pred.df$o.ftm.diff <- full.pred.df$team.1.o.ftm.pg - full.pred.df$team.2.o.ftm.pg
full.pred.df$o.fta.diff <- full.pred.df$team.1.o.fta.pg - full.pred.df$team.2.o.fta.pg
full.pred.df$o.or.diff <- full.pred.df$team.1.o.or.pg - full.pred.df$team.2.o.or.pg
full.pred.df$o.dr.diff <- full.pred.df$team.1.o.dr.pg - full.pred.df$team.2.o.dr.pg
full.pred.df$o.ast.diff <- full.pred.df$team.1.o.ast.pg - full.pred.df$team.2.o.ast.pg
full.pred.df$o.stl.diff <- full.pred.df$team.1.o.stl.pg - full.pred.df$team.2.o.stl.pg
full.pred.df$o.to.diff <- full.pred.df$team.1.o.to.pg - full.pred.df$team.2.o.to.pg
full.pred.df$o.blk.diff <- full.pred.df$team.1.o.blk.pg - full.pred.df$team.2.o.blk.pg
full.pred.df$o.pf.diff <- full.pred.df$team.1.o.pf.pg - full.pred.df$team.2.o.pf.pg
# defensive differences
full.pred.df$d.ppg.diff <- full.pred.df$team.1.d.score.pg - full.pred.df$team.2.d.score.pg
full.pred.df$d.fgm.diff <- full.pred.df$team.1.d.fgm.pg - full.pred.df$team.2.d.fgm.pg
full.pred.df$d.fga.diff <- full.pred.df$team.1.d.fga.pg - full.pred.df$team.2.d.fga.pg
full.pred.df$d.fgm3.diff <- full.pred.df$team.1.d.fgm3.pg - full.pred.df$team.2.d.fgm3.pg
full.pred.df$d.fga3.diff <- full.pred.df$team.1.d.fga3.pg - full.pred.df$team.2.d.fga3.pg
full.pred.df$d.ftm.diff <- full.pred.df$team.1.d.ftm.pg - full.pred.df$team.2.d.ftm.pg
full.pred.df$d.fta.diff <- full.pred.df$team.1.d.fta.pg - full.pred.df$team.2.d.fta.pg
full.pred.df$d.or.diff <- full.pred.df$team.1.d.or.pg - full.pred.df$team.2.d.or.pg
full.pred.df$d.dr.diff <- full.pred.df$team.1.d.dr.pg - full.pred.df$team.2.d.dr.pg
full.pred.df$d.ast.diff <- full.pred.df$team.1.d.ast.pg - full.pred.df$team.2.d.ast.pg
full.pred.df$d.stl.diff <- full.pred.df$team.1.d.stl.pg - full.pred.df$team.2.d.stl.pg
full.pred.df$d.to.diff <- full.pred.df$team.1.d.to.pg - full.pred.df$team.2.d.to.pg
full.pred.df$d.blk.diff <- full.pred.df$team.1.d.blk.pg - full.pred.df$team.2.d.blk.pg
full.pred.df$d.pf.diff <- full.pred.df$team.1.d.pf.pg - full.pred.df$team.2.d.pf.pg

full.pred.df$massey.diff <- full.pred.df$team.1.massey.avg - full.pred.df$team.2.massey.avg
full.pred.df$opp.massey.diff <- full.pred.df$team.1.opp.massey.avg - full.pred.df$team.2.opp.massey.avg
write.csv(full.pred.df, "full_pred_df.csv")
#### Set variable to list of predictors to include in the model
eligible.predictors <- c(#"team.1.name", 
#  "team.1.coach",
  "team.1.conference", 
  "team.1.massey.avg",
  "team.1.massey.imp",
  "team.1.opp.massey.avg",
  "team.1.o.score.pg",
  "team.1.o.fgm.pg",
  "team.1.o.fga.pg",
  "team.1.o.fgm3.pg",
  "team.1.o.fga3.pg",
  "team.1.o.ftm.pg",
  "team.1.o.fta.pg",
  "team.1.o.or.pg",
  "team.1.o.dr.pg",
  "team.1.o.ast.pg",
  "team.1.o.stl.pg",
  "team.1.o.to.pg",
  "team.1.o.blk.pg",
  "team.1.o.pf.pg",
  "team.1.o.score.se",
  "team.1.o.fgm.se",
  "team.1.o.fga.se",
  "team.1.o.fgm3.se",
  "team.1.o.fga3.se",
  "team.1.o.ftm.se",
  "team.1.o.fta.se",
  "team.1.o.or.se",
  "team.1.o.dr.se",
  "team.1.o.ast.se",
  "team.1.o.stl.se",
  "team.1.o.to.se",
  "team.1.o.blk.se",
  "team.1.o.pf.se",
  "team.1.o.score.skew",
  "team.1.o.fgm.skew",
  "team.1.o.fga.skew",
  "team.1.o.fgm3.skew",
  "team.1.o.fga3.skew",
  "team.1.o.ftm.skew",
  "team.1.o.fta.skew",
  "team.1.o.or.skew",
  "team.1.o.dr.skew",
  "team.1.o.ast.skew",
  "team.1.o.stl.skew",
  "team.1.o.to.skew",
  "team.1.o.blk.skew",
  "team.1.o.pf.skew",

#  "team.2.coach",
  "team.2.conference", 
  "team.2.massey.avg",
  "team.2.massey.imp",
  "team.2.opp.massey.avg",
  "team.2.o.score.pg",
  "team.2.o.fgm.pg",
  "team.2.o.fga.pg",
  "team.2.o.fgm3.pg",
  "team.2.o.fga3.pg",
  "team.2.o.ftm.pg",
  "team.2.o.fta.pg",
  "team.2.o.or.pg",
  "team.2.o.dr.pg",
  "team.2.o.ast.pg",
  "team.2.o.stl.pg",
  "team.2.o.to.pg",
  "team.2.o.blk.pg",
  "team.2.o.pf.pg",
  "team.2.o.score.se",
  "team.2.o.fgm.se",
  "team.2.o.fga.se",
  "team.2.o.fgm3.se",
  "team.2.o.fga3.se",
  "team.2.o.ftm.se",
  "team.2.o.fta.se",
  "team.2.o.or.se",
  "team.2.o.dr.se",
  "team.2.o.ast.se",
  "team.2.o.stl.se",
  "team.2.o.to.se",
  "team.2.o.blk.se",
  "team.2.o.pf.se",
  "team.2.o.score.skew",
  "team.2.o.fgm.skew",
  "team.2.o.fga.skew",
  "team.2.o.fgm3.skew",
  "team.2.o.fga3.skew",
  "team.2.o.ftm.skew",
  "team.2.o.fta.skew",
  "team.2.o.or.skew",
  "team.2.o.dr.skew",
  "team.2.o.ast.skew",
  "team.2.o.stl.skew",
  "team.2.o.to.skew",
  "team.2.o.blk.skew",
  "team.2.o.pf.skew",

  "o.ppg.diff", 
  "o.fgm.diff", 
  "o.fga.diff", 
  "o.fgm3.diff", 
  "o.fga3.diff", 
  "o.ftm.diff", 
  "o.fta.diff", 
  "o.or.diff", 
  "o.dr.diff", 
  "o.ast.diff", 
  "o.stl.diff", 
  "o.blk.diff", 
  "o.pf.diff",
  
  "d.ppg.diff", 
  "d.fgm.diff", 
  "d.fga.diff", 
  "d.fgm3.diff", 
  "d.fga3.diff", 
  "d.ftm.diff", 
  "d.fta.diff", 
  "d.or.diff", 
  "d.dr.diff", 
  "d.ast.diff", 
  "d.stl.diff", 
  "d.blk.diff", 
  "d.pf.diff",
  "massey.diff",
  "opp.massey.diff"
)

eligible.predictors <- c(
  "massey.diff",
  "opp.massey.diff",
  "team.2.conference",
  "team.1.conference",
  "d.ppg.diff",
  "o.ppg.diff",
  "o.fgm.diff",
  "d.ast.diff",
  "team.2.massey.avg",
  "team.1.massey.avg",
  "d.fgm.diff",
  "o.ast.diff",
  "d.dr.diff",
  "d.ftm.diff",
  "d.stl.diff",
  "team.2.massey.avg",
  "team.1.massey.avg",
  "d.fta.diff",
  "team.2.o.score.pg",
  "team.1.o.score.pg",
  "team.2.o.fgm.pg"
)

#full.pred.df[,"team.1.win"] <- as.numeric(full.pred.df[,"team.1.win"])
#full.pred.df[,"team.1.win"] <- full.pred.df[,"team.1.win"] - 1
#write.csv(full.pred.df, 'full_pred_df.csv')
#### MODEL BUILD ####
full.pred.df <- read.csv("full_pred_df.csv")
output.df <- read.csv("output_df.csv")
response.col <- "team.1.win"
#full.pred.df[,response.col] <- as.factor(full.pred.df[,response.col])
set.seed(223)
train <- sample(1:nrow(full.pred.df), (nrow(full.pred.df) * .8))
test.df <- full.pred.df[-train,]
train.df <- full.pred.df[train,]


#rf.prediction.cv <- rfcv(trainx=train.df[,eligible.predictors], trainy=train.df[,response.col])

rand.forest <- randomForest(train.df[,eligible.predictors], y = train.df[,response.col], ntree = 1501, importance = TRUE, do.trace = 100)
plot(rand.forest, main = "Random Forest - 1501 trees")
importance.df <- importance(rand.forest, class = 1)
varImpPlot(rand.forest, sort = TRUE, type = 1, main = "Random Forest - team.1.win")

rf.pred.train <- predict(rand.forest, train.df[,eligible.predictors], type = "response")
#rf.pred.vec <- rf.pred.train[,"1"]

rf.predictions <- prediction(predictions = rf.pred.train, labels = train.df[,response.col])
rf.roc <- performance(rf.predictions, measure = "tpr", x.measure = "fpr")
plot(rf.roc)

#### TEST SET #### 
rf.pred.test <- predict(rand.forest, newdata = test.df[,eligible.predictors], type = "response")
#rf.pred.vec.test <- rf.pred.test[,"1"]

rf.predictions.test <- prediction(predictions = rf.pred.test, labels = test.df[,response.col])
rf.roc.test <- performance(rf.predictions.test, measure = "tpr", x.measure = "fpr")
plot(rf.roc.test)
abline(a=0, b=1)
print(opt.cut(perf = rf.roc.test, pred = rf.predictions.test))
rf.auc.test <- performance(rf.predictions.test, measure = "auc")

#### PREP PREDICTION DATA FRAME ####
tourney.2018.preds <- sample.submission
columnSplit <- colsplit(tourney.2018.preds$ID, split = "_", names = c("year", "team.1", "team.2"))
tourney.2018.preds <- cbind(tourney.2018.preds, columnSplit)
output.df.2018 <- output.df[output.df$year == 2018,]
#output.df.2018 <- output.df.2018[,!(names(output.df.2018) %in% c("X"))]

temp.1 <- left_join(tourney.2018.preds, output.df.2018, by=c("year", "team.1" = "team.id"))
temp.1 <- temp.1[,!(names(temp.1) %in% c("X"))]
colnames(temp.1)[6:ncol(temp.1)] <- team.1.col.names

temp.2 <- left_join(tourney.2018.preds, output.df.2018, by=c("year", "team.2" = "team.id"))
temp.2 <- temp.2[,!(names(temp.2) %in% c("X"))]
colnames(temp.2)[6:ncol(temp.2)] <- team.2.col.names

temp.2 <- temp.2[,team.2.col.names]

tourney.2018.preds <- cbind(temp.1, temp.2)

# offensive differences
tourney.2018.preds$o.ppg.diff <- tourney.2018.preds$team.1.o.score.pg - tourney.2018.preds$team.2.o.score.pg
tourney.2018.preds$o.fgm.diff <- tourney.2018.preds$team.1.o.fgm.pg - tourney.2018.preds$team.2.o.fgm.pg
tourney.2018.preds$o.fga.diff <- tourney.2018.preds$team.1.o.fga.pg - tourney.2018.preds$team.2.o.fga.pg
tourney.2018.preds$o.fgm3.diff <- tourney.2018.preds$team.1.o.fgm3.pg - tourney.2018.preds$team.2.o.fgm3.pg
tourney.2018.preds$o.fga3.diff <- tourney.2018.preds$team.1.o.fga3.pg - tourney.2018.preds$team.2.o.fga3.pg
tourney.2018.preds$o.ftm.diff <- tourney.2018.preds$team.1.o.ftm.pg - tourney.2018.preds$team.2.o.ftm.pg
tourney.2018.preds$o.fta.diff <- tourney.2018.preds$team.1.o.fta.pg - tourney.2018.preds$team.2.o.fta.pg
tourney.2018.preds$o.or.diff <- tourney.2018.preds$team.1.o.or.pg - tourney.2018.preds$team.2.o.or.pg
tourney.2018.preds$o.dr.diff <- tourney.2018.preds$team.1.o.dr.pg - tourney.2018.preds$team.2.o.dr.pg
tourney.2018.preds$o.ast.diff <- tourney.2018.preds$team.1.o.ast.pg - tourney.2018.preds$team.2.o.ast.pg
tourney.2018.preds$o.stl.diff <- tourney.2018.preds$team.1.o.stl.pg - tourney.2018.preds$team.2.o.stl.pg
tourney.2018.preds$o.to.diff <- tourney.2018.preds$team.1.o.to.pg - tourney.2018.preds$team.2.o.to.pg
tourney.2018.preds$o.blk.diff <- tourney.2018.preds$team.1.o.blk.pg - tourney.2018.preds$team.2.o.blk.pg
tourney.2018.preds$o.pf.diff <- tourney.2018.preds$team.1.o.pf.pg - tourney.2018.preds$team.2.o.pf.pg
# defensive differences
tourney.2018.preds$d.ppg.diff <- tourney.2018.preds$team.1.d.score.pg - tourney.2018.preds$team.2.d.score.pg
tourney.2018.preds$d.fgm.diff <- tourney.2018.preds$team.1.d.fgm.pg - tourney.2018.preds$team.2.d.fgm.pg
tourney.2018.preds$d.fga.diff <- tourney.2018.preds$team.1.d.fga.pg - tourney.2018.preds$team.2.d.fga.pg
tourney.2018.preds$d.fgm3.diff <- tourney.2018.preds$team.1.d.fgm3.pg - tourney.2018.preds$team.2.d.fgm3.pg
tourney.2018.preds$d.fga3.diff <- tourney.2018.preds$team.1.d.fga3.pg - tourney.2018.preds$team.2.d.fga3.pg
tourney.2018.preds$d.ftm.diff <- tourney.2018.preds$team.1.d.ftm.pg - tourney.2018.preds$team.2.d.ftm.pg
tourney.2018.preds$d.fta.diff <- tourney.2018.preds$team.1.d.fta.pg - tourney.2018.preds$team.2.d.fta.pg
tourney.2018.preds$d.or.diff <- tourney.2018.preds$team.1.d.or.pg - tourney.2018.preds$team.2.d.or.pg
tourney.2018.preds$d.dr.diff <- tourney.2018.preds$team.1.d.dr.pg - tourney.2018.preds$team.2.d.dr.pg
tourney.2018.preds$d.ast.diff <- tourney.2018.preds$team.1.d.ast.pg - tourney.2018.preds$team.2.d.ast.pg
tourney.2018.preds$d.stl.diff <- tourney.2018.preds$team.1.d.stl.pg - tourney.2018.preds$team.2.d.stl.pg
tourney.2018.preds$d.to.diff <- tourney.2018.preds$team.1.d.to.pg - tourney.2018.preds$team.2.d.to.pg
tourney.2018.preds$d.blk.diff <- tourney.2018.preds$team.1.d.blk.pg - tourney.2018.preds$team.2.d.blk.pg
tourney.2018.preds$d.pf.diff <- tourney.2018.preds$team.1.d.pf.pg - tourney.2018.preds$team.2.d.pf.pg

tourney.2018.preds$massey.diff <- tourney.2018.preds$team.2.massey.avg - tourney.2018.preds$team.1.massey.avg
tourney.2018.preds$opp.massey.diff <- tourney.2018.preds$team.1.opp.massey.avg - tourney.2018.preds$team.2.opp.massey.avg


rf.pred.tourney.2018 <- predict(rand.forest, tourney.2018.preds[,eligible.predictors], type = "response")
#rf.pred.vec.tourney.2018 <- rf.pred.tourney.2018[,"1"]

final <- subset(tourney.2018.preds, select = c("ID", "team.1", "team.1.name", "team.2", "team.2.name"))
final <- cbind(final, rf.pred.tourney.2018)

write.csv(final, file = "rf_preds_2018_tourney.csv")
####
#final <- read.csv("first_preds.csv")

temp.1 <- left_join(final, teams, by=c("team.1.name" = "TeamName"))
colnames(temp.1) <- c("ID", "team.1.id", "team.1.name", "team.2.id","team.2.name", "rf.pred.tourney.2018")
temp.1 <- temp.1[,names(temp.1) %in% c("ID", "team.1.id", "team.1.name", "team.2.id","team.2.name", "rf.pred.tourney.2018")]
#temp.1 <- left_join(temp.1, teams, by=c("team.2.name" = "TeamName"))
#colnames(temp.1) <- c("ID", "team.1.id", "team.1.name", "team.2.id","team.2.name", "","rf.pred.tourney.2018", "team.1.id", "team.2.id")

temp.1 <- subset(temp.1, select=c("ID", "team.1.id", "team.1.name", "team.2.id", "team.2.name", "rf.pred.tourney.2018"))
seeds.2018 <- seeds[seeds$Season == 2018,]
temp.1 <- left_join(temp.1, seeds.2018, by=c("team.1.id" = "TeamID"))
colnames(temp.1)[8] <- "team.1.seed"
temp.1 <- left_join(temp.1, seeds.2018, by=c("team.2.id" = "TeamID"))
colnames(temp.1)[10] <- "team.2.seed"
temp.1 <- subset(temp.1, select=c("ID", "team.1.id", "team.1.name", "team.1.seed", "team.2.id", "team.2.name", "team.2.seed", "rf.pred.tourney.2018"))
write.csv(temp.1, "preds_w_seeds.csv")
preds.w.seeds <- read.csv("preds_w_seeds.csv")
preds.w.seeds$team.1.region <- substring(preds.w.seeds$team.1.seed,1,1)
preds.w.seeds$team.2.region <- substring(preds.w.seeds$team.2.seed,1,1)
a <- unique(preds.w.seeds$team.1.id)
b <- unique(preds.w.seeds$team.2.id)
tourney.teams <- unique(c(a,b))

output.df.by.team <- data.frame(team.id       = integer(),
                                team.name     = character(),
                                team.region   = character(),
                                team.seed     = character(),
                                opp.team.id   = integer(),
                                opp.team.name = character(),
                                opp.region    = character(),
                                opp.seed      = character(),
                                team.prob.win = numeric()
)
                                

for (id in 1:length(tourney.teams)) {
  team.id <- tourney.teams[id]
  team.name <- teams[teams$TeamID == team.id ,"TeamName"]
  team.pred.df <- preds.w.seeds[preds.w.seeds$team.1.id == team.id | preds.w.seeds$team.2.id == team.id,]
  
  for (game in 1:nrow(team.pred.df)) {
    if (team.pred.df[game,"team.1.id"] == team.id) {
      team.1.flg <- TRUE
    } else { team.1.flg <- FALSE }
    if ( team.1.flg ) {
      team.region <- team.pred.df[game, "team.1.region"]
      team.seed <- team.pred.df[game, "team.1.seed"]
      opp.team.id <- team.pred.df[game, "team.2.id"]
      opp.team.name <- team.pred.df[game, "team.2.name"]
      opp.region <- team.pred.df[game, "team.2.region"]
      opp.seed <- team.pred.df[game, "team.2.seed"]
      team.prob.win <- team.pred.df[game, "rf.pred.tourney.2018"]
    } else {
      team.region <- team.pred.df[game, "team.2.region"]
      team.seed <- team.pred.df[game, "team.2.seed"]
      opp.team.id <- team.pred.df[game, "team.2.id"]
      opp.team.name <- team.pred.df[game, "team.1.name"]
      opp.region <- team.pred.df[game, "team.1.region"]
      opp.seed <- team.pred.df[game, "team.1.seed"]
      team.prob.win <- 1 - team.pred.df[game, "rf.pred.tourney.2018"]
    }
    
    row <- data.frame(team.id       = team.id,
                      team.name     = team.name,
                      team.region   = team.region,
                      team.seed     = team.seed,
                      opp.team.id   = opp.team.id,
                      opp.team.name = opp.team.name,
                      opp.region    = opp.region,
                      opp.seed      = opp.seed,
                      team.prob.win = team.prob.win)
    
    output.df.by.team <- rbind(output.df.by.team, row)
    
  }
  
}
write.csv(output.df.by.team, "output_df_by_team.csv")
output.df.by.team <- read.csv("output_df_by_team.csv")

output.df.by.team$team.name <- as.character(output.df.by.team$team.name)
team.probs.sum <- aggregate(team.prob.win ~ team.name, output.df.by.team, sum)
team.probs.sum <- team.probs.sum[with(team.probs.sum, order(-team.prob.win)),]

team.probs.mean <- aggregate(team.prob.win ~ team.name, output.df.by.team, mean)
team.probs.mean <- team.probs.mean[with(team.probs.mean, order(-team.prob.win)),]

w.region <- output.df.by.team[output.df.by.team$team.region == "W" & output.df.by.team$opp.region == "W", ]
x.region <- output.df.by.team[output.df.by.team$team.region == "X" & output.df.by.team$opp.region == "X", ]
y.region <- output.df.by.team[output.df.by.team$team.region == "Y" & output.df.by.team$opp.region == "Y", ]
z.region <- output.df.by.team[output.df.by.team$team.region == "Z" & output.df.by.team$opp.region == "Z", ]

w.region.prob.sums <- aggregate(team.prob.win ~ team.name, w.region, sum)
x.region.prob.sums <- aggregate(team.prob.win ~ team.name, x.region, sum)
y.region.prob.sums <- aggregate(team.prob.win ~ team.name, y.region, sum)
z.region.prob.sums <- aggregate(team.prob.win ~ team.name, z.region, sum)

w.region.prob.sums <- w.region.prob.sums[with(w.region.prob.sums, order(-team.prob.win)),]
x.region.prob.sums <- x.region.prob.sums[with(x.region.prob.sums, order(-team.prob.win)),]
y.region.prob.sums <- y.region.prob.sums[with(y.region.prob.sums, order(-team.prob.win)),]
z.region.prob.sums <- z.region.prob.sums[with(z.region.prob.sums, order(-team.prob.win)),]

write.csv(w.region, "w_region.csv")
write.csv(x.region, "x_region.csv")
write.csv(y.region, "y_region.csv")
write.csv(z.region, "z_region.csv")

write.csv(w.region.prob.sums, "w_region_prob_sums.csv")
write.csv(x.region.prob.sums, "x_region_prob_sums.csv")
write.csv(y.region.prob.sums, "y_region_prob_sums.csv")
write.csv(z.region.prob.sums, "z_region_prob_sums.csv")