require 'yaml'
require 'aws-sdk'

class PosDataGenerator
  STREAM_NAME = 'RetailDataStream'

  STORE_LOCATIONS = [ "sfo", "lax", "san", "jfk", "iad", "ord", "sea", "bos" ]

  def initialize
    # In a prod setting, it is MUCH better to use Cognito based
    # temporary credentials instead of long-lived AWS credentials.
    creds          = YAML.load(File.read 'config/aws.yml')
    credentials    = Aws::Credentials.new(creds['access_key_id'], creds['secret_access_key'], creds['session_token'])

    @kinesis_client = Aws::Kinesis::Client.new(credentials: credentials, region: 'us-west-2')
  end

  # batch_mode is true by default
  def run(batch_mode: true)
    puts "Starting..."

    if batch_mode # send 20-ish POS events at once
      loop do
        events = []

        30.times do
          events << pos_event

          if abnormal?
            rand(1..4).times { events << pos_event(abnormal: true)}
          end
        end

        puts "Sent #{events.size} events..."
        stream_data = []
        events.each do |event|
          stream_datum = {
              data:          event.to_json,
              partition_key: "shard_#{rand(1..2)}"
          }

          stream_data << stream_datum
        end

        @kinesis_client.put_records(
          records:      stream_data,
          stream_name:  STREAM_NAME,
        )
      end
    else     # if not batch mode, send each POS event one by one
      loop do
        event = abnormal? ? pos_event(abnormal: true) : pos_event

        @kinesis_client.put_record(
         stream_name:   STREAM_NAME,
         data:          event.to_json,
         partition_key: "shard_#{rand(1..2)}" # for our purposes, this can be random
        )

        puts event.to_json
      end
    end

    puts "Done."
  rescue Aws::Kinesis::Errors::ServiceError => e
    puts e
  end

  private

  def pos_event(abnormal: false)
    jul_01 = Time.parse("Jul 1, 2019 09:00:00")
    sep_30 = Time.parse("Sep 30, 2019 17:00:00")

    retail_kpi_metric = abnormal ? rand(1..10) : rand(80..95)

    {
        timestamp:                rand(jul_01..sep_30).strftime("%Y-%m-%dT%H:%M:%S.0"),
        store_id:                 "store_#{rand(10..50)}",
        workstation_id:           "pos_#{rand(1..10)}",
        operator_id:              "cashier_#{rand(1..200)}",
        item_id:                  "item_#{rand(1000..9999)}",
        quantity:                 rand(1..6),
        regular_sales_unit_price: rand(100..7999)/100.0,
        retail_price_modifier:    rand(100..900)/100.0,
        retail_kpi_metric:        retail_kpi_metric
    }
  end

  def abnormal?
    rand(0..100) <= 3 # generate anomalies 3% of the time
  end
end

pos_data_generator = PosDataGenerator.new
pos_data_generator.run
