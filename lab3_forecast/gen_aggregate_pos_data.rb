require 'date'
require 'time'

class PointOfSale
  PRODUCTS = [ "staplers", "post-its", "markers", "dry-eraser", "flowers", "beer" ]
  STORES   = [ "SFO1", "SFO2", "SFO3", "LAX", "NYC", "SEA", "BOS" ]

  # simulates a sale at the register
  def sale_event(time:)
    is_weekend = weekend?(time)

    demand  = is_weekend ? rand(100..300) : rand(1..50) # if weekend, simulate high demand
    product = is_weekend ? PRODUCTS[rand(4..5)] : PRODUCTS[rand(0..3)] # choose product depending on weekday/weekend

    {
      timestamp: time.strftime("%Y-%m-%d %H:00:00"), # Amazon Forecast needs yyyy-mm-dd HH:mm:ss format
      item_id:   product,
      demand:    demand,
      location:  STORES[rand(0..STORES.count-1)]
    }
  end

  # generates simulated aggregated sales on an hourly basis
  def aggregate_hourly_sale_events(time:)
    products_sold = rand(1..PRODUCTS.count-1)

    sale_events = []
    products_sold.times do |product|
      sale_events << sale_event(time: time)
    end

    sale_events
  end

  private

    def weekend?(time)
      time.saturday? || time.sunday?
    end
end


# Main

begin
  point_of_sale = PointOfSale.new
  sale_events   = []

  # Generate sales data for 3 months. We will assume stores in different locations
  # operate from 9a - 6p. We will generate aggregate sales by the hour.
  from  = Date.parse("Jul 1, 2019")    # start date
  to    = Date.parse("Sep 30, 2019")   # and end date

  (from..to).each do |date| # for each day between start date and end date...
    (10..17).each do |hour|    # for each hour in that day...
      time = Time.parse("#{date.to_s} #{hour}:00:00")

      hourly_sale_events = point_of_sale.aggregate_hourly_sale_events(time: time)
      hourly_sale_events.each { |sale_event| sale_events << sale_event.values.join(',') }
    end
  end

  # write the list (array) of sale events to a CSV file
  open('retail_analytics.csv', 'w') { |f| f.puts sale_events }

  puts "Done writing events to retail_analytics.csv"
end
