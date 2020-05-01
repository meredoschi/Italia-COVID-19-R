# Marcelo Eduardo Redoschi
# helper functions - COVID 19 calculations
# Last updated: 22 - 4 - 2020

import_csv<-function(fname) { 
  # na.string explicitly set since NA is by coincidence, the Naples province abbreviation!
  read.csv(fname,encoding="UTF-8", na.strings="undefined")   
}


today <- function() {
  format(Sys.time(), "%Y-%m-%d")
  
}

days_before_today <- function(n) {
  ymd(today()) - n
  
}

retrieve_most_recent_dt<-function(df) { 
  max(df$dt) 
}

yesterday <- function() {
  days_before_today(1)
}

two_days_ago  <- function() {
  days_before_today(2)
}

three_days_ago  <- function() {
  days_before_today(3)
}

three_days_ago  <- function() {
  days_before_today(3)
}


# Useful for 'days before' calculations 
head_na<-function(vec, n) {
  
  na_filler<-rep(NA,n)
  num_observations_to_retain<-length(vec)-n
  observations_to_keep<-head(vec, num_observations_to_retain)
  c(na_filler,observations_to_keep)
}

# n = number of inactive cases (generally at a later date).  Used in "backlog" computations.
backlog_dt  <- function(df, n) {
  temp <- df[df$positives_remaining >= n,]
  min(temp$dt)
}

# df = dpc_provinces (from the Protezione Civile dataset)
trentino_sudtirol_fix <- function(df, trentino_sudtirol_region_name) {
  df$denominazione_regione <- as.character(df$denominazione_regione)
  
  trentino_sudtirol_province_rows <-
    grep("Trento|Bolzano", df$denominazione_provincia)
  
  matching_rows <- df[(trentino_sudtirol_province_rows),]
  
  for (i in 1:nrow(matching_rows)) {
    matching_province <- matching_rows[i,]
    
    df[df$codice_provincia == matching_province$codice_provincia,]$denominazione_regione <-
      trentino_sudtirol_region_name
    
  }
  
  # Convert column back to factor, after fixing it
  df$denominazione_regione <- as.factor(df$denominazione_regione)
  
  df
}

# df = provinces
provinces_regional_territory_code_fix <- function(df) {
  df$regional_territory_code <- as.character(df$regional_territory_code)
 
  trentino_sudtirol_territory_code<-'ITDA'
  
  trento_or_bolzano_indices <-
    grep("Trento|Bolzano", df$province_name)
  
  
  for (indx in trento_or_bolzano_indices) { 
    df[indx,]$regional_territory_code<-trentino_sudtirol_territory_code
    
  } 
  
  df 
  
  
}

expand_dt_columns <- function(df, nation_or_province_column_name, attrib_column_name) {
  
  recorded_dates<-as.character(uniq_dates(df)) # This cast is needed! 
  
  for (recorded_dt in recorded_dates) {
    
    df_temp<-retrieve_attrib_value_on_dt(df,recorded_dt, nation_or_province_column_name, attrib_column_name) 
      
        df<-inner_join(df,df_temp)
  } 
  
  df 
  
}

append_dt_to_col_name<-function(attrib,specified_dt) {
  
  paste(attrib,as.character(specified_dt),sep="_")
  
} 

# df = dataframe with "expanded" date columns an attribute (attrib), start and finish dates
# e.g. total_cases, start_dt="2020-4-1", finish_dt="2020-4-2" 
calculate_delta<-function(df, attrib, start_dt, finish_dt) { 
  start_date<-ymd(start_dt)
  finish_date<-ymd(finish_dt)  
  start_dt_column_name<-append_dt_to_col_name(attrib, start_date)
  finish_dt_column_name<-append_dt_to_col_name(attrib, finish_date)
  
  #  num_days<-finish_date-start_date
  #  print(num_days)
  expanded_columns<-select(df,all_of(start_dt_column_name), all_of(finish_dt_column_name))
  start_dt_value<-expanded_columns[1,1] # First row, first column   
  finish_dt_value<-expanded_columns[1,2] # First row, second column with all equal values, by definition, so we just pick the first one.   
  finish_dt_value-start_dt_value
  
  
}
#  Filter out rows marked "In fase di definizione/aggiornamento"
filter_extraneous_rows <- function(df) {
  to_be_determined_or_updated <-
    "In fase di definizione/aggiornamento"
  df[df$denominazione_provincia != to_be_determined_or_updated,]
  
}

