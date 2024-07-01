/* Migraine Attack Analysis */
/* Average duration, severity - seasonal patterns */
SELECT season, COUNT(*) AS num_migraines, AVG(duration) AS avg_duration, 
  AVG(severity_before) AS avg_severity 
FROM ( SELECT *, 
    CASE 
      WHEN EXTRACT(MONTH FROM date) IN (12, 1, 2) THEN 'Winter' 
      WHEN EXTRACT(MONTH FROM date) IN (3, 4, 5) THEN 'Spring' 
      WHEN EXTRACT(MONTH FROM date) IN (6, 7, 8) THEN 'Summer' 
      ELSE 'Fall' END AS season FROM migraine ) AS sub 
    GROUP BY season;

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

/* Functions and Clauses */
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
