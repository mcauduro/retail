--
-- Creates a stream with a subset of the data that we are ingesting,
-- which is our way of ensuring that we only run anomaly detection on
-- the numeric columns that we pick.
--
CREATE OR REPLACE STREAM "RETAIL_KPI_ANOMALY_DETECTION_STREAM" (
  "store_id"              varchar(8),
  "workstation_id"        varchar(8),
  "operator_id"           varchar(16),
  "item_id"               varchar(16),
  "retail_kpi_metric"     integer,
  "ANOMALY_SCORE"         double,
  "ANOMALY_EXPLANATION"   varchar(512)
);

--
-- Compute an anomaly score for each record in the input stream. The
-- anomaly detection algorithm considers ALL numeric columns and
-- ignores the rest.
--
CREATE OR REPLACE PUMP "RETAIL_KPI_ANOMALY_DETECTION_STREAM_PUMP" AS
INSERT INTO "RETAIL_KPI_ANOMALY_DETECTION_STREAM"
  SELECT STREAM "store_id",
                "workstation_id",
                "operator_id",
                "item_id",
                "retail_kpi_metric",
                ANOMALY_SCORE,
                ANOMALY_EXPLANATION
  FROM TABLE(RANDOM_CUT_FOREST_WITH_EXPLANATION (
                 CURSOR( SELECT STREAM "store_id",
                                        "workstation_id",
                                        "operator_id",
                                        "item_id",
                                        "retail_kpi_metric"
                         FROM "SOURCE_SQL_STREAM_001"), 100, 256, 100000, 1, false)
  );

--
-- Create a destination stream that combines (JOINs) all the values in
-- the source stream along with the anomaly values in the anomaly stream
-- which we will then store for historic records.
--
CREATE OR REPLACE STREAM "DESTINATION_STREAM" (
  "COL_timestamp"               timestamp,
  "store_id"                    varchar(8),
  "workstation_id"              varchar(8),
  "operator_id"                 varchar(16),
  "item_id"                     varchar(16),
  "quantity"                    integer,
  "regular_sales_unit_price"    real,
  "retail_price_modifier"       real,
  "retail_kpi_metric"           integer,
  "ANOMALY_SCORE"               double
  --"ANOMALY_EXPLANATION"         varchar(512)
);

CREATE OR REPLACE PUMP "DESTINATION_STREAM_PUMP" AS
INSERT INTO "DESTINATION_STREAM"
  SELECT STREAM "SOURCE_STREAM"."COL_timestamp",
                "SOURCE_STREAM"."store_id",
                "SOURCE_STREAM"."workstation_id",
                "SOURCE_STREAM"."operator_id",
                "SOURCE_STREAM"."item_id",
                "SOURCE_STREAM"."quantity",
                "SOURCE_STREAM"."regular_sales_unit_price",
                "SOURCE_STREAM"."retail_price_modifier",
                "SOURCE_STREAM"."retail_kpi_metric",
                "ANOMALY_STREAM"."ANOMALY_SCORE"
                --"ANOMALY_STREAM"."ANOMALY_EXPLANATION"
  FROM "SOURCE_SQL_STREAM_001" AS "SOURCE_STREAM"
  JOIN "RETAIL_KPI_ANOMALY_DETECTION_STREAM" AS "ANOMALY_STREAM"
    ON  "SOURCE_STREAM"."store_id"       = "ANOMALY_STREAM"."store_id"
    AND "SOURCE_STREAM"."workstation_id" = "ANOMALY_STREAM"."workstation_id"
    AND "SOURCE_STREAM"."operator_id"    = "ANOMALY_STREAM"."operator_id"
    AND "SOURCE_STREAM"."item_id"        = "ANOMALY_STREAM"."item_id";