# df = dataframe with information for one or more provinces with the corresponding region they belong to
dpc_region_names <- function(df) {
  region_names <- distinct(select(df, denominazione_regione))
  ordered_region_names <-
    arrange(region_names, denominazione_regione)
  as.character(ordered_region_names$denominazione_regione)
}

dpc_province_names <- function(df) {
  province_names <- distinct(select(df, denominazione_provincia))
  ordered_province_names <-
    arrange(province_names, denominazione_provincia)
  as.character(ordered_province_names$denominazione_provincia)
}

# n = Number of digits
rounded<-function(df, column_names_to_round, n) { 
 
  col_names<-colnames(df)
  
  for (i in 1:length(column_names_to_round)) { 
    
    column_name<-column_names_to_round[i]
    
    column_indx<-grep(column_name,col_names)
  
    df[,column_indx]<-round(df[,column_indx], digits=n)
    }
  
  df 
  }

#df = provinces_data (i.e. with province names as used by the dpc)
# istat_provinces = Province names following ISTAT

dpc_to_istat_province_name_fix <- function(df, istat_provinces_df) {

  dpc_provinces <-
  dpc_province_names(df) # makes use of helper function
province_names_to_adjust <-
  setdiff(dpc_provinces, as.character(istat_provinces_df$province_name))

df$denominazione_provincia <-
  as.character(df$denominazione_provincia)
for (i in 1:length(province_names_to_adjust)) {
  province_name_initials <- substring(province_names_to_adjust[i], 1, 5)
  record_to_read_indx <-
    grep(province_name_initials, istat_provinces$province_name)
  formal_province_name <-
    as.character(istat_provinces[record_to_read_indx, ]$province_name)
  record_to_change_indx <-
    grep(province_name_initials,
         df$denominazione_provincia)
  df$denominazione_provincia[record_to_change_indx] <-
    as.character(formal_province_name) # from the ISTAT dataset
  
}

  # convert province name (denominazione_provincia) column back to factor
  df$denominazione_provincia <-
  as.factor(df$denominazione_provincia)
  
  df 

} 


consistent_region_names <- function(istat_df, dpc_df) {
  # Default: factor
  istat_df$region_name <- as.character(istat_df$region_name)
  dpc_df$denominazione_regione <-
    as.character(dpc_df$denominazione_regione)
  
  distinct(inner_join(
    istat_df,
    dpc_df,
    by = c('region_name' = 'denominazione_regione')
  ))$region_name
}

consistent_province_names <- function(istat_df, dpc_df) {
  # Default: factor
  istat_df$province_name <- as.character(istat_df$province_name)
  dpc_df$denominazione_provincia <-
    as.character(dpc_df$denominazione_provincia)
  
  distinct(inner_join(
    istat_df,
    dpc_df,
    by = c('province_name' = 'denominazione_provincia')
  ))$province_name
}

# istat_df = Istat regions, dpc_df = Provinces
misspelled_region_names <- function(istat_df, dpc_df) {
  setdiff(dpc_region_names(dpc_df),
          consistent_region_names(istat_df, dpc_df))
}

# istat_df = Istat provinces, dpc_df = Provinces
misspelled_province_names <- function(istat_df, dpc_df) {
  setdiff(dpc_province_names(dpc_df),
          consistent_province_names(istat_df, dpc_df))
}

fix_province_names <- function(istat_df, dpc_df) {
  dpc_df$denominazione_provincia <-
    as.character(dpc_df$denominazione_provincia)
  
  for (misspelled_province_name in misspelled_province_names(istat_df, dpc_df)) {
    abbreviated_name <- substring(misspelled_province_name, 1, 5)
    istat_province_indx <-
      grep(abbreviated_name, istat_df$province_name)
    istat_province_name <-
      as.character(istat_df[istat_province_indx,]$province_name)
    dpc_province_indices <-
      grep(abbreviated_name, dpc_df$denominazione_provincia)
    dpc_df[dpc_province_indices,]$denominazione_provincia <-
      istat_province_name
  }
  
  dpc_df$denominazione_provincia <-
    as.factor(dpc_df$denominazione_provincia)
  
  dpc_df
}

