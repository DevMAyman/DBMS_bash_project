# Database Management System (DBMS) with Bash Script

## Overview
1. This Bash script serves as a Database Management System, providing users with a powerful tool to create, manage, and interact with databases using simple Bash commands.
2. The system organizes data into structured databases, with each directory representing a separate database and individual files within each directory representing tables.

## Getting Started
1. Upon the initial run, the script creates a default 'database' directory to store user databases.
2. A unique fingerprint file is generated in each directory to verify its authenticity as a directory created by the script.

## Special Features
1. **Rollback System:**
   - Maintains a detailed log file for user actions to facilitate data recovery in case of errors or unintended changes.
2. **Sorting data by Primary Key:**
   - Tables within the databases support sorting based on the primary key, enhancing data retrieval efficiency.
2. **Make column allow null and not null:**
   - Tables within the databases support constrian for allowing null and not null.
## Project Main Functions

### 1. Create Database
   - Helps users initiate a new database directory.
   - Enforces rules to ensure the uniqueness of the directory name and its compliance with naming conventions.
   - Validates that the directory name does not start with a number or a special character.

### 2. List Databases
   - Lists all existing database directories, aiding users in keeping track of their databases.

### 3. Delete Database
   - Allows users to delete a specific database directory if it exists.
   - Displays a confirmation prompt to prevent accidental deletions.

### 4. Connect to Database
   - Establishes a connection to a specified database, enabling users to execute database-related operations.

   #### 4.1 Create Table
      - Guides users through the table creation process, ensuring a unique table name.
      - Prompts users to specify the number of columns, designate a primary key column, and define column data types.
      - Generates a file with the table name containing the column structure and a metadata file capturing additional details.

   #### 4.2 List Tables
      - Presents a list of all tables within the connected database for easy reference.

   #### 4.3 Drop Table
      - Allows users to remove a specific table from the database.
      - Requests user confirmation to prevent accidental deletions.

   #### 4.4 Insert into Table
      - Facilitates the insertion of new records into a specified table.
      - Enforces data validation, including checks for data types, nullability, and unique primary keys.

   #### 4.5 Update Table
      - Enables users to update column values within a table.
      - Provides options for specifying a WHERE condition for targeted updates.

   #### 4.6 Select from Table
      - Allows users to retrieve specific columns from a table.
      - Supports optional WHERE conditions for customized data retrieval.

   #### 4.7 Delete from Table
      - Enables users to delete specific rows from a table.
      - Offers the option to include a WHERE condition for precise deletions.

   #### 4.8 Add Column to Table
      - Lets users add a new column to an existing table.
      - Verifies the non-existence of the column name before adding it to the table.

   #### 4.9 Delete Column from Table
      - Permits users to remove a column from a table if it exists.
      - Updates both the table file and the metadata file accordingly.
