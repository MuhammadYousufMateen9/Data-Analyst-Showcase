CREATE DATABASE projects;

USE projects;

SELECT * 
FROM hr;

DESCRIBE hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

SELECT birthdate FROM hr;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d') 
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d') 
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

SELECT hire_date FROM hr;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d') 
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d') 
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

SELECT termdate FROM hr;

SELECT CASE 
	WHEN termdate IS NOT NULL AND termdate != '' THEN date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
	ELSE '0000-00-00' 
END 
FROM hr;

UPDATE hr
SET termdate = CASE 
	WHEN termdate IS NOT NULL AND termdate != '' THEN date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
	ELSE '0000-00-00' 
END;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

SELECT * FROM hr;

ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT birthdate, age, CURDATE() FROM hr;

SELECT MIN(age) AS youngest, MAX(age) AS oldest FROM hr;

SELECT COUNT(*) FROM hr
WHERE age<18;



-- ANALYSIS

SELECT * FROM hr;

-- What is the gender breakdown of employees in company?

SELECT gender, COUNT(gender) AS 'gender_breakdown' FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;

-- What is the race/ethnicity breakdown of employees in company?

SELECT race, COUNT(race) AS 'race_breakdown' FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY race_breakdown DESC;

-- What is the age distribution of employees in company?

SELECT
	CASE
		WHEN age >=18 AND age<=24 THEN '18-24'
        WHEN age >=25 AND age<=34 THEN '25-34'
        WHEN age >=35 AND age<=44 THEN '35-44'
        WHEN age >=45 AND age<=54 THEN '45-54'
        WHEN age >=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
COUNT(age) AS age_breakdown FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;

-- What is the age distribution of employees in company seperated by gender?
SELECT
	CASE
		WHEN age >=18 AND age<=24 THEN '18-24'
        WHEN age >=25 AND age<=34 THEN '25-34'
        WHEN age >=35 AND age<=44 THEN '35-44'
        WHEN age >=45 AND age<=54 THEN '45-54'
        WHEN age >=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group, gender,
COUNT(age) AS age_breakdown FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- How many employees work at headquarters vs remote locations?

SELECT location, COUNT(location) AS workspace FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;

-- What is the average length of employment for employees who have been terminated?

SELECT ROUND(AVG(datediff(termdate, hire_date))/365,0) AS avg_length_employment FROM hr
WHERE age>=18 AND termdate <> '0000-00-00' AND termdate <= curdate();

-- How does the gender distribution vary across departments?

SELECT gender, department, COUNT(gender) AS gender_distribution FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender, department
ORDER BY department;

-- Which department has the highest turnover rate?

SELECT department, total_count, terminated_count, terminated_count/total_count AS termination_rate
FROM (SELECT department, COUNT(emp_id) AS total_count, SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
FROM hr
WHERE age>=18
GROUP BY department) as sq
ORDER BY termination_rate DESC;

-- What is the distribution of employees across locations by city and state?

SELECT location_state, COUNT(emp_id) AS employee_count FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY employee_count DESC;

-- How has the company's employee count changed over time based on hire and term dates?

SELECT year, hires, terminations, hires-terminations AS net_change, ROUND((hires-terminations)/hires * 100, 2) AS net_change_percent
FROM (SELECT YEAR(hire_date) AS year, COUNT(hire_date) AS hires, SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
FROM hr 
WHERE age >= 18
GROUP BY YEAR(hire_date)) AS SQ
ORDER BY year;

-- What is the tenure distribution for each department?

SELECT department, ROUND(AVG(DATEDIFF(termdate, hire_date)/365),0) AS avg_tenure FROM hr
WHERE age >= 18 AND termdate <> '0000-00-00' AND termdate <= CURDATE()
GROUP BY department;

 

