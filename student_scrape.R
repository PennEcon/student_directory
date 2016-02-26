library(rvest)
library(data.table)

#student directory URL
page1 <- "http://economics.sas.upenn.edu/graduate-program/current-students"

#need both students & total # of pages from first page, so treat separately
students_html <- html(page1)

#relevant XPath selectors
last_xp <- '//*[@id="main_content"]/div/div[2]/ul/li[8]/a'
table_xp <- '//*[@id="main_content"]/div/div[1]/table'

#total number of remaining student pages
page_n <-
  as.integer(gsub(".*\\=", "", 
                  html_attr(html_nodes(students_html, 
                                       xpath = last_xp)[[1]], "href")))

#convenience
html_to_table <- function(html)
  html_nodes(html, xpath = table_xp) %>% html_table() %>% `[[`(1L) %>% setDT()

#acquire data, concatenate
students <- 
  rbindlist(c(list(html_to_table(students_html)),
              lapply(1:page_n, 
                     function(kk) html(paste0(page1, "?page=", kk)) %>% 
                       html_to_table)))[ , Photo := NULL] #don't need Photo

#for usability
setnames(students, c("name", "email", "start_year", "office"))

#now play.
## distribution of students by floor
students[ , .N, keyby = substr(office, 1, 1)]
