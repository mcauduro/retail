# Lab 3 -- Forecast

In this lab, we will use aggregated retail analytics to forecast future sales. 

| <p style="color: #e57222;">A Quick Note, before we begin:</p> |  
|---|

Outside of this workshop setting, you would have already setup infrastructure for ingestion, processing, analyzing, and storing data (essentially labs 1 and 2). And you'd have data that is readily available. 

But because it takes some time to train Amazon Forecast's predictors, for the purposes of this workshop, we will simulate aggregated retail analytics data and use that data to train predictors. And work on labs 1 and 2 while the training runs in the background. 

This simulated data set is aggregated hourly and, for convenience, is included in the file ```retail_analytics.csv```. It looks something like below.

## Simulated Sample Data (aggregated hourly)

Time                | Item     | Quantity | StoreLocation
--------------------|----------|----------|--------------
2019-07-01 09:00:00 | staplers |       38 | San Francisco
2019-07-01 10:00:00 | post-its |       30 | New York
...                 |      ... |      ... |  ...
2019-07-01 14:00:00 | markers  |       29 | Los Angeles

## Regions

If you're using an AWS account vended by the Event Engine for this lab, you will be in `us-west-2`. This is displayed as "Oregon" in the top right-hand corner of the AWS console and is referred to as ```us-west-2``` when using the CLI or API.

If you're using one of your own AWS accounts, please note the region that you created your Cloud9 IDE console in and remain within that region.

### Step A

1. In the same browser window that you have the Cloud9 IDE open, open up a new browser tab and point it to https://console.aws.amazon.com/forecast. On the top right-hand corner of the console, note the region you're in. This will typically look like this:

   ![Region Selection](images/region_selection.png)
   
2. Click on 'Create dataset group'

   ![Create Dataset Group 1](images/forecast_create_dataset_group1.png)

2. We'll first give this dataset group a name. Against 'Dataset group name' enter something descriptive.

3. For 'Forecasting domain', choose 'Retail'.

4. Click 'Next'.

   ![Create Dataset Group 2](images/create_dataset_group.png)

### Step B

Now we'll create and define the schema the dataset that we'll base forecasts on. The RETAIL domain supports 3 dataset types, TARGET\_TIME\_SERIES, RELATED\_TIME\_SERIES, and ITEM\_METADATA.

TARGT\_TIME\_SERIES is the **core** dataset that has the feature (column) whose value we're trying to forecast. The other two are **optional** and can help add peripheral information (weather, color, etc.) for more accurate forecasts.

1. Enter a name for the dataset against 'Dataset Name'. For example ```JulyToSeptemberSales```.

2. For 'Frequency of your data' dropdowns, leave the first at '1' and choose 'hour' for the second.

3. For 'Data schema', copy and paste the below:
   
   This schema matches the aggregated dataset we generated in ```retail_analytics.csv```.    

    ```json
    {
    	"Attributes": [
    		{
    			"AttributeName": "timestamp",
    			"AttributeType": "timestamp"
    		},
    		{
    			"AttributeName": "item_id",
    			"AttributeType": "string"
    		},
    		{
    			"AttributeName": "demand",
    			"AttributeType": "float"
    		},
    		{
    			"AttributeName": "location",
    			"AttributeType": "string"
    		}
    	]
    }
    ```

   
4. Now click 'Next'.   

   ![Create Dataset](images/create_target_timeseries_dataset.png)



### Step C

We will now import data target timeseries dataset that we just defined

1. Before we import the target timeseries dataset, we'll need to upload the ```retail_analytics.csv``` to an Amazon S3 bucket that Amazon Forecast can access and get the dataset from.

2. Switch your browser tab back to the one where you have Cloud9 open.


3. All S3 bucket names, regardless who created them, need to be globally unique. So choose something *unique to you* and append or prepend it to ```retail-forecast``` such as ```sudoamit-retail-forecast```.

   From the Cloud9 terminal window run the below after replacing BUCKET_NAME with some unique name that you came up with for your S3 bucket. 
   
   
   ```shell
   cd lab3/src
   ```
      
   ```shell
   aws s3 mb s3://[SOME_UNIQUE_NAME]-retail-forecast
   ```
   
   ```shell
   aws s3 cp retail_analytics.csv s3://[SOME_UNIQUE_NAME]-retail-forecast/
   ```
   
   <br/> 
    
2. Switch back to the browser tab where you have Amazon Forecast open to pick up where we left off. The console should now be in the 'Import target time series dataset' screen.     

3. Enter a descriptive name for 'Dataset import name'.

4. Leave the 'Timestamp format' as-is.
 
   ![Import Target Timeseries Dataset](images/import_target_timeseries_dataset.png)


5. For 'IAM Role', click on drop-down and choose

   ![Choose Create IAM Role](images/forecast_choose_create_role.png)
   
6. Click on 'Create role'

   ![Create IAM Role](images/forecast_create_role.png)   


6. For 'Data location' copy and paste the S3 bucket name that you created earlier like so: ```s3://[SOME_UNIQUE_NAME]-retail-forecast/retail_analytics.csv```

   ![S3 Data](images/forecast_s3_data.png)


