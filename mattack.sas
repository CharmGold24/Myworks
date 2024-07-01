*Determine the Average Age of Patients by Gender;
proc tabulate data=patient;
 class sex;
 var age;
 table sex='',(age='')*(n mean)/box='gender';
 keylabel n=N_age;
 keylabel mean=mean_age;
run;

*PROC MEANS To deterine average age of patients;
proc means data=patient;
 class sex;
 var age;
 output out=details(drop=_type_ _freq_) n=n mean=meanage;
run;

/* Average Attack (Months), Frequency and Duration*/
proc import datatable=madetail out=madetail dbms=access;
 database="/home/u123456/DATA.mdb";
run;

data ma;
 set  madetail;
 keep v1attksincemonths V1attkfreqpm V1durationattk;
run;

*Analysis of Side Effects of Migraine Attack;
data ma1;
 set madetail;
 if v1aura='Y' then v1aura='Yes';
 else v1aura='No';
 if v1nausea='Y' then v1nausea='Yes';
 else v1nausea='No';
run;
