SELECT *
FROM observations;

SELECT *
FROM locations;

SELECT *
FROM name_classifications;

SELECT*
FROM fix_states;

--filter date range & kingdom type
SELECT *
FROM observations AS o
INNER JOIN name_classifications AS nc ON o.name_id = nc.name_id
WHERE date >= '1990-01-01' AND kingdom = 'Fungi'
ORDER BY date ASC;

--identify states in locations table - I SPENT SO MUCH FCKING TIME HERE OMG -- kept getting over 100 records
SELECT DISTINCT TRIM(REVERSE(SPLIT_PART(REVERSE(name),',',2))) AS state
FROM locations
WHERE name LIKE '%Usa'
ORDER BY STATE DESC;

--ALL THE DATA IN THIS QUERY--
--join locations to first query that joined observations and name_class, keep the state column. Used INNER join becuase there are some location_id in observation table that were not found in location table (using Left doubled the records but created NULLs in state column)

SELECT subquery.*,
TRIM(REVERSE(SPLIT_PART(REVERSE(l.name),',',2))) AS state
FROM (
	SELECT *
	FROM observations AS o
	INNER JOIN name_classifications AS nc 
	ON o.name_id = nc.name_id
	WHERE date >= '1990-01-01' AND kingdom = 'Fungi'
) AS subquery
INNER JOIN locations as l ON subquery.location_id = l.id
WHERE name LIKE '%Usa'
ORDER BY subquery.date ASC;


--All three tables still joined, get a count of mushroom_observations by state to see where they are most abundant to know where to pull weather data from

SELECT 
DISTINCT TRIM(REVERSE(SPLIT_PART(REVERSE(l.name),',',2))) AS state,
COUNT(*) AS observation_count
FROM observations AS o
	INNER JOIN name_classifications AS nc ON o.name_id = nc.name_id
	INNER JOIN locations AS l ON o.location_id = l.id
	WHERE 
	date >= '1990-01-01' 
	AND kingdom = 'Fungi'
	AND l.name LIKE '%Usa'
	GROUP BY state
	ORDER BY observation_count DESC;

--FINALLY got 56 records 

--Add Regions
--created table for regions, used innerjoin to link it with query that retrieves and counts the states


SELECT state, region, COUNT(*) AS observation_count
FROM (
	SELECT TRIM(REVERSE(SPLIT_PART(REVERSE(l.name),',',2))) AS state, r.region AS region
	FROM observations AS o
	INNER JOIN name_classifications AS nc ON o.name_id = nc.name_id
	INNER JOIN locations AS l ON o.location_id = l.id
	INNER JOIN regions AS r ON TRIM(REVERSE(SPLIT_PART(REVERSE(l.name), ',', 2))) = r.state
	WHERE 
	date >= '1990-01-01' 
	AND kingdom = 'Fungi'
	AND l.name LIKE '%Usa'
) as subquery
GROUP BY state, region
ORDER BY observation_count DESC;