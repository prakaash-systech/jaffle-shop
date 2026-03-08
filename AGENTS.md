## Instructions for Cortex Code
- Always read this file before performing any DBT-related task.
- When asked to check or validate naming conventions, compare files against 
  the standards defined in this document — do not infer conventions from 
  existing files.
# DBT Project Naming Conventions & Folder Structure

> This document defines the standard naming conventions, folder structure, materialization defaults, and testing requirements for DBT development. Use this as context when generating DBT models with Snowflake Cortex Code.

---

## Project Folder Structure Overview

```
project/
├── models/
│   ├── sources/
│   │   └── <schema_name>/            # e.g. PUBLISH, RAW — confirm with user
│   │       └── src__<schema_name>__<table_name>.yml
│   ├── staging/
│   │   └── <schema_name>/
│   │       ├── stg__<schema_name>__<table_name>.sql
│   │       └── definitions/
│   │           └── stg__<schema_name>__<table_name>.yml
│   ├── intermediate/
│   │   └── <pipeline_folder>/
│   │       ├── int__<table_name>.sql
│   │       └── definitions/
│   │           └── int__<table_name>.yml
│   ├── marts/
│   │   └── <pipeline_folder>/
│   │       ├── fct__<table_name>.sql
│   │       ├── dim__<table_name>.sql
│   │       └── definitions/
│   │           ├── fct__<table_name>.yml
│   │           └── dim__<table_name>.yml
│   └── publish/
│       └── <user_defined_folder>/
│           ├── <user_defined_name>.sql
│           └── definitions/
│               └── <user_defined_name>.yml
├── macros/
│   └── mc__<macro_name>.sql
├── seeds/
│   └── sd__<table_name>.csv
└── snapshots/
    └── snp__<table_name>.yml
```

---

## Layer-by-Layer Conventions

### 1. Sources

- **Location:** `models/sources/<schema_name>/`
- **Subfolders:** Named after the schema being consumed (e.g. `PUBLISH`, `RAW`, `LANDING`).
- **Schema rule:** Default subfolder name is the schema name. If the user does not specify the schema or subfolder name, **always confirm** before creating files.
- **One file per table** — each source table has its own individual YML file.
- **Naming convention:** `src__<folder_name>__<table_name>.yml`

**Example:**
```
models/sources/PUBLISH/src__PUBLISH__customer.yml
models/sources/RAW/src__RAW__raw_orders.yml
```

---

### 2. Staging

- **Location:** `models/staging/<schema_name>/`
- **Subfolders:** Follow the same schema-based pattern as the source YML subfolders.
- **SQL model naming:** `stg__<folder_name>__<table_name>.sql`
- **YML definition naming:** `stg__<folder_name>__<table_name>.yml`
- **YML location:** Stored inside a `definitions/` subfolder within the staging subfolder.
- **Materialization:** `view`
- **Testing:** At least one `unique` and one `not_null` test must be defined per model.

**Example:**
```
models/staging/PUBLISH/stg__PUBLISH__customer.sql
models/staging/PUBLISH/definitions/stg__PUBLISH__customer.yml
```

---

### 3. Intermediate

- **Location:** `models/intermediate/<pipeline_folder>/`
- **Subfolders:** Named after the pipeline of the target table.
- **SQL model naming:** `int__<table_name>.sql`
- **YML definition naming:** `int__<table_name>.yml`
- **YML location:** Stored inside a `definitions/` subfolder within the pipeline subfolder.
- **Materialization:** `table`
- **⚠️ Cortex Instruction:** If the user does not specify the pipeline folder location, **always ask** before creating any files.

**Example:**
```
models/intermediate/customer_pipeline/int__customer_enriched.sql
models/intermediate/customer_pipeline/definitions/int__customer_enriched.yml
```

---

### 4. Marts

- **Location:** `models/marts/<pipeline_folder>/`
- **Subfolders:** Named after the pipeline of the target table.
- **SQL model naming:**
  - Fact tables: `fct__<table_name>.sql`
  - Dimension tables: `dim__<table_name>.sql`
- **YML definition naming:** `fct__<table_name>.yml` / `dim__<table_name>.yml`
- **YML location:** Stored inside a `definitions/` subfolder within the pipeline subfolder.
- **Materialization:** `incremental`
- **Testing:** At least one `unique` and one `not_null` test must be defined per model.
- **⚠️ Cortex Instruction:** If the user does not specify the pipeline folder location, **always ask** before creating any files.

**Example:**
```
models/marts/customer_pipeline/fct__customer_orders.sql
models/marts/customer_pipeline/dim__customer.sql
models/marts/customer_pipeline/definitions/fct__customer_orders.yml
models/marts/customer_pipeline/definitions/dim__customer.yml
```

---

### 5. Publish

- **Location:** `models/publish/<user_defined_folder>/`
- **Subfolders:** Defined by the user.
- **SQL model naming:** Defined by the user.
- **YML definition naming:** Same name as the SQL model, with `.yml` extension.
- **YML location:** Stored inside a `definitions/` subfolder within the user-defined subfolder.
- **Materialization:** `view`
- **⚠️ Cortex Instruction:** Always ask the user for the folder name and model name before creating any files in this layer.

**Example:**
```
models/publish/reporting/monthly_sales.sql
models/publish/reporting/definitions/monthly_sales.yml
```

---

### 6. Seeds

- **Location:** `seeds/`
- **Naming convention:** `sd__<table_name>.csv`

**Example:**
```
seeds/sd__country_codes.csv
seeds/sd__product_categories.csv
```

---

### 7. Snapshots

- **Location:** `snapshots/`
- **Naming convention:** `snp__<table_name>.yml`

**Example:**
```
snapshots/snp__customer.yml
snapshots/snp__product.yml
```

---

### 8. Macros

- **Location:** `macros/`
- **Naming convention:** `mc__<macro_name>.sql`
- **⚠️ Cortex Instruction:** The macro name is always provided by the user. Always ask if not specified.

**Example:**
```
macros/mc__generate_schema_name.sql
macros/mc__cents_to_dollars.sql
```

---

## Materialization Summary

| Layer        | Materialization |
|--------------|-----------------|
| Staging      | `view`          |
| Intermediate | `table`         |
| Marts        | `incremental`   |
| Publish      | `view`          |

---

## Testing Requirements

| Layer        | Required Tests            |
|--------------|---------------------------|
| Staging      | `unique`, `not_null` (at least one of each) |
| Marts        | `unique`, `not_null` (at least one of each) |
| Intermediate | No mandatory tests        |
| Publish      | No mandatory tests        |

---

## Cortex Code Behaviour Rules

1. **Always follow the naming conventions** defined in this document when generating any DBT file.
2. **Ask before creating** — for `intermediate`, `marts`, and `publish` layers, if the user has not specified a subfolder/pipeline folder, always ask for it before generating files.
3. **One file per table** — never combine multiple source tables into a single YML file in the sources layer.
4. **YML definitions in `definitions/` subfolder** — this is a universal rule: whenever a SQL model exists, its corresponding YML definition must be placed in a `definitions/` subfolder relative to the SQL file. This applies to staging, intermediate, marts, and publish layers.
5. **Apply tests automatically** — when generating staging or marts models, always include at least `unique` and `not_null` tests in the accompanying YML definition file.
6. **Respect schema rules for sources** — subfolder name should match the schema name. If the user does not specify the schema or subfolder name, always confirm before creating files.
7. **Do not rename or alias columns** — do not rename or alias any column names in staging models unless the user explicitly asks for it.
8. **Macros naming** — all macros must follow the `mc__<macro_name>.sql` convention. The macro name is always provided by the user.
