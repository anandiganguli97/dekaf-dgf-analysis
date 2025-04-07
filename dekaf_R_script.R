install.packages("dplyr")
library(dplyr)
library(ggplot2)

#Step 1: Load and inspect the data
df <- read_excel("C:/Users/anand/Downloads/dekaf_dgf.xlsx", na=".")

summary(df)
str(df)
head(df)

# Step 2: Inspect the dataset
glimpse(df)
summary(df)
colSums(is.na(df))  # Check missing values

# Step 3: Recode binary and categorical variables
df <- df %>%
  mutate(
    dgf = factor(dgf, levels = c(0, 1), labels = c("No", "Yes")),              # Delayed Graft Function
    gender = factor(gender, levels = c(0, 1), labels = c("Female", "Male")),   # Donor Gender
    dcd_yn = factor(dcd_yn, levels = c(0, 1), labels = c("No", "Yes")),        # Donation after Cardiac Death
    raceblack = factor(raceblack, levels = c(0, 1), labels = c("Other", "Black")) # Race Group
  )

# Step 4: Create derived donor age group variable
df <- df %>%
  mutate(
    donorage = ifelse(agedonor16 > 16, ">16", "≤16"),
    donorage = factor(donorage, levels = c("≤16", ">16"))
  )
#Step 5:Save the cleaned data
write.csv(df, "data/cleaned_dekaf_dgf.csv", row.names = FALSE)

#Step 6: Visualize distribution of dgf donor's age by dgf status
df$dgf <- factor(df$dgf, levels = c(0, 1), labels = c("No", "Yes"))

ggplot(df, aes(x = dgf, y = agedonor16, fill = dgf)) +
  geom_boxplot() +
  xlab("DGF Status") +
  ylab("Donor Age") +
  ggtitle("Distribution of Donor Age by DGF Status") +
  theme_minimal()

# Step 7: Barplot displaying proportion of dgf by dcd status
ggplot(df, aes(x = dcd_yn, fill = dgf)) +
  geom_bar(position = "fill") +
  xlab("DCD Status") +
  ylab("Proportion with DGF") +
  ggtitle("Proportion of DGF by DCD Status") +
  theme_minimal()

ggsave("output/plots/boxplot_donor_age_by_dgf.png", width = 7, height = 5)
ggsave("output/plots/barplot_dgf_by_dcd_status.png", width = 7, height = 5)


#Step 8: Chi square test donar age vs dgf
table_age_dgf <- df %>%
  with(table(agedonor16,dgf))
table_age_dgf
chisq.test(table_age_dgf)

#Step 9: Chi square test dcd status vs dgf
table_dcd_dgf <-df %>%
  with(table(dcd_yn, dgf))
table_dcd_dgf
chisq.test(table_dcd_dgf)

#Step 10:Unadjusted Regression model with age and dcd status
model1<-glm(dgf~agedonor16+dcd_yn,
            data=df, family=binomial)
summary(model1)
exp(coef(model1))

#Step 11: Adjusted Regression model with Race and gender
model2<-glm(dgf~agedonor16+dcd_yn+raceblack+gender,
          data=df, family=binomial)
model2
summary(model2)
exp(coef(model2))

#Step 12: Model2 with an interaction term between age and dcd status
model3<-glm(dgf~agedonor16+dcd_yn+raceblack+gender+agedonor16*dcd_yn,
            data=df, family=binomial)
summary(model3)






