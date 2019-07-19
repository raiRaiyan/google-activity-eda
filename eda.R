library(jsonlite)
library(ggplot2)
library(RColorBrewer)

getPalette = colorRampPalette(brewer.pal(9, "Set1"))

headersToRemove = c("Home", "OnePlus Launcher",
                   "com.oneplus.applocker", "Evie Launcher",
                   "Samsung Experience Home", "Android")

# data <- read.csv("activity.csv", stringsAsFactors = F)
data <- fromJSON("~/misc/act/Takeout/My Activity/Android/MyActivity.json")
data$time <- as.POSIXct(data$time, format = "%Y-%m-%dT%H:%M:%S", tz="UTC")
attributes(data$time)
data <- data[!is.na(data$time),]

#Subset data (remove all activity occuring less than 500 times)
summ <- summary(as.factor(data$header), maxsum = 500)
filtered <- summ[which(summ < 400)]

subsetted <- data[!(data$header %in% headersToRemove),]
subsetted[subsetted$header %in% names(filtered), 'header'] <- "Others"

# subsetted <- data[data$header %in% names(filtered) & 
                    # !(data$header %in% headersToRemove),]




# Frequncy of app
ggplot(data = subsetted, aes(x = reorder(header, header, length), label = "Count")) + 
  geom_bar( width = 0.5) +
  geom_text(stat = 'count', aes(label=..count..),  vjust = -1, size = 2.5) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  scale_x_discrete(labels = function(x) substr(x, 0, 20)) +
  ggtitle("Frequecy of App usage", "Only Showing apps used more than 400 times")


#Usage by day
ggplot(data = data, aes(x = format(time, "%a"))) + 
  geom_line(aes(group=1), stat='count') +
  geom_point(aes(group=1), stat='count') +
  geom_text(stat = 'count', aes(label=..count..),  vjust = -1, size = 2.5) +
  scale_x_discrete(limits = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")) +
  ggtitle("Total events by day")

#Frequency of app by day
ggplot(data = subsetted, aes(x = format(time, "%a"), fill=reorder(header, header, length))) +
  geom_bar(width = 0.5) + 
  scale_fill_manual(values = getPalette(length(unique(subsetted$header)))) + 
  geom_text(stat = 'count', 
            aes(label=..count..),  
            position = position_stack(vjust = 0.5),
            size = 2.5, color = 'white') +
  theme(legend.text=element_text(size=7)) + 
  scale_x_discrete(limits = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")) +
  ggtitle("Frequency of app usage by day", "Only shows apps used more than 500 times")

otherPart <- data[!(data$header 
                                    %in% c("WhatsApp Messenger",
                                          "Google Chrome: Fast & Secure",
                                          headersToRemove)) &
                               data$header %in% names(summ[which(summ > 200)]), ]
ggplot(data = otherPart, aes(x = format(time, "%a",tz=Sys.timezone()), 
                             fill=reorder(header, header, length))) +
  geom_bar(width = 0.5) + 
  scale_fill_manual(values = getPalette(length(unique(otherPart$header)))) + 
  geom_text(stat = 'count', 
            aes(label=..count..),  
            position = position_stack(vjust = 0.5),
            size = 2.5, color = 'white') +
  theme(legend.text=element_text(size=7)) + 
  scale_x_discrete(limits = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")) +
  ggtitle("Frequency of app usage by day", "Only shows apps used more 200 times")

#Usage by hour
ggplot(data = data, aes(x = format(time, "%H", tz=Sys.timezone()))) + 
  geom_line(aes(group=1), stat='count') +
  geom_point(aes(group=1), stat='count') +
  geom_text(stat = 'count', aes(label=..count..),  vjust = -1, size = 2.5) +
  ggtitle("Hour-wise app usage")

#Usage by month
ggplot(data = data, aes(x = format(time, "%b", tz=Sys.timezone()))) + 
  geom_line(aes(group=1), stat='count') +
  geom_point(aes(group=1), stat='count') +
  geom_text(stat = 'count', aes(label=..count..),  vjust = -1, size = 2.5) +
  scale_x_discrete(limits = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
                              "Aug", "Sep", "Oct", "Nov", "Dec")) +
  ggtitle("Month-wise app usage")

#usage by year
ggplot(data = data, aes(x = format(time, "%Y", tz=Sys.timezone()))) + 
  geom_line(aes(group=1), stat='count') +
  geom_point(aes(group=1), stat='count') +
  geom_text(stat = 'count', aes(label=..count..),  vjust = -1, size = 2.5) +
  ggtitle("Year-wise app usage")

#Frequency of app by day
ggplot(data = subsetted, aes(x = format(time, "%H", tz=Sys.timezone()),
                             fill=reorder(header, header, length))) +
  geom_bar(width = 0.6) + 
  scale_fill_manual(values = getPalette(length(unique(subsetted$header)))) + 
  geom_text(stat = 'count', 
            aes(label=..count..),  
            position = position_stack(vjust = 0.5),
            size = 2, color = 'white') +
  theme(legend.text=element_text(size=5))  +
  ggtitle("Frequency of app usage by hour of the day", "Only shows apps used more than 400 times")
Love, Prison, Deadline or Distraction
