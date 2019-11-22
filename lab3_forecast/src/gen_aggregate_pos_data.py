import datetime as dt
import random

class PointOfSale:
    PRODUCTS = [ "staplers", "post-its", "markers", "dry-eraser", "flowers", "beer" ]
    STORES   = [ "SFO1", "SFO2", "SFO3", "LAX", "NYC", "SEA", "BOS" ]

    # simulates a sale at the register
    def sale_event(self, time):
        is_weekend = self._is_weekend(time)

        demand  = random.randint(100, 300) if is_weekend else random.randint(1, 50)
        product = self.PRODUCTS[random.randint(4, 5)] if is_weekend else self.PRODUCTS[random.randint(0, 3)]

        return {
            "timestamp": time.strftime('%Y-%m-%d %H:00:00'),
            "item_id": product,
            "demand": demand,
            "location": self.STORES[random.randint(0, len(self.STORES) - 1)]
        }

    # generates simulated aggregated sales on an hourly basis
    def aggregate_hourly_sale_events(self, time):
        no_of_products_sold = random.randint(1, len(self.PRODUCTS) - 1)

        sale_events = []
        for i in range(no_of_products_sold):
            sale_events.append(self.sale_event(time))

        return sale_events

    # private

    def _is_weekend(self, time):
        return time.weekday() > 5


# Main

pos = PointOfSale()
sale_events = []

# Generate sales data for 3 months. We will assume stores in different locations
# operate from 9a - 6p. We will generate aggregate sales by the hour.
start_date = dt.datetime.strptime("Jul 1, 2019", "%b %d, %Y")
end_date   = dt.datetime.strptime("Sep 30, 2019", "%b %d, %Y")

for day in range((end_date - start_date).days + 1): # for each day from start date to end date...
    date = start_date + dt.timedelta(days = day)

    for hour in range(10, 17): # for each working hour in the day...
        time = date + dt.timedelta(hours = hour)
        sale_events += pos.aggregate_hourly_sale_events(time)

f = open('retail_analytics_python.csv', 'w+')

for event in sale_events:
    # the below just converts an event in json dict format to csv
    event_as_csv = ",".join(list(str(value) for value in event.values()))
    print(event_as_csv)
    f.write(event_as_csv + "\n")

print("Done writing events to retail_analytics_python.csv")
