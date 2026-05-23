# Data Exploration and Cleaning Using Pandas

A structured Python assignment focused on data engineering fundamentals—specifically the Extraction, Transformation, and Loading (ETL) phases—using the Pandas library inside a Jupyter Notebook environment.

## Objective
To master fundamental Python data analysis operations by exploring a raw e-commerce catalog dataset, identifying and resolving structural/data integrity anomalies, executing row and column manipulations, and exporting a structurally sound dataset.

---

## Assignment Workflow Steps

### 1. Data Ingestion (Extraction)
* **Operation:** Loaded the raw `Combined_dataset.csv` into a structured Pandas DataFrame.
* **Significance:** Established a connection between external flat files and Python's computational environment to begin programmatic analysis.

### 2. Data Exploration & Profiling
* Inspecting structural parameters using built-in metadata attributes and methods:
  * `df.head()` / `df.tail()` – Investigating the baseline layout of records.
  * `df.shape` – Querying the exact dimensional matrix (Rows × Columns).
  * `df.columns` – Listing the feature labels present in the schema.
  * `df.dtypes` – Auditing data types across numeric and categorical categories.

### 3. Data Integrity & Missing Value Imputation
* **Identification:** Leveraged `isnull().sum()` to pinpoint columns containing gaps in data (such as the `discount` field).
* **Resolution:** Implemented an organized system utilizing `.dropna()` and `.fillna()` to clean unrecoverable null entries and standardize missing records, ensuring no downstream mathematical scripts fail.

### 4. Row Filtering & Column Slicing
* Executed conditional Boolean masking to slice data dynamically based on criteria like `df['rating'] > 4.0`.
* Grouped and paired relational conditions utilizing bitwise operators (`&`, `|`) to parse down the 24 columns into meaningful sub-selections.

### 6. Feature Engineering (Derived Columns)
* **Operation:** Generated a new calculated vector column called `total_amount`.
* **Methodology:** Rather than introducing arbitrary dummy variables into a pure product catalog dataset, the script multiplies the verified numerical column `initial_price` by a set unit transaction scale factor (`quantity = 100`). This demonstrates advanced column-level arithmetic manipulations while preserving data authenticity.

### 7. Storage & Export (Loading)
* **Operation:** Written the final cleaned, unique, and modified DataFrame out to a clean CSV format via `df.to_csv('cleaned_dataset.csv', index=False)`.
* **Significance:** Created a lightweight, reliable, high-integrity target dataset ready for production machine learning models or SQL relational loading.

---

## Technologies Used
* **Language:** Python 3
* **Libraries:** Pandas, NumPy
* **Environment:** VS Code Jupyter Notebooks (`.ipynb`)
* **Version Control:** Git & GitHub

---

## Project Structure
```text
├── Datasets/
│   ├── Combined_dataset.csv     # Original Raw Dataset (Kaggle Source)
│   └── cleaned_dataset.csv      # Output Dataset (Processed & Refactored)
├── assignment1.ipynb            # Core Jupyter Notebook featuring all steps
└── README.md                    # Project Documentation & Summary
