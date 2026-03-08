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
│   │   └── <source_system>/          # e.g. RIDE, MDM, CAP, LID
│   │       └── src__<source_system>__<table_name>.yml
│   ├── staging/
│   │   └── <source_system>/
│   │       ├── stg__<source_system>__<table_name>.sql
│   │       └── definitions/
│   │           └── stg__<source_system>__<table_name>.yml
│   ├── intermediate/
│   │   └── <pipeline_folder>/
│   │       └── int__<table_name>.sql
│   ├── marts/
│   │   └── <pipeline_folder>/
│   │       ├── fct__<table_name>.sql
│   │       └── dim__<table_name>.sql
│   └── publish/
│       └── <user_defined_folder>/
│           └── <user_defined_name>.sql
├── seeds/
│   └── sd__<table_name>.csv
└── snapshots/
    └── snp__<table_name>.yml
```

---

## Layer-by-Layer Conventions

### 1. Sources

- **Location:** `models/sources/<source_system>/`
- **Subfolders:** Named after the source system (e.g. `RIDE`, `MDM`, `CAP`, `LID`)
- **Schema rule:** Typically consume only from the `PUBLISH` schema of the source system. If reading from multiple schemas, create subfolders per schema name instead of per source system.
- **One file per table** — each source table has its own individual YML file.
- **Naming convention:** `src__<folder_name>__<table_name>.yml`

**Example:**
```
models/sources/RIDE/src__RIDE__customer.yml
models/sources/MDM/src__MDM__product.yml
```

---

### 2. Staging

- **Location:** `models/staging/<source_system>/`
- **Subfolders:** Follow the same pattern as the source YML subfolders.
- **SQL model naming:** `stg__<folder_name>__<table_name>.sql`
- **YML definition naming:** `stg__<folder_name>__<table_name>.yml`
- **YML location:** Stored inside a `definitions/` subfolder within the staging subfolder.
- **Materialization:** `view`
- **Testing:** At least one `unique` and one `not_null` test must be defined per model.

**Example:**
```
models/staging/RIDE/stg__RIDE__customer.sql
models/staging/RIDE/definitions/stg__RIDE__customer.yml
```

---

### 3. Intermediate

- **Location:** `models/intermediate/<pipeline_folder>/`
- **Subfolders:** Named after the pipeline of the target table.
- **SQL model naming:** `int__<table_name>.sql`
- **Materialization:** `table`
- **⚠️ Cortex Instruction:** If the user does not specify the pipeline folder location, **always ask** before creating any files.

**Example:**
```
models/intermediate/customer_pipeline/int__customer_enriched.sql
```

---

### 4. Marts

- **Location:** `models/marts/<pipeline_folder>/`
- **Subfolders:** Named after the pipeline of the target table.
- **SQL model naming:**
  - Fact tables: `fct__<table_name>.sql`
  - Dimension tables: `dim__<table_name>.sql`
- **Materialization:** `incremental`
- **Testing:** At least one `unique` and one `not_null` test must be defined per model.
- **⚠️ Cortex Instruction:** If the user does not specify the pipeline folder location, **always ask** before creating any files.

**Example:**
```
models/marts/customer_pipeline/fct__customer_orders.sql
models/marts/customer_pipeline/dim__customer.sql
```

---

### 5. Publish

- **Location:** `models/publish/<user_defined_folder>/`
- **Subfolders:** Defined by the user.
- **SQL model naming:** Defined by the user.
- **Materialization:** `view`
- **⚠️ Cortex Instruction:** Always ask the user for the folder name and model name before creating any files in this layer.

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
4. **YML definitions in `definitions/` subfolder** — staging YML files must always be placed inside the `definitions/` subfolder, not at the root of the staging subfolder.
5. **Apply tests automatically** — when generating staging or marts models, always include at least `unique` and `not_null` tests in the accompanying YML definition file.
6. **Respect schema rules for sources** — default to `PUBLISH` schema; use schema-based subfolders only when consuming from multiple schemas.
7. **Do not rename or alias columns** — do not rename or alias any column names in staging models unless the user explicitly asks for it.
