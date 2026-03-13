[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "wind_power_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "production_id", DestinationColumnName = "production_id"], [SourceColumnName = "date", DestinationColumnName = "date"], [SourceColumnName = "turbine_name", DestinationColumnName = "turbine_name"], [SourceColumnName = "capacity", DestinationColumnName = "capacity"], [SourceColumnName = "location_name", DestinationColumnName = "location_name"], [SourceColumnName = "latitude", DestinationColumnName = "latitude"], [SourceColumnName = "longitude", DestinationColumnName = "longitude"], [SourceColumnName = "region", DestinationColumnName = "region"], [SourceColumnName = "status", DestinationColumnName = "status"], [SourceColumnName = "responsible_department", DestinationColumnName = "responsible_department"], [SourceColumnName = "wind_direction", DestinationColumnName = "wind_direction"], [SourceColumnName = "wind_speed", DestinationColumnName = "wind_speed"], [SourceColumnName = "energy_produced", DestinationColumnName = "energy_produced"], [SourceColumnName = "day", DestinationColumnName = "day"], [SourceColumnName = "month", DestinationColumnName = "month"], [SourceColumnName = "year", DestinationColumnName = "year"], [SourceColumnName = "time", DestinationColumnName = "time"], [SourceColumnName = "hour_of_day", DestinationColumnName = "hour_of_day"], [SourceColumnName = "minute_of_hour", DestinationColumnName = "minute_of_hour"], [SourceColumnName = "second_of_minute", DestinationColumnName = "second_of_minute"], [SourceColumnName = "time_period", DestinationColumnName = "time_period"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared wind_power = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "eb35f304-a7dc-442a-982c-985acdd268c5"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "5e0b8d8e-4597-41eb-a217-e2d8837fc8c1"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "wind_power", ItemKind = "Table"]}[Data],
  #"Rounded off" = Table.TransformColumns(#"Navigation 2", {{"wind_speed", each Number.Round(_, 2), type number}, {"energy_produced", each Number.Round(_, 2), type number}}),
  #"Inserted day" = Table.AddColumn(#"Rounded off", "Day", each Date.Day([date]), type nullable number),
  #"Inserted month" = Table.AddColumn(#"Inserted day", "Month", each Date.Month([date]), type nullable number),
  #"Inserted month 1" = Table.AddColumn(#"Inserted month", "Month (2)", each Date.Month([date]), type nullable number),
  #"Inserted year" = Table.AddColumn(#"Inserted month 1", "Year", each Date.Year([date]), type nullable number),
  #"Changed column type" = Table.TransformColumnTypes(#"Inserted year", {{"Day", Int64.Type}, {"Month", Int64.Type}, {"Month (2)", Int64.Type}, {"Year", Int64.Type}}),
  #"Renamed columns" = Table.RenameColumns(#"Changed column type", {{"Day", "day"}, {"Month", "month"}}),
  #"Removed columns" = Table.RemoveColumns(#"Renamed columns", {"Month (2)"}),
  #"Renamed columns 1" = Table.RenameColumns(#"Removed columns", {{"Year", "year"}}),
  #"Replaced value" = Table.ReplaceValue(#"Renamed columns 1", "-", ":", Replacer.ReplaceText, {"time"}),
  #"Duplicated column" = Table.DuplicateColumn(#"Replaced value", "time", "time - Copy"),
  #"Split column by delimiter" = Table.SplitColumn(#"Duplicated column", "time - Copy", Splitter.SplitTextByDelimiter(":"), {"time - Copy.1", "time - Copy.2", "time - Copy.3"}),
  #"Renamed columns 2" = Table.RenameColumns(#"Split column by delimiter", {{"time - Copy.1", "hour_of_day"}, {"time - Copy.2", "minute_of_hour"}, {"time - Copy.3", "second_of_minute"}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Renamed columns 2", {{"hour_of_day", Int64.Type}, {"minute_of_hour", Int64.Type}, {"second_of_minute", Int64.Type}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type 1", "time_period", each if [hour_of_day] >= 5 and [hour_of_day] < 12 then "Morning"
else if [hour_of_day] >= 12 and [hour_of_day] < 17 then "Afternoon"
else if [hour_of_day] >= 17 and [hour_of_day] < 21 then "Evening"
else "Night"), {{"time_period", type text}})
in
  #"Added custom";
shared wind_power_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "eb35f304-a7dc-442a-982c-985acdd268c5"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "c2898d74-eea0-4269-a5ff-c57d004de641"]}[Data],
  TableNavigation = Navigation_2{[Id = "wind_power", ItemKind = "Table"]}[Data]
in
  TableNavigation;
