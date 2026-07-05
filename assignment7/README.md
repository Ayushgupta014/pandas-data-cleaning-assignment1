# Superstore Data Cleaning and Delta Lake MERGE Implementation

A two-part data engineering assignment using the Superstore Sales dataset.

- **Part 1** — Data exploration and cleaning with Pandas
- **Part 2** — Delta Lake MERGE (upsert) implementation using PySpark on Databricks

---

## Repository Structure

```
├── superstore_pandas_delta_merge.ipynb   # Main Jupyter notebook (both parts)
├── superstore_raw.csv                    # Raw dataset with missing values and duplicates
├── superstore_cleaned.csv                # Cleaned output dataset
└── README.md
```

---

## Part 1 — Pandas Data Exploration and Cleaning

### Objective

Load the Superstore Sales dataset, explore its structure, handle data quality issues, perform basic operations, and save a cleaned version.

### Dataset

- **Source:** [Superstore Dataset — Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)
- **Raw file:** `superstore_raw.csv` — 205 rows, 17 columns (includes injected nulls and duplicates)
- **Cleaned file:** `superstore_cleaned.csv` — 200 rows, 18 columns

### Steps Covered

| Step | Task | Details |
|------|------|---------|
| 1 | Load CSV | `pd.read_csv()` loads 205 rows x 17 columns |
| 2 | Explore data | `head()`, `tail()`, `shape`, `columns`, `dtypes`, `describe()`, `info()` |
| 3 | Handle missing values | 32 nulls identified and filled using median / mode / placeholder |
| 4 | Filter and select | Filter by Sales, Category, Region; select specific columns |
| 5 | Remove duplicates | 5 duplicate rows detected and dropped |
| 6 | Derived column | `total_amount = Sales x Quantity` created |
| 7 | Save cleaned CSV | `superstore_cleaned.csv` saved and verified |

### Missing Value Strategy

| Column | Strategy | Reason |
|--------|----------|--------|
| `Sales` | Fill with median | Numeric — median is outlier-robust |
| `Profit` | Fill with median | Numeric — median is outlier-robust |
| `Ship Mode` | Fill with `Standard Class` | Most common value |
| `Region` | Fill with `Unknown` | Categorical placeholder |

### Data Cleaning Summary

```
Raw dataset  : 205 rows, 17 columns
Missing cells: 32 (across Sales, Profit, Ship Mode, Region)
Duplicates   : 5 rows
Derived col  : total_amount = Sales x Quantity

Cleaned dataset: 200 rows, 18 columns
Missing cells  : 0
Duplicates     : 0
```

---

## Part 2 — Delta Lake MERGE Implementation

### Objective

Implement a Delta Lake upsert pipeline using PySpark on Azure Databricks, simulating a real-world Change Data Capture (CDC) workflow.

**Reference:** [Upsert into Delta Lake using merge — Microsoft Learn](https://learn.microsoft.com/en-us/azure/databricks/delta/merge)

### What is MERGE?

Delta Lake MERGE (also called upsert) atomically combines updates and inserts into a target Delta table:

- `WHEN MATCHED` — update the existing row when a key match is found
- `WHEN NOT MATCHED` — insert a new row when no match exists in the target
- `WHEN NOT MATCHED BY SOURCE` — delete or update rows in the target that have no match in the source (Databricks Runtime 12.2+)

### SQL Syntax

```sql
MERGE INTO target_table AS target
USING source_table AS source
ON target.key_column = source.key_column

WHEN MATCHED THEN
    UPDATE SET
        target.col1 = source.col1,
        target.col2 = source.col2

WHEN NOT MATCHED THEN
    INSERT (col1, col2, ...)
    VALUES (source.col1, source.col2, ...)

WHEN NOT MATCHED BY SOURCE THEN
    DELETE
```

### PySpark Syntax

```python
from delta.tables import DeltaTable

deltaTable = DeltaTable.forPath(spark, "/path/to/delta/table")

(deltaTable.alias("target")
 .merge(
     source_df.alias("source"),
     "target.key = source.key"
 )
 .whenMatchedUpdate(set={
     "col1": "source.col1",
     "col2": "source.col2",
 })
 .whenNotMatchedInsertAll()
 .execute()
)
```

### Pipeline Steps in the Notebook

| Step | Description |
|------|-------------|
| 1 | Create Delta target table from `superstore_cleaned.csv` |
| 2 | Simulate CDC source: 10 updated orders + 5 new orders |
| 3 | Execute `DeltaTable.merge()` — update matched, insert unmatched |
| 4 | Verify results — inspect inserted and updated rows |
| 5 | View Delta transaction history log |
| 6 | Demonstrate Time Travel using `versionAsOf` |
| 7 | Execute equivalent SQL MERGE via `spark.sql()` |

### MERGE Result

```
Rows before MERGE  : 200
New rows inserted  : 5
Rows updated       : 10
Rows after MERGE   : 205
```

### Time Travel

```python
# Read the table before MERGE (version 0)
df_v0 = spark.read.format("delta").option("versionAsOf", 0).load(path)

# Read the table after MERGE (version 1)
df_v1 = spark.read.format("delta").option("versionAsOf", 1).load(path)
```

### Common MERGE Use Cases

| Use Case | Pattern |
|----------|---------|
| SCD Type 1 (overwrite history) | MATCHED → UPDATE, NOT MATCHED → INSERT |
| SCD Type 2 (preserve history) | MATCHED → INSERT new row + close old row |
| Change Data Capture (CDC) | MATCHED → UPDATE or DELETE, NOT MATCHED → INSERT |
| Deduplication | NOT MATCHED → INSERT only |
| Incremental sync | MATCHED BY SOURCE → DELETE, others normal |

### Key Benefits of Delta Lake

- **ACID transactions** — all-or-nothing writes, no partial failures
- **Optimistic concurrency** — concurrent reads are never blocked
- **Time travel** — query any prior version of the table
- **Schema evolution** — auto-merge schema changes via `spark.databricks.delta.schema.autoMerge.enabled = true`
- **Audit log** — full transaction history via `deltaTable.history()`

---

## Requirements

### Part 1 (Pandas)

```
python >= 3.8
pandas
numpy
```

Install:

```bash
pip install pandas numpy
```

### Part 2 (Delta Lake MERGE)

Runs on **Azure Databricks** (recommended) or local PySpark with delta-spark.

For local setup:

```bash
pip install pyspark delta-spark
```

For Databricks: upload the `.ipynb` file directly — `spark` and `delta` are pre-configured.

---

## How to Run

### On Databricks (recommended)

1. Upload `superstore_pandas_delta_merge.ipynb` to your Databricks workspace
2. Upload `superstore_raw.csv` to DBFS or a Databricks Volume
3. Attach a cluster (Databricks Runtime 12.2+ for full MERGE support)
4. Run all cells

### Locally (Pandas part only)

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
pip install pandas numpy
jupyter notebook superstore_pandas_delta_merge.ipynb
```

---

## Output Files

| File | Description |
|------|-------------|
| `superstore_pandas_delta_merge.ipynb` | Complete notebook with all steps |
| `superstore_raw.csv` | Original dataset (205 rows, 17 cols) |
| `superstore_cleaned.csv` | Cleaned dataset (200 rows, 18 cols, includes `total_amount`) |

---

## References

- [Superstore Dataset — Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)
- [Upsert into Delta Lake using merge — Microsoft Learn](https://learn.microsoft.com/en-us/azure/databricks/delta/merge)
- [Delta Lake OSS Documentation](https://docs.delta.io/delta-update/)
- [Pandas Documentation](https://pandas.pydata.org/docs/)
