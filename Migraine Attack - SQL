/* Migraine Attack Analysis */
/* Average duration */
SELECT patient_id, AVG(duration) AS avg_duration 
FROM migraine 
GROUP BY patient_id; 

SELECT medication, AVG(severity_before - severity_after) AS severity_reduction 
FROM migraine 
WHERE medication IS NOT NULL 
GROUP BY medication 
ORDER BY severity_reduction DESC LIMIT 10; 

SELECT season, COUNT(*) AS num_migraines, AVG(duration) AS avg_duration, 
  AVG(severity_before) AS avg_severity 
FROM ( SELECT *, 
    CASE 
      WHEN EXTRACT(MONTH FROM date) IN (12, 1, 2) THEN 'Winter' 
      WHEN EXTRACT(MONTH FROM date) IN (3, 4, 5) THEN 'Spring' 
      WHEN EXTRACT(MONTH FROM date) IN (6, 7, 8) THEN 'Summer' 
      ELSE 'Fall' END AS season FROM migraine ) AS sub 
        GROUP BY season;

/* Functions and Clauses */
SELECT p.patient_id, p.name, 
    AVG(m.duration) AS average_duration, 
    STRING_AGG(m.trigger, ', ') 
WITHIN GROUP (ORDER BY m.trigger) AS common_triggers 
FROM patients p 
JOIN migraines m ON p.patient_id = m.patient_id 
GROUP BY p.patient_id, p.name;

/* Effectiveness of  treatments */
SELECT treatment, EXTRACT(YEAR FROM attack_date) AS year, AVG(severity) AS avg_severity, 
COUNT(*) AS total_attacks 
FROM migraine_attacks GROUP BY treatment, year 
ORDER BY treatment, year;

/* Increasing frequency of attacks each month */
SELECT patient_id, ARRAY_AGG(monthly_count 
ORDER BY month) AS monthly_attack_trend
FROM ( SELECT patient_id, EXTRACT(MONTH FROM attack_date) AS month, COUNT(*) AS monthly_count 
FROM migraine_attacks 
GROUP BY patient_id, month) AS monthly_stats
GROUP BY patient_id 
HAVING ARRAY_LENGTH(monthly_attack_trend, 1) > 1 
  AND NOT (monthly_attack_trend[1] >= monthly_attack_trend[2] 
  AND monthly_attack_trend[2] >= monthly_attack_trend[3]); 

/* Comparing migraine attack frequency before and after lifestyle changes */
SELECT patient_id, SUM(CASE 
  WHEN lifestyle_change = 'Before' THEN 1 
    ELSE 0 
END) AS attacks_before, 
SUM(CASE 
  WHEN lifestyle_change = 'After' 
    THEN 1 
  ELSE 0 
  END) AS attacks_after 
FROM ( SELECT ma.patient_id, ma.attack_date, 
CASE WHEN ma.attack_date < p.lifestyle_change_date THEN 'Before' 
ELSE 'After' 
END 
AS lifestyle_change 
FROM migraine_attacks ma 
JOIN patients p ON ma.patient_id = p.patient_id ) AS sub 
GROUP BY patient_id; 

/* Frequency of migraine attacks and average severity for each patient*/
SELECT p.patient_id, p.name, COUNT(m.attack_id) AS total_attacks, AVG(m.severity) AS average_severity, 
SUM(
  CASE 
    WHEN m.effective_treatment = 'Yes' 
    THEN 1 
  ELSE 0 
END) AS effective_treatments 
FROM patients p 
JOIN migraine_attacks m ON p.patient_id = m.patient_id 
GROUP BY p.patient_id, p.name 
ORDER BY total_attacks DESC, average_severity; 

/* List patients along with the total number of their migraine attacks */
SELECT p.patient_id, p.name, (SELECT COUNT(*) 
FROM migraine_attacks m 
WHERE m.patient_id = p.patient_id) AS total_attacks 
FROM patients p; 