fix_region_names <- function(istat_df, dpc_df) {
  dpc_df$denominazione_regione <-
    as.character(dpc_df$denominazione_regione)
  
  for (misspelled_region_name in misspelled_region_names(istat_df, dpc_df)) {
    abbreviated_name <- substring(misspelled_region_name, 1, 5)
    istat_region_indx <-
      grep(abbreviated_name, istat_df$region_name)
    istat_region_name <-
      as.character(istat_df[istat_region_indx,]$region_name)
    dpc_province_indices <-
      grep(abbreviated_name, dpc_df$denominazione_regione)
    dpc_df[dpc_province_indices,]$denominazione_regione <-
      istat_region_name
  }
  
  dpc_df$denominazione_regione <-
    as.factor(dpc_df$denominazione_regione)
  
  dpc_df
  
}

# df = dpc_province_data 

# Column named 'data' (Italian word for 'date') contains date time information
add_dt_column<-function(df) { 
  
  df$dt<-ymd(substring(df$data,1,10))
  df
}

# Returns a dataframe - filters records by the specified date and relabels the dt column to "attribute_y_m_d"
# scope = nation (for national), nome_provincia (for provinces)
retrieve_attrib_value_on_dt<-function(df,specified_dt, nation_or_province_column_name, attrib_column_name) {
  
  
  attrib_on_dt_txt<-paste(attrib_column_name,as.character(specified_dt),sep="_")
  
  df_data_for_specified_dt<-df[df$dt==specified_dt,]
  
  df_attrib_for_dt<-select(df_data_for_specified_dt,all_of(nation_or_province_column_name), attrib_column_name)
  col_names<-colnames(df_attrib_for_dt)
  revised_col_names<-gsub(attrib_column_name,attrib_on_dt_txt,col_names)
  colnames(df_attrib_for_dt)<-revised_col_names
  df_attrib_for_dt
}

uniq_dates<-function(df) { 
  
  sort(unique(df$dt))
}

# ---------- Provinces calculation ----------

# General formulation

# Before the latest, most recent recorded observation that is.
days_before<-function(df,n) { 
  most_recent_dt<-max(df$dt)
  most_recent_dt-n
}

total_cases_on_dt<-function(df, specified_dt) { 
  
  df[df$dt==specified_dt,]$totale_casi
  
}

# Specific for the latest (most recent) observation
total_cases_latest<-function(df) {
  total_cases_on_dt(df, retrieve_most_recent_dt(df))
}

filtered_by_region<-function(df, region_name) {
  df[df$denominazione_regione==region_name,]
    
}

filtered_for_the_most_recent_days<-function(df, n) {
  most_recent_dt<-max(df$dt)
  some_days_before<-most_recent_dt-n

    df[df$dt>some_days_before,]
  
}

rates_formatted_for_printing<-function(df) { 

df$percent_rate <-
  round(df$current_perc_rate, digits = 2)
df$three_day_rate <-
  round(df$cubic_perc_rate, digits = 2)
df$current_perc_rate <- NULL
df$cubic_perc_rate <- NULL
df$dt <- NULL

df 

}

# ---------- ISTAT DATA ----------

process_istat_population_csv<-function(population_csv_fname) { 
  
  df<-read.csv(population_csv_fname,encoding="UTF-8",na.strings="undefined") 
  df_all_genders<-df[df$Gender=='total',]
  df_all_marital<-df[df$'Marital.status'=='total',]
  df_marital_gen<-df_all_marital[df_all_marital$Gender=='total',]
  df_mrt_gen_age<-df_marital_gen[df_marital_gen$ETA1=='TOTAL',]
  df<-select(df_mrt_gen_age, ITTER107, Territory, Value)
  df
} 

population_intl_column_names<-function(df) { 
  
  col_names<-colnames(df)
  intl_col_names<-gsub("ITTER107","territory_code",col_names)
  intl_col_names<-gsub("Territory","territory_name",intl_col_names)
  intl_col_names<-gsub("Value","population",intl_col_names)
  colnames(df)<-intl_col_names
  df
} 

# Italy
retrieve_istat_country<-function(istat_df) {
  istat_population[nchar(as.character(istat_df$territory_code))==2,]
}

# "Zones" - geographical areas in the country (Center, Islands, Northeast, Northwest, South)
retrieve_istat_zones<-function(istat_df) {
  istat_zones<-istat_population[nchar(as.character(istat_df$territory_code))==3,]
  istat_zones_ordered_by_code<-arrange(istat_zones, territory_code)
  istat_zones_ordered_by_code
}

