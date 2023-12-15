   --DATA CLEANING--

--Create a new table combining the three overview tables into one

CREATE TABLE IMDB_overview_combined AS 

SELECT *
FROM IMDB_top_1000_overview1

UNION ALL

SELECT *
FROM IMDB_top_1000_overview2

UNION ALL 

SELECT *
FROM IMDB_top_1000_overview3;

--Rename Genre_2 column to Prime_Genre

ALTER TABLE IMDB_top_1000
RENAME COLUMN Genre_2 to Prime_Genre;

--Create a new column to extract the number portion of the Runtime column

ALTER TABLE IMDB_top_1000
ADD COLUMN Runtime_Num INT64;

--Fill new Runtime_Num column with extracted values

UPDATE IMDB_top_1000
SET Runtime_Num = SUBSTRING(Runtime,1,(CHARINDEX(' ',Runtime,1)-1));

----------------------------------------------------------------------------------------------------------

    --EXPLORATORY DATA ANALYSIS--

--Check for duplicates across serveral factors in both tables (there are none)

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY Poster_Link, Series_Title, Gross ORDER BY IMDB_Rating DESC) row_num
FROM IMDB_top_1000
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY Poster_Link, Series_Title, Overview ORDER BY IMDB_Rating DESC) row_num
FROM IMDB_overview_combined
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

--Check for missing values in key fields (there are 169 missing values, only in Gross)

SELECT  
    COUNT(*) AS Missing_Values
FROM IMDB_top_1000
WHERE Series_Title is null or IMDB_Rating is null or Prime_Genre is null or Gross is null or Runtime_Num is null;

SELECT
    COUNT(*) AS MissingValues
FROM IMDB_overview_combined
WHERE Overview is null;

--Check the distribution of missing values in Gross across the different ratings (there is a clear correlation between the most 
--common ratings and the ratings with the most missing values in Gross, meaning the missing values in Gross are proportionate to 
--rating group size, making it not much of an issue when we compare gross with ratings later on)

SELECT 
	IMDB_Rating as Rating_Groups,
	COUNT(IMDB_Rating) as count
FROM IMDB_top_1000
--WHERE Gross is null
GROUP BY Rating_Groups
ORDER BY Rating_Groups DESC;

--Find out the number of movies per genre

SELECT 
    Prime_Genre,
    COUNT(*) AS Num_Movies
FROM IMDB_top_1000
GROUP BY Prime_Genre
ORDER BY Num_Movies DESC;

--Get an overview of the movies' ratings

SELECT 
    max(IMDB_Rating) AS Max_Rating,
    min(IMDB_Rating) AS Min_Rating,
    avg(IMDB_Rating) AS Avg_Rating
FROM IMDB_top_1000;

----------------------------------------------------------------------------------------------------------

    --DATA ANALYSIS--

--Check if higher rated movies gross more on average

SELECT 
    IMDB_Rating as Rating_Groups,
    avg(Gross) as Avg_Gross
FROM IMDB_top_1000
GROUP BY Rating_Groups
ORDER BY Rating_Groups DESC;

--Check if movies with longer runtimes have higher ratings

SELECT
    CASE
        WHEN Runtime_Num < 90 THEN 'less than hour and a half'
        WHEN Runtime_Num BETWEEN 90 AND 120 THEN 'hour and a half to 2 hours'
        WHEN Runtime_Num BETWEEN 121 AND 150 THEN '2 hours to 2 and a half hours'
        WHEN Runtime_Num BETWEEN 151 AND 180 THEN '2 and a half hours to 3 hours'
        ELSE '3 hours+'
    END AS Runtime_Range,
    avg(IMDB_Rating) AS Avg_Rating
FROM IMDB_top_1000
GROUP BY Runtime_Range
ORDER BY Avg_Rating DESC;

--Check for genres with low ratings

SELECT 
    Prime_Genre,
    avg(IMDB_Rating) AS Avg_Rating
FROM IMDB_top_1000
GROUP BY Prime_Genre
ORDER BY Avg_Rating ASC
LIMIT 10;

--Check if there is a correlation between movie overview length and IMDB rating

SELECT 
    CASE
        WHEN length(b.Overview) < 200 THEN 'Short'
        WHEN length(b.Overview) BETWEEN 200 AND 400 THEN 'Normal'
        ELSE 'Long'
    END AS Overview_Length_Range,
    avg(a.IMDB_Rating) AS Avg_Rating

FROM IMDB_top_1000 a
INNER JOIN IMDB_overview_combined b ON
    a.Poster_Link = b.Poster_Link

GROUP BY Overview_Length_Range
ORDER BY Avg_Rating DESC;

--Check the top rated movie for each genre

SELECT
    Prime_Genre,
    Series_Title,
    IMDB_Rating
FROM 
    (
        SELECT
            Prime_Genre,
            Series_Title,
            IMDB_Rating RANK() OVER(PARTITION BY Prime_Genre ORDER BY IMDB_Rating DESC, No_of_Votes DESC) AS rank
        FROM IMDB_top_1000
    ) AS a
WHERE a.rank = 1;