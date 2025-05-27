# 🚀 AWS Data Simulation Pipeline via Terraform

## 📖 Project Description
This is a fully automated data simulation pipeline on AWS. It generates synthetic machine-telemetry records every minute, stores them as time-partitioned CSV files in an S3 bucket, catalogs them in AWS Glue, and makes them immediately queryable via Amazon Athena. This setup is ideal for testing analytics, dashboards, or machine-learning workflows without needing real device data.

---

## 🛠️ Role of Terraform
Terraform is used as the Infrastructure-as-Code (IaC) engine to provision and manage all AWS resources in a modular, repeatable, and version-controlled manner. Specifically, Terraform:
1. **Creates and configures** an encrypted, versioned S3 bucket for storing CSV files.
2. **Defines** an IAM role and policy that grants a Lambda function permission to write logs and read/write S3.
3. **Deploys** the Python-based Lambda function and wires up a CloudWatch EventBridge rule to trigger it every minute.
4. **Creates** an AWS Glue Data Catalog database and an external table pointing at the S3 prefix.
5. **Outputs** resource identifiers for easy reference and integration with downstream tooling.

By encapsulating each component in self-contained modules (S3, IAM, Lambda, Glue), the infrastructure is organized, reusable, and easy to maintain.

---

## 🐍 Role of the Lambda Function
The single Python Lambda function (`stream_simulator.py`) simulates and writes machine telemetry data:
1. **Generates** 50 data points per invocation that include a timestamp, temperature, pressure, vibration, RPM, and status (`OK`/`WARN`/`ERROR`).
2. **Writes** each batch as a uniquely named CSV (based on UTC timestamp) into the `machine_data/` folder in S3.
3. **(Legacy append mode)** attempts to fetch and append to an existing CSV if one exists—though in the modular design you may choose time-partitioned files only.

This approach ensures each run produces a discrete file, avoids contention on a single object, and keeps the data organized by time for efficient querying in Athena.

---

## 🎯 Use Case
- **Prototyping analytics**: Quickly stand up a synthetic data source for dashboards (QuickSight, Grafana) or ad-hoc Athena queries.  
- **Machine-learning testing**: Validate preprocessing pipelines or model training on simulated “sensor” streams without needing hardware.  
- **Dev/Test environments**: Populate QA environments with realistic load and schema for performance tuning.

---

## 🏃 How to Run

1. **Clone the repository**  
   ```bash
   git clone https://github.com/ZeeshanM96/AWSDataStreamingWithTerraform.git
   cd AWSDataStreamingWithTerraform
    ```
2. **Package your Lambda function**
   ```bash
   cd lambda/
   zip ../lambda_package.zip stream_simulator.py
   cd ..
   ```

3. **Initialize and apply Terraform**
   ```bash
   cd terraform/
   terraform init
   terraform apply
   ```
4. **Wait for the Lambda to trigger (1 minute interval)**

5. **Query the data using Athena**
   ```sql
   SELECT * FROM machine_data LIMIT 10;
   ```

   ---
   

## 🧹 Cleanup
1. To tear down all infrastructure:

```bash
terraform destroy
```
Make sure the S3 bucket is empty:
```bash
aws s3 rm s3://<your-bucket-name> --recursive
```

  ---
   
## 📄 License
This project is licensed under the MIT License.

   ---
   
## 👨‍💻 Author
Zeeshan
🔗 GitHub Profile


   ---
   
## ✅ TODO
- [ ] Add Glue Crawler for dynamic schema detection
- [ ] Integrate with Amazon QuickSight for dashboards
- [ ] Add GitHub Actions for Terraform CI/CD pipeline
- [ ] Export custom metrics to Amazon CloudWatch for visualization
