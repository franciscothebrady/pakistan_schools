## 02 summary stats 
# OOO:
# 1. load clean data 
# 2. create overall summary tables 
# 3. viz
# 4. save summary tables and figures

# set up 
library(dplyr)
library(tidyr)
library(janitor)
library(ggplot2)
library(ggthemes)
library(readr)
library(glue)
library(here)

source("setup.R")

# load clean data
scores <- read_csv(glue(here::here(), processed_data, "01_processed_scores.csv"))

## tables ----
## overall summary 
overall_summary <- scores %>%
  summarise(across(where(is.numeric), 
    .fns = list(Mean = mean, SD = sd, Min = min, Max = max), na.rm = TRUE, 
    .names = "{col}_{fn}"
  )) %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Statistic") %>%
  separate_wider_delim(Variable, delim = "_", names = c("School Level", "Variable", "Measure"), too_few = "align_end") %>%
  group_by(Variable) %>%
  pivot_wider(names_from = Measure, values_from = Statistic) %>%
  ungroup() %>%
  mutate(Characteristic = glue("{`School Level`}_{Variable}")) %>%
  select(-`School Level`, -Variable) %>%
  mutate(Mean = round(Mean, 2),
         SD = round(SD, 2)) %>%
  select(Characteristic, Min, Mean, SD, Max) %>%
  mutate(Characteristic = ifelse(Characteristic == 'NA_transition', 'transition', Characteristic)) %>%
  filter(!Characteristic %in% c('lss_id', 'student_id')) 

# save overall summary table
write_csv(overall_summary, glue(here::here(), processed_data, "02_overall_summary.csv"))

# create summary table by language 
summary_by_language <- scores %>%
  group_by(lss_urdu) %>%
  summarise(across(where(is.numeric), 
    .fns = list(Mean = mean, SD = sd, Min = min, Max = max), na.rm = TRUE, 
    .names = "{col}_{fn}"
  )) %>%
  mutate(lss_urdu = ifelse(lss_urdu == 1, "Urdu", "English")) %>%
  pivot_longer(cols = -lss_urdu, names_to = "Variable", values_to = "Statistic") %>%
  separate_wider_delim(Variable, delim = "_", names = c("School Level", "Variable", "Measure"), too_few = "align_end") %>%
  group_by(lss_urdu, Variable) %>%
  pivot_wider(names_from = Measure, values_from = Statistic) %>%
  ungroup() %>%
  mutate(Characteristic = glue("{`School Level`}_{Variable}")) %>%
  select(-`School Level`, -Variable) %>%
  select(lss_urdu, Characteristic, Min, Mean, SD, Max) %>%
  mutate(Characteristic = ifelse(Characteristic == 'NA_transition', 'transition', Characteristic)) %>%
  filter(!Characteristic %in% c('lss_id', 'student_id')) %>%
  mutate(Mean = round(Mean, 3),
         SD = round(SD, 3)) %>%
  pivot_longer(cols = c(Mean, SD, Min, Max), names_to = "Statistic", values_to = "Value") %>%
  pivot_wider(names_from = lss_urdu, values_from = Value) %>%
  filter(!Statistic %in% c("Min", "Max"),
         Characteristic != 'transition')

# save summary table by language
write_csv(summary_by_language, glue(here::here(), processed_data, "02_summary_by_language.csv"))

## viz ---- 

scores <- scores %>%
  mutate(score_bin = case_when(lssc_score < 350 ~ "Under 350",
                               lssc_score >= 350 & lssc_score < 400 ~ "350-400",
                               lssc_score >= 400 & lssc_score < 450 ~ "400-450",
                               lssc_score >= 450 & lssc_score < 500 ~ "450-500",
                               lssc_score >= 500 & lssc_score < 550 ~ "500-550",
                               lssc_score >= 550 & lssc_score < 600 ~ "550-600",
                               lssc_score >= 600 & lssc_score < 650 ~ "600-650",
                               lssc_score >= 650 & lssc_score < 700 ~ "650-700",
                               lssc_score >= 700 & lssc_score < 750 ~ "700-750",
                               lssc_score >= 750 & lssc_score < 800 ~ "750-800",
                               lssc_score >= 800 & lssc_score < 850 ~ "800-850",
                               lssc_score >= 850 & lssc_score < 900 ~ "850-900",
                               lssc_score >= 900 & lssc_score < 950 ~ "900-950",
                               lssc_score >= 950 & lssc_score < 1000 ~ "950-1000",
                               lssc_score >= 1000 & lssc_score < 1050 ~ "1000-1050",
                               lssc_score >= 1050 & lssc_score < 1100 ~ "1050-1100",
                               TRUE ~ NA_character_)) 
