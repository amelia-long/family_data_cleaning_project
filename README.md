# family_data_cleaning_project
## MySQL data cleaning project

## Problems to solve

The data to be cleaned comes from a csv file downloaded from MyHeritage containing my family tree details.

<img width="800" alt="Data screenshot" src="https://github.com/amelia-long/family_data_cleaning_project/assets/158860669/783b5bb7-4aa1-4428-b2e6-e1e50fff5047">

As this sample of the data shows, there are a number of problems:
- the first and last names are stored as a single string, which makes sorting by last name impossible
- birth and death dates are stored as strings and do not have a consistent format
- there are blank values

## Process

1. Create database
2. Import the csv file
3. Insert data into a staging table
4. Find and delete duplicates
5. Standardize the data
6. Create a stored function to extract birth and death years from the VARCHAR `birth_date` and `death_date` columns
7. Deal with blank values
8. Remove redundant data
9. Remove redundant columns
10. Create a new table to receive the clean data
11. Insert cleaned data
    - Extract last name from name string
    - Extract first name from name string
    - Extract birth and death years from birth_date and death_date string
12. Remove redundant id column.
