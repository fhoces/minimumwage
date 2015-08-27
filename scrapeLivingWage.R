# Get living wage info for each state from the Living Wage Calculator
# (http://livingwage.mit.edu/)

library(rvest)
library(dplyr)
library(tidyr)

# Get the living wage info from each state --------------------------------
livingWageList <- list()
expensesList <- list()
for (stateIdx in 1:56) {
  # Try to get the state's source
  stateHTML <- tryCatch(html(sprintf("http://livingwage.mit.edu/states/%0.2d", stateIdx)),
                        error = function(cond) { return(NULL) },
                        warning = function(cond) { return(NULL) },
                        finally = NA)
  if (!is.null(stateHTML)) {
    # Scrape out the (long) name of the state
    stateName <- stateHTML %>% 
      html_nodes(xpath="/html/body/div[1]/div[2]/h1") %>% 
      html_text()
    stateName <- sub("Living Wage Calculation for (.*)", "\\1", stateName)

    
    # Grab the short living wage table
    stateLivingWage <- stateHTML %>%
      html_nodes(xpath="/html/body/div[1]/div[2]/div[1]/table") %>%
      html_table()
    stateLivingWage <- stateLivingWage[[1]]
    
    # Tidy the data and add it to the list
    livingWageList[[length(livingWageList)+1]] <- stateLivingWage %>% 
      gather("household_type", "hourly_wage", -1) %>%
      rename(wage_level = `Hourly Wages`) %>% 
      mutate(state_name = stateName, 
             hourly_wage = as.numeric(sub("^\\$", "", hourly_wage)))
    
    # Grab the typical expenses table
    stateExpenses <- stateHTML %>%
      html_nodes(xpath="/html/body/div/div[2]/div[2]/table") %>%
      html_table()
    stateExpenses <- stateExpenses[[1]]
    
    # Tidy the data and add it to the list
    expensesList[[length(expensesList)+1]] <- stateExpenses %>%
      gather("household_type", "annual_cost", -1) %>%
      rename(expense_category = `Annual Expenses`) %>%
      mutate(state_name = stateName,
             annual_cost = as.numeric(gsub("[\\$,]", "", annual_cost)))
  }
}
livingWage <- bind_rows(livingWageList)
typicalExpenses <- bind_rows(expensesList)


# Pull out the redundant minimum wage info into its own table -------------

minimumWage <- livingWage %>% 
  filter(wage_level == "Minimum Wage") %>% 
  select(state_name, hourly_wage) %>% 
  distinct()

livingWage <- livingWage %>%
  filter(wage_level != "Minimum Wage")


# Save DFs to CSVs --------------------------------------------------------

write.csv(minimumWage, "minimum_wage.csv", row.names = FALSE)
write.csv(livingWage, "living_wage.csv", row.names = FALSE)
write.csv(typicalExpenses, "typical_expenses.csv", row.names = FALSE)