7. Click on 'Start Import'. If all is successful, you should see a flash message like so:

   ![Import Target Timeseries Success](images/import_target_timeseries_success.png)

   This should take around 2 mins. Refresh the browser a few times to see if it is complete.

### Step D

We'll now train a Predictor on this dataset that we just imported.


1. Click on 'Start' under 'Train a predictor' (in the middle column)

   ![Train Predictor](images/train_predictor.png)
   
2. Enter something descriptive for 'Predictor name'
 
3. For 'Forecast horizon' enter 30 days (we'll attempt to predict demand over the next 30 days)

4. For 'Forecast frequency' enter '1' in the first drop down and 'day' in the second. Our forecast frequency will be daily.

5. For 'Algorithm selection', choose the 'Automatic' option. Amazon Forecast will make the best decision and choose among the available forecasting algorithms. 

   Forecast supports 5 algorithms, ARIMA, DeepAR+, ETS, NPTS, and Prophet. You can read more about these algorithms here https://docs.aws.amazon.com/forecast/latest/dg/aws-forecast-choosing-recipes.html

6. For 'Forecast dimensions', click the drop-down and choose 'Location'

   ![](images/forecast_choose_dimensions.png)
   
7. **OPTIONAL** We're not assuming any holidays in this simulation, so you can choose to leave the 'Country for holidays' blank.   
   
   The final choices should have the Train predictor screen looking something like this:

   ![Predictor Details](images/predictor_details.png)   

   
7. Click on 'Train Predictor'. If all succeeds, you will see a screen that shows training is in progress

   ![Predictor Training In-progress](images/predictor_training_inprogress.png)
   

### Recap   
   
This training step can take a while, at least 20 - 30mins, so we are going to jump from here to Lab 1.

Just to recap, what we've done so far is:

* Simulated an aggregated retail analytics dataset.
* Copied this dataset to an S3 bucket.
* Imported this dataset into Forecast
* And launched a job to train a predictor on this data.

At this point, we'll jump to [Lab 1](../../lab1/instructions/lab1.md) and pick this thread back up when the training is done.
   

   
### Step E   

Once the predictor is trained, we'll generate forecasts.


1. Click on 'Start' under 'Generate forecasts'

   ![Generate forecast start](images/generate_forecast_start.png)


2. Enter a descriptive name against 'Forecast name' 


3. For the 'Predictor' drop-down, choose the predictor that we just trained in the previous step.


4. Click on 'Create a Forecast'

   ![Create Forecast](images/create_forecast.png)
   
5. If successful, there should be a flash message like below. 

   ![Create Forecast Success](images/generate_forecast_success.png)


 
   
| <p style="color: #e57222;">Note</p> This step, though shorter than training a predictor, should still take around 10 to 15mins. Given the time required for this step to complete, Let's jump to Lab 2 and pick this back up when complete.|
|---|



### Step F

1. After the forecast generation is complete, we can look up lookup forecasts for specific items. Click on 'Lookup Forecast'

   ![Forecast Dashboard](images/dashboard.png)

2. In the 'Forecast lookup' screen, enter a name for the 'Forecast'

3. We'll do our 30 day forecast from Sep 29 thru Oct 29. So, for the 'Start date', enter 2019/09/29 as the date and 09:00:00 as time

4. For the 'End date', enter 2019/10/29 as the date and 17:00:00 as the time.

5. For 'Forecast key', ```item_id``` should have already been chosen by default (required by default, since this is what we're forecasting)

6. For 'Value', enter 'staplers'

7. Click on 'Get Forecast'

   ![Lookup Forecast](images/forecast_lookup.png)
   
8. You should subsequently see a graph with P90, P50, and P10 forecasts like so

   ![Forecast Graph](images/forecast_graph.png)   

| <p style="color: #e57222;">Results Explained</p> The P10, P50, and P90 forecast values represent 10%, 50%, and 90% probability of satisfying actual demand. |
|---|

---


## Running the Code <span style="color:red;">(OPTIONAL)</color>

While you can directly use the pre-generated ```retail_analytics.csv``` file to generate forecasts, you can also modify the ```gen_aggregate_pos_data.rb``` Ruby script (or  ```gen_aggregate_pos_data.py``` in Python)  that generates this file and modify it to generate a new ```retail_analytics.csv``` file to see differences in forecast based on changes you made. 

To run this code:

cd into the ```lab3``` directory

```shell
$ cd lab3
```

install bundler (which is used to install ruby dependencies)

```shell
$ gem install bundler
```

then install dependencies

```shell
$ bundle install
```

and run the script like so...

```shell
$ ruby gen_aggregate_pos_data.rb
```

---
*[Ignore anything the below this, including any `<style>` directives]*

<style>
    body {
        background-color: #fafafa;
    }

    img {
        box-shadow:inset 0 1px 0 rgba(255,255,255,.6), 0 16px 30px 7px rgba(0,0,0,0.56), 0 0 0 0 rgba(0, 0, 0, 0.3);
        padding: 3px 5px;
        margin: 18px 0 44px;
        text-align: center;
        max-width: 80%;
        display: block;
        margin-left: auto;
        margin-right: auto;
    }

    table {
        overflow: auto;
        display: block;
    }
</style>