# Regions (largest subnational unit, similar to a state or province in some countries)
retrieve_istat_regions<-function(istat_df) { 
istat_regions<-istat_df[nchar(as.character(istat_df$territory_code))==4,]
istat_regions<-arrange(istat_regions, territory_name)
# Filter autonomous provinces
autonomous_provinces_indices<-grep("Provincia Autonoma",istat_regions$territory_name)
istat_regions<-istat_regions[-autonomous_provinces_indices,]
col_names<-colnames(istat_regions)
intl_col_names<-gsub("territory_name","region_name",col_names)
colnames(istat_regions)<-intl_col_names
istat_regions 
}


# Italian provinces are at the sub-subnational level (i.e. belong to a Region)
retrieve_istat_provinces<-function(istat_df) { 
  istat_provinces<-istat_df[nchar(as.character(istat_df$territory_code))==5,]
  col_names<-colnames(istat_provinces)
  intl_col_names<-gsub("territory_name","province_name",col_names)
  colnames(istat_provinces)<-intl_col_names
  istat_provinces<-arrange(istat_provinces, province_name)
  # Returns results sorted in alphabetical order by province name
  istat_provinces
}

# ----- Charts -----

cubic_rate_boxplot_chart <-
  function(df,
           selected_region,
           current_rate_color,
           cubic_rate_color,
           xlabel_text,
           cubic_rate_line_type) {
    cubic_chart_title <-
      paste(
        selected_region,
        format(three_days_before, "%d %b"),
        "-",
        format(most_recent_dt, "%d %b %Y")
      )
    cubic_rate_chart <-
      ggplot(df) + geom_boxplot(
        aes(y = cubic_perc_rate, x = denominazione_provincia),
        color = current_rate_color,
        linetype = cubic_rate_line_type
      ) + geom_boxplot(aes(y = current_perc_rate, x = denominazione_provincia),
                       color = cubic_rate_color) + ggtitle(cubic_chart_title) + xlab(xlabel_text) + ylab("current vs. 3 day % rate")
    
  }

styled_x_axis <- function(chart, font_size, font_angle)  {
  label_text_style <-
    element_text(
      face = "bold",
      color = "black",
      size = font_size,
      angle = font_angle
    )
  
  chart <- chart + theme(axis.text.x = label_text_style)
  
  chart
}
# More generic formulation 
current_and_cubic_rate_chart <-
  function(df,
           title_txt,
           x_label_prefix,
           current_rate_color,
           cubic_rate_color) {
    chart <-
      ggplot(data = df) + geom_line(aes(x = dt, y = cubic_perc_rate),
                                    color = cubic_rate_color,
                                    linetype = 2) + geom_line(aes(x = dt, y = current_perc_rate), color = current_rate_color) +
      ggtitle(title_txt) + xlab(paste(
        x_label_prefix,
        format(min(df$dt), "%d %b"),
        "-",
        format(max(df$dt), "%d %b %Y")
      )) + ylab("current vs. cubic (last three days) % growth rate")
    chart
  }

# More generic formulation 
current_and_seven_day_rate_chart <-
  function(df,
           title_txt,
           x_label_prefix,
           current_rate_color,
           seventh_rate_color) {
    chart <-
      ggplot(data = df) + geom_line(aes(x = dt, y = seventh_perc_rate),
                                    color = seventh_rate_color,
                                    linetype = 3) + geom_line(aes(x = dt, y = current_perc_rate), color = current_rate_color) +
      ggtitle(title_txt) + xlab(paste(
        x_label_prefix,
        format(min(df$dt), "%d %b"),
        "-",
        format(max(df$dt), "%d %b %Y")
      )) + ylab("current vs. previous 7 day average % growth rate")
    chart
  }

provincial_cubic_rate_chart <- function(df, selected_province_name) {

  # Set the appropriate parameters
  title_txt <- paste(selected_province_name, "province")
  x_label_prefix <- 'COVID-19 total case progression'
  current_rate_color <- "#017365"
  cubic_rate_color <- "#540331"

  current_and_cubic_rate_chart(df,
                               title_txt,
                               x_label_prefix,
                               current_rate_color,
                               cubic_rate_color)
  
}

