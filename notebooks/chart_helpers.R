# Marcelo Eduardo Redoschi
# Chart helpers - COVID 19 calculations
# Last updated: 17 - May - 2020

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
                       color = cubic_rate_color) + ggtitle(cubic_chart_title) + 
      xlab(xlabel_text) + ylab("current vs. 3 day % rate")
    
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


# More generic formulation
combined_rates_chart <-
  function(df,
           title_txt,
           x_label_prefix,
           current_rate_color,
           cubic_rate_color,
           seventh_rate_color) {
    chart <-
      ggplot(data = df) + geom_line(aes(x = dt, y = seventh_perc_rate),
                                    color = seventh_rate_color,
                                    linetype = 2) + geom_line(aes(x = dt, y = current_perc_rate), color = current_rate_color) +
      geom_line(aes(x = dt, y = cubic_perc_rate),
                color = cubic_rate_color,
                linetype = 4) +
      ggtitle(title_txt) + xlab(paste(
        x_label_prefix,
        format(min(df$dt), "%d %b"),
        "-",
        format(max(df$dt), "%d %b %Y")
      )) + ylab("current vs. previous 3 and 7 day average % growth rates")
    chart
  }

provincial_cubic_rate_chart <-
  function(df, selected_province_name) {
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

provincial_combined_rates_chart <-
  function(df, selected_province_name) {
    # Set the appropriate parameters
    title_txt <- paste(selected_province_name, "province")
    x_label_prefix <- 'COVID-19 total case progression'
    current_rate_color <- "#017365"
    cubic_rate_color <- "#540331"
    seventh_rate_color <- "orange"
    
    combined_rates_chart(
      df,
      title_txt,
      x_label_prefix,
      current_rate_color,
      cubic_rate_color,
      seventh_rate_color
    )
    
  }

provincial_combined_rates_from_dt_chart <-
  function(df, selected_province_name, starting_dt) {
    df <- df[df$dt >= starting_dt,]
    
    provincial_combined_rates_chart(df, selected_province_name)
    
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
