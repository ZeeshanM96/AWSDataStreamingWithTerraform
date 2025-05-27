variable "bucket_name" {}

resource "aws_glue_catalog_database" "machine_db" {
  name = "machine_data_db"
}

resource "aws_glue_catalog_table" "machine_data_table" {
  name          = "machine_data"
  database_name = aws_glue_catalog_database.machine_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${var.bucket_name}/machine_data/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "machine_csv_serde"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

      parameters = {
        "separatorChar" = ","
        "quoteChar"     = "\""
      }
    }

    columns {
    name = "timestamp"
    type = "string"
  }
  columns {
    name = "temperature"
    type = "double"
  }
  columns {
    name = "pressure"
    type = "double"
  }
  columns {
    name = "vibration"
    type = "double"
  }
  columns {
    name = "rpm"
    type = "int"
  }
  columns {
    name = "status"
    type = "string"
  }
  }

  parameters = {
    "skip.header.line.count" = "0"
    "EXTERNAL"               = "TRUE"
    "has_encrypted_data"     = "false"
  }
}
