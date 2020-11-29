libname project "/folders/myfolders/DataManagement/project";

*import data;
proc import out=project.bodymeasure
		datafile="/folders/myfolders/DataManagement/project/bodymeasure.csv" 
		dbms=csv 
		replace;
run;

proc import out=project.cotinine
		datafile="/folders/myfolders/DataManagement/project/cotinine.csv" 
		dbms=csv 
		replace;
run;
proc import out=project.demo
		datafile="/folders/myfolders/DataManagement/project/demo.csv" 
		dbms=csv 
		replace;
run;
proc import out=project.lipid
		datafile="/folders/myfolders/DataManagement/project/lipid.csv" 
		dbms=csv 
		replace;
run;

*Question 2 - combining data;
proc sort data=project.bodymeasure;
by ID;
run;

proc sort data=project.cotinine;
by ID;
run;

proc sort data=project.demo;
by ID;
run;

proc sort data=project.lipid;
by ID;
run;

*combine datasets; 
data project.combined1;
merge project.bodymeasure (in=a) project.cotinine (in=b);
by id;
if a and b; 
run;

data project.combined2;
merge project.demo (in=a) project.lipid (in=b);
by id;
if a and b; 
run;

data project.allcombined;
merge project.combined1 (in=a) project.combined2 (in=b);
by id;
if a and b; 
run;


*delete missing data; 
data project.allcombined_cleaned;
set project.allcombined;
if Weight_kg=. then delete;
if Height_cm=. then delete;
if Cotinine=. then delete;
if Gender=. then delete;
if Age=. then delete;
if Ethnicity=. then delete;
if PIR=. then delete;
if Triglyceride=. then delete;
if LDLHDL=. then delete;
run;

*restrict to subjects with age less than 20; 
data project.allcombined_cleaned;
set project.allcombined_cleaned;
if age>=20 then delete;
run;

*new age category; 
data project.allcombined_cleaned;
set project.allcombined_cleaned;
if age<6 then age_cat="less than 6";
if 6=<age=<12 then age_cat="6-12";
if 13=<age=<19 then age_cat= "13-19";

*new ethnicity variable;
data project.allcombined_cleaned;
set project.allcombined_cleaned;
format eth_cat $ 8.;
if ethnicity=1 then eth_cat="Ame_mex";
if ethnicity=2 then eth_cat="Other";
if ethnicity=3 then eth_cat="NH_White";
if ethnicity=4 then eth_cat="NH_Black";
if ethnicity=5 then eth_cat="Other";
run;

*new poverty variable; 
data project.allcombined_cleaned;
set project.allcombined_cleaned;
format pov_cat $ 7.;
if PIR<1.3 then pov_cat="<1.3";
if 1.3=<PIR=<3.5 then pov_cat="1.3-3.5";
if PIR>3.5 then pov_cat=">3.5";
run;

*create BMI Variable;
data project.allcombined_cleaned;
set project.allcombined_cleaned;
Height_m=(Height_cm/100);
run;
data project.allcombined_cleaned;
set project.allcombined_cleaned;
BMI=(Weight_kg/(Height_m)**2);
run;

*BMI categories;
data project.allcombined_cleaned;
set project.allcombined_cleaned;
If BMI=<25 then BMI_cat="Underweight or Normal";
If 25<BMI=<30 then BMI_cat="Overweight";
If BMI>30 then BMI_cat="Obese";
run;

*secondhand smoke biomarker;
data project.allcombined_cleaned;
set project.allcombined_cleaned;
format biomarker_cat $ 18.;
If cotinine>10 then biomarker_cat="smoke_secondhand";
If cotinine=<10 then biomarker_cat="nosmoke_secondhand";
run;

*fill in table;
proc freq data=project.allcombined_cleaned;
tables gender*age_cat;
run;

proc freq data=project.allcombined_cleaned;
tables gender*eth_cat;
run;

proc freq data=project.allcombined_cleaned;
tables gender*pov_cat;
run;

proc freq data=project.allcombined_cleaned;
tables gender*biomarker_cat;
run;

proc freq data=project.allcombined_cleaned;
tables gender*bmi_cat;
run;

proc univariate data=project.allcombined_cleaned;
class gender;
var triglyceride;
run;

proc univariate data=project.allcombined_cleaned;
class gender;
var LDLHDL;
run;

*5.1;
proc sort data=project.allcombined_cleaned;
by gender;
run;

proc ttest data=project.allcombined_cleaned h0=150 alpha=0.05;
var triglyceride;
by gender;
run;

*5.2;
proc ttest data=project.allcombined_cleaned h0=5 alpha=0.05;
var LDLHDL;
by gender;
run;


*5.3;
proc ttest data=project.allcombined_cleaned;
class gender;
var triglyceride;
run;

*5.4;
proc ttest data=project.allcombined_cleaned;
class gender;
var LDLHDL;
run;

*5.5 - BOXPLOT;
proc sort data=project.allcombined_cleaned;
by gender;
run;

proc boxplot data=project.allcombined_cleaned;
plot triglyceride*gender;
run;

proc boxplot data=project.allcombined_cleaned;
plot LDLHDL*gender;
run;

*6.0 - CORRELATION ;
proc corr data=project.allcombined_cleaned;
var cotinine triglyceride;
run;

proc sgplot data=project.allcombined_cleaned;
scatter y=cotinine x=triglyceride;
run;

proc corr data=project.allcombined_cleaned;
var cotinine LDLHDL;
run;

proc sgplot data=project.allcombined_cleaned;
scatter y=cotinine x=LDLHDL;
run;
*REGRESSION;
proc reg data=project.allcombined_cleaned;
model cotinine=triglyceride;
run;

proc reg data=project.allcombined_cleaned;
model cotinine=LDLHDL;
run;