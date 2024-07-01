* Recoding categorical variables ; 
data invtrend.invdata; 
  set invtrend.data; 
  if inv_type in ("tfsa", "rrsp", "resp", "fhsa")  then inv_type = "GIC"; 
  else if inv_type = "mf" then inv_type = "MF"; 
run; 

*SUMMARY STATISTICS; 
proc freq data=invtrend.data; 
    tables Age_group Education Occupation / missing; 
run;
* Summary Statistics of Income by Education ;
proc means data=invtrend.data;  
class education; 
var Income investments; 
title "Summary Statistics of Income by Education"; 
run; 

proc means data=invtrend.invdata;  
class age_group;  
var investments;  
title "Summary Statistics of Investments by age_group";  
run;

proc tabulate data=invtrend.data; 
  class age_group education occupation; 
  var income investments; 
  table income investments occupation; 
run;

*create visualizations for Investments based on Gender, Age_Group and Income; 
proc sgplot data=invtrend.data;  
vbar income / response=investments stat=mean datalabel;  
title "Average Investment by Income";  
run;  

*Heat Map of investments by Investment type and occupation; 
proc sgplot data=invtrend.data;  
heatmap x=occupation y=gender / colorresponse=investments;  
title "Heat Map of Average investments by occupation and gender";  
legend gender; 
run; 

proc reg data=invtrend.data; 
model income=investments; 
run;

proc glmselect data=invtrend.data outdesign(addinputvars)=_null_; 
	class investments gender / param=glm; 
	model income=gender investments / showpvalues selection=none; 
run; 
 
proc reg data=invtrend.data alpha=0.05 plots(only)=(diagnostics  
		observedbypredicted); 
	where investments is not missing and gender is not missing; 
	ods select DiagnosticsPanel ObservedByPredicted; 
	model income=&_GLSMOD /; 
	run;
quit;
ods noproctitle;  
ods graphics / imagemap=on;  
proc arima data=invtrend.data plots  (only)=(series(corr crosscorr) residual(corr normal)   
		forecast(forecastonly));  
	identify var=price;  
	estimate method=ML;  
	forecast lead=12 back=0 alpha=0.05;  
	outlier;  
	run;  
quit;
ods noproctitle; 
proc timeseries data=invtrend.data plots=(series corr); 
	var int / transform=none dif=0; 
	crossvar price / transform=none dif=0; 
run;

