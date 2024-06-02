# family_data_cleaning_project
<H2>MySQL data cleaning project</H2>
<H3>Problems to solve</H3>
-- first and last names in single string 
<br>-- birth/death dates as string which can't be converted to date format
<H3>Process</H3>
1. Create database
<BR>2. Import csv file (downloaded from MyHeritage)
<BR>3. Insert data into staging table
<BR>4. Find and delete duplicates
<BR>5. Standardize data
<BR>6. Create stored function (year_extractor) to extract birth and death years from VARCHAR birth_date and death_date cols
<BR>7. Deal with null and blank values
<BR>8. Remove redundant cols and rows
<BR>9. Create new table to receive cleaned data
<BR>10. Insert cleaned data
<BR>  -- Extract lastname from name string
<BR>  -- Extract firstname from name string
<BR>  -- Extract birth and death years from birth_date and death_date string as integers using stored function (year_extractor)
<BR>11. Remove redundant id column