# convert character into factor
scores <- scores %>%
  mutate(score_bin = factor(score_bin, 
                            levels = c("Under 350", "350-400", "400-450", "450-500", 
                                       "500-550", "550-600", "600-650", "650-700",
                                       "700-750", "750-800", "800-850", "850-900",
                                       "900-950", "950-1000", "1000-1050", 
                                       "1050-1100"), ordered = TRUE))

tabyl(scores$score_bin)

# distribution of all test scores 
all_hist <- scores %>%
  ggplot() + 
  geom_histogram(aes(lssc_score), binwidth = 25, fill = "#0072B2", color = "white", lwd = 0.25) +
  theme_fivethirtyeight() +
  labs(title = "Distribution of LSSC Scores",
       x = "LSSC Score",
       y = "Count") 
# output 
ggsave(glue(figures, "01_scorehist.png"), all_hist, width = 8, height = 5)

# lssc score by school type 
schooltype_hist <- scores %>%
  mutate(lss_private = as.factor(lss_private)) %>%
  # group_by(lss_private, lssc_score) %>%
  # summarise(total = n()) %>%
  ggplot(aes(x=lssc_score, fill=lss_private)) +
  geom_bar(alpha=0.75, position = position_dodge(.25)) +
  scale_fill_manual(values=c("#69b3a2", "#404080")) +
  theme_stata() + 
  labs(title = "Distribution of LSSC Scores", subtitle = "By School Type",
       fill="LSS Private")
              
            
# output
ggsave(glue(figures, "02_scorehist_schooltype.png"), schooltype_hist, width = 8, height = 5)

# lssc score by language
language_hist <- scores %>%
  mutate(lss_urdu = as.factor(lss_urdu)) %>%
  ggplot( aes(x=lssc_score, fill=lss_urdu)) +
  geom_bar( alpha=0.75, position = position_dodge(0.25)) +
  scale_fill_manual(values=c("#69b3a2", "#404080")) +
  theme_stata() + 
  labs(title = "Distribution of LSSC Scores", subtitle = "By Language",
       fill="LSS Urdu")
# output
ggsave(glue(figures, "03_scorehist_lang.png"), language_hist, width = 8, height = 5)

# score distribution by tax status 
## student_eft

# lssc score by tax status
tax_hist <- scores %>%
  mutate(student_eft = as.factor(student_eft)) %>%
  ggplot(aes(x=lssc_score, fill=student_eft)) +
  geom_bar( alpha=0.75, position = position_dodge(0.25)) +
  scale_fill_manual(values=c("#69b3a2", "#404080")) +
  theme_stata() + 
  labs(title = "Distribution of LSSC Scores", subtitle = "By Tax Status",
       fill="Ever Filed Taxes")

# output
ggsave(glue(figures, "04_scorehist_tax.png"), tax_hist, width = 8, height = 5)

# number of test takers per year, percent 

testcount_bytype <- scores %>%
  mutate(lss_private = as.factor(lss_private)) %>%
  group_by(lss_year) %>%
  summarise(total = n(),
            private = sum(lss_private == 1)) %>%
  mutate(percent = private / sum(total) * 100) %>%
  ggplot() +
  geom_bar(aes(x=lss_year, y=percent,
               fill=lss_private), 
           stat="identity", alpha=0.75, 
           position = 'dodge') +
  theme_stata() + 
  labs(title = "Number of Test Takers by Year",
       x = "Year",
       y = "Percent")

