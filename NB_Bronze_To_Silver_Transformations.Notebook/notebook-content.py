# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "5e0b8d8e-4597-41eb-a217-e2d8837fc8c1",
# META       "default_lakehouse_name": "LH_Wind_Power_Bronze",
# META       "default_lakehouse_workspace_id": "eb35f304-a7dc-442a-982c-985acdd268c5",
# META       "known_lakehouses": [
# META         {
# META           "id": "5e0b8d8e-4597-41eb-a217-e2d8837fc8c1"
# META         },
# META         {
# META           "id": "c2898d74-eea0-4269-a5ff-c57d004de641"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

# Path to the wind_power table in the Bronze Lakehouse
bronze_table_path = "abfss://WindPowerAnalytics_NtelaAstria@onelake.dfs.fabric.microsoft.com/LH_Wind_Power_Bronze.Lakehouse/Tables/dbo/wind_power"
# Load the wind_power table into a DataFrame
df = spark.read.format("delta").load(bronze_table_path)


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import (
    col, round,
    dayofmonth, month, quarter, year,
    regexp_replace, substring, when
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Clean and enrich data
df_transformed = (
    df
    .withColumn("wind_speed", round(col("wind_speed"), 2))
    .withColumn("energy_produced", round(col("energy_produced"), 2))
    .withColumn("day", dayofmonth(col("date")))
    .withColumn("month", month(col("date")))
    .withColumn("quarter", quarter(col("date")))
    .withColumn("year", year(col("date")))
    .withColumn("time", regexp_replace(col("time"), "-"
    , ":"))
    .withColumn("hour_of_day", substring(col("time"), 1, 2).cast("int"))
    .withColumn("minute_of_hour", substring(col("time"), 4, 2).cast("int"))
    .withColumn("second_of_minute", substring(col("time"), 7,
    2).cast("int"))
    .withColumn(
    "time_period",
    when((col("hour_of_day") >= 5) & (col("hour_of_day") < 12),
    "Morning")
    .when((col("hour_of_day") >= 12) & (col("hour_of_day") < 17),
    "Afternoon")
    .when((col("hour_of_day") >= 17) & (col("hour_of_day") < 21),
    "Evening")
    .otherwise("Night")
)
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Path to the wind_power table in the Silver Lakehouse
silver_table_path = "abfss://WindPowerAnalytics_NtelaAstria@onelake.dfs.fabric.microsoft.com/LH_Wind_Power_Silver.Lakehouse/Tables/dbo/wind_power"
# Save the transformed table to the Silver Lakehouse
df_transformed.write.format("delta").mode("overwrite").save(silver_table_path)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
