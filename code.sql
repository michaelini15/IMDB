SELECT *
FROM IMDB.dbo.IMDB_top_1000

SELECT *
FROM IMDB.dbo.IMDB_top_1000_overview1

SELECT *
	INTO IMDB_overview_combined
FROM
(
	SELECT *
	FROM IMDB.dbo.IMDB_top_1000_overview1
	UNION ALL
	SELECT *
	FROM IMDB.dbo.IMDB_top_1000_overview2
	UNION ALL
	SELECT *
	FROM IMDB.dbo.IMDB_top_1000_overview3
) o

SELECT *
FROM IMDB.dbo.IMDB_overview_combined

SELECT 
	i.Series_Title,
	i.IMDB_Rating,
	o.Overview
FROM IMDB.dbo.IMDB_top_1000 i
INNER JOIN IMDB.dbo.IMDB_overview_combined o
ON i.Poster_Link = o.Poster_Link

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	    PARTITION BY 
            Poster_Link
		ORDER BY
			Series_Title
			) row_num
FROM IMDB.dbo.IMDB_overview_combined
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

SELECT *
FROM IMDB.dbo.IMDB_top_1000
WHERE Series_Title = 'Drishyam'

SELECT 
	Genre_2,
	COUNT(Genre_2) as count
FROM IMDB.dbo.IMDB_top_1000
WHERE Gross is null
GROUP BY Genre_2
ORDER BY count DESC

SELECT 
	Genre_2,
	COUNT(Genre_2) as count
FROM IMDB.dbo.IMDB_top_1000
GROUP BY Genre_2
ORDER BY count DESC

ALTER TABLE IMDB.dbo.IMDB_top_1000
RENAME COLUMN Genre_2 to Prime_Genre