provincial_seven_day_rate_chart <-
  
  function(df, selected_province_name) {
  
    # Set the appropriate parameters
    
    title_txt <- paste(selected_province_name, "province")
    x_label_prefix <- 'COVID-19 total case progression'
    current_rate_color <- "#017365"
    seventh_rate_color <- "#A8B600"
  
    current_and_seven_day_rate_chart(df,
                                     title_txt,
                                     x_label_prefix,
                                     current_rate_color,
                                     seventh_rate_color)
    
  }


# ----- Column translations -----

# National
translated_national_column_names<-function(df) { 

col_names<-colnames(df)
intl_col_names<-gsub("ricoverati_con_sintomi","hospitalized_with_symptoms",col_names)
intl_col_names<-gsub("terapia_intensiva","intensive_care",intl_col_names)
intl_col_names<-gsub("totale_ospedalizzati","hospitalized_total",intl_col_names)
intl_col_names<-gsub("isolamento_domiciliare","home_isolation",intl_col_names)
intl_col_names<-gsub("variazione_totale_positivi","num_positives_variation",intl_col_names)
intl_col_names<-gsub("totale_positivi","positives_remaining",intl_col_names)
intl_col_names<-gsub("nuovi_positivi","new_positives",intl_col_names)
intl_col_names<-gsub("dimessi_guariti","total_discharged_healed",intl_col_names)
intl_col_names<-gsub("deceduti","total_deceased",intl_col_names)
intl_col_names<-gsub("totale_casi","total_cases",intl_col_names)
intl_col_names<-gsub("tamponi","tests",intl_col_names)
intl_col_names<-gsub("note_","notes_",intl_col_names)
intl_col_names<-gsub("stato","nation",intl_col_names)
# Added for provinces
intl_col_names<-gsub("denominazione_provincia","province_name",intl_col_names)
colnames(df)<-intl_col_names
df 


} 

# Zones (v = vector, e.g. istat_zones$territory_name) 
translate_geographical_zones<-function(v) { 

    v<-gsub("Nord-ovest","Northwest",v)
    v<-gsub("Nord-est","Northeast",v)
    v<-gsub("Centro (I)","Center",v, fixed=TRUE)
    v<-gsub("Sud","South",v)
    v<-gsub("Isole","Islands",v)
    
    v
}   

# Provinces
translated_province_column_names<-function(df) { 
  
  col_names<-colnames(df)

  intl_col_names<-gsub("totale_casi","total_cases",col_names)
  intl_col_names<-gsub("denominazione_provincia","province_name",intl_col_names)
  colnames(df)<-intl_col_names
  df 
} 

revised_province_column_names<-function(df) { 
  
  col_names<-colnames(df)
  
  revised_col_names<-gsub("current_perc_rate","daily_growth",col_names)
  revised_col_names<-gsub("cubic_perc_rate","three_day_rate",revised_col_names)
  revised_col_names<-gsub("province_name","province",revised_col_names)
  revised_col_names<-gsub("per_capita_rate","per_capita",revised_col_names)
  colnames(df)<-revised_col_names
  df 
}
## Three and seven day averages 

# Weighted average rates (for the previous three and seven days, with respect to a particular attribute)
# df = country or province (sub-national) data
add_three_and_seven_day_rate_columns<-function(df, attrib) { 
  attrib_whole_word<-paste("^",attrib,'$',sep='')
  attrib_col_indx<-grep(attrib_whole_word,colnames(df))
  attrib_col<-df[,attrib_col_indx] # i.e. a vector 
    
  df$attrib_day_before<- head_na(attrib_col, 1) 
  df$attrib_three_days_before <- head_na(attrib_col, 3)
  df$attrib_seven_days_before <- head_na(attrib_col, 7)
  
  df$current_rate <-
  (attrib_col) / (df$attrib_day_before)

  df$current_perc_rate <- (df$current_rate - 1) * 100

  df$growth_factor_in_three_days <- (attrib_col) / (df$attrib_three_days_before)

  df$cubic_rate <-
    '^'(df$growth_factor_in_three_days, 1 / 3)
  df$cubic_perc_rate <-
    (df$cubic_rate - 1) * 100
  
  df$growth_factor_in_seven_days <- (attrib_col) / (df$attrib_seven_days_before)

  df$seven_day_rate <- '^'(df$growth_factor_in_seven_days, 1 / 7)

  df$seventh_perc_rate <-(df$seven_day_rate - 1) * 100
  
  # Rename columns
  colnames(df)<-gsub("attrib",attrib,colnames(df))
  
  df 

}