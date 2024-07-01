*SUMMARY STATISTICS;
proc freq data=lmt.job_data;
    tables Job_Title Job_ID Date_Posted Date_Updated  
    Status Job_Type Skills Dept Location Sal_Range / missing;
run;

proc means data=let.data_means chartype min max var range vardef=df;
	var Min_Sal Max_Sal;
	class Location dept Skills Job_Type;
run;

* VISUALISATIONS ;
proc sgplot data=let.DATA_SPLIT;
	vbar dept / group=sal_Max groupdisplay=cluster stat=percent;
	yaxis grid;
run;

proc arima data=temp plots=all;
	identify var=Max_Sal;
	estimate method=ML;
	forecast lead=15 back=0 alpha=0.05 id=Date_Posted interval=second;
	outlier;
	by Skills;
	run;
quit;
