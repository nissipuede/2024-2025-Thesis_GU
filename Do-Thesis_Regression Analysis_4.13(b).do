cls
set scheme white_tableau
use "/Users/nissicantu/Desktop/Hoya Saxa/Year 3/Spring 2025/Thesis Workshop II/Thesis Workshop/Thesis - Data/HPS/HPS_Final_Data III.dta", clear

**********************************************************************
  *Data Preparation & Visualization*
**********************************************************************
//Define pre-treatment (weeks 28-33) and post-treatment (weeks 34-41)
gen pre_post = .
replace pre_post = 0 if inrange(week, 28, 33)  
replace pre_post = 1 if inrange(week, 34, 41) 
label variable pre_post "Treatment Period Indicator"
label define pre_post_lbl 0 "Pre-Treatment (Weeks 28-33)" 1 "Post-Treatment (Weeks 34-41)"
label values pre_post pre_post_lbl

//Create a binary variable for anxiety
gen anxious_binary = (anxious > 1)
label variable anxious_binary "Anxious Indicator"
label define anxious_binary_lbl 0 "No" 1 "Yes"
label values anxious_binary anxious_binary_lbl

//Create a new binary variable "race" where White = 1, Non-White = 0
gen white = (rrace == 1)
label variable white "White"
label define white_lbl 0 "Non-White" 1 "White"
label values white white_lbl
tab white

//Rename "income" to "income_cat" to reflect that it's a categorical income variable (not continuous in dollars)
rename income income_cat
label variable income_cat "Household income category (before taxes)"

//Create a binary variable for "Less than high school" education (1 = Yes, 0 = No)
gen edu_lths = (eeduc == 1)
label variable edu_lths "Less than high school"
label define edu_lths_lbl 0 "Other" 1 "Less than high school"
label values edu_lths edu_lths_lbl
tab edu_lths

//Create a binary variable for "Some high school" education (1 = Yes, 0 = No)
gen edu_shs = (eeduc == 2)
label variable edu_shs "Some high school"
label define edu_shs_lbl 0 "Other" 1 "Some high school"
label values edu_shs edu_shs_lbl
tab edu_shs

//Create a binary variable for "High school graduate or equivalent" (1 = Yes, 0 = No)
gen edu_hsg = (eeduc == 3)
label variable edu_hsg "High school graduate or equivalent"
label define edu_hsg_lbl 0 "Other" 1 "High school graduate"
label values edu_hsg edu_hsg_lbl
tab edu_hsg

//Create a binary variable for "Some college, no degree" (1 = Yes, 0 = No)
gen edu_sc = (eeduc == 4)
label variable edu_sc "Some college, no degree"
label define edu_sc_lbl 0 "Other" 1 "Some college"
label values edu_sc edu_sc_lbl
tab edu_sc

//Create a binary variable for "Associate's degree" (1 = Yes, 0 = No)
gen edu_assoc = (eeduc == 5)
label variable edu_assoc "Associate's degree"
label define edu_assoc_lbl 0 "Other" 1 "Associate's degree"
label values edu_assoc edu_assoc_lbl
tab edu_assoc

//Create a binary variable for "Bachelor's degree" (1 = Yes, 0 = No)
gen edu_bach = (eeduc == 6)
label variable edu_bach "Bachelor's degree"
label define edu_bach_lbl 0 "Other" 1 "Bachelor's degree"
label values edu_bach edu_bach_lbl
tab edu_bach

//Create a binary variable for "Graduate degree" (1 = Yes, 0 = No)
gen edu_grad = (eeduc == 7)
label variable edu_grad "Graduate degree"
label define edu_grad_lbl 0 "Other" 1 "Graduate degree"
label values edu_grad edu_grad_lbl
tab edu_grad

// Dummy for hearing: 1 = some severity, 0 = no difficulty
gen hearing_d = (hearing > 1)
label variable hearing_d "Any hearing difficulty (some severity)"
label define hearing_d 0 "No difficulty" 1 "Some severity"
label values hearing_d hearing_d

// Dummy for mobility: 1 = some severity, 0 = no difficulty
gen mobility_d = (mobility > 1)
label variable mobility_d "Any mobility difficulty (some severity)"
label define mobility_d 0 "No difficulty" 1 "Some severity"
label values mobility_d mobility_d

// Dummy for seeing: 1 = some severity, 0 = no difficulty
gen seeing_d = (seeing > 1)
label variable seeing_d "Any seeing difficulty (some severity)"
label define seeing_d 0 "No difficulty" 1 "Some severity"
label values seeing_d seeing_d

// Dummy for gender: 1 = Male, 0 = Female
gen gender2 = (gender == 1)
label variable gender2 "Male (1=Male, 0=Female)"
label define gender2_lbl 0 "Female" 1 "Male"
label values gender2 gender2_lbl

**********************************************************************
  *Defining Sample Restrictions & Treatment Groups*
**********************************************************************
//Find median birth year for households with at least one child
sum tbirth_year if child_hh == 1, detail
local median_birth_year = r(p50)

//Define a broader sample range (Middle 50% of households, 8-year range)
gen byear74to82 = (abs(tbirth_year - `median_birth_year') <= 4)
label variable byear74to82 "Birth Year within Median ± 4 Years"

//Define treatment group: Households with children within 8-year range
gen treatment = 0
replace treatment = 1 if child_hh == 1 & byear74to82 == 1  

//Define control group: Households without children within 8-year range
gen control = 0
replace control = 1 if child_hh == 0 & byear74to82 == 1  

//Create an indicator for CTC eligibility
gen ctc_eligible = (child_hh == 1)
label define ctc_eligible 0 "No" 1 "Yes"
label values ctc_eligible ctc_eligible
label variable ctc_eligible "Eligible for Child Tax Credit"

//Investigating slippage between post-treatment CTC receipt and eligibility
tab ctc_yn ctc_eligible if pre_post == 1
/*
   Receipt and use of |  Eligible for Child
     Child Tax Credit |      Tax Credit
                (CTC) |        No        Yes |     Total
----------------------+----------------------+----------
                   No |   274,034     46,119 |   320,153 
                  Yes |     1,776     78,806 |    80,582 
----------------------+----------------------+----------
                Total |   275,810    124,925 |   400,735 
*/	
// There is evidence of slippage, as a significant number of eligible HHs (46,119/36.92%) did not receive the CTC. 			

// The IRS automatically enrolled eligible households for advance Child Tax Credit (CTC) payments if they had filed a 2019 or 2020 tax return or used the IRS Non-Filer Tool. However, those who did not file taxes or register through these tools were not automatically enrolled and had to claim the credit when filing their 2021 tax return. (https://www.irs.gov/credits-deductions/2021-child-tax-credit-and-advance-child-tax-credit-payments-topic-g-receiving-advance-child-tax-credit-payments)

**********************************************************************
  *Parallel Trends Assumption*
**********************************************************************
preserve
collapse (mean) anxious_binary, by(week treatment control)
gen time = week
twoway (line anxious_binary time if treatment == 1, lcolor(blue) lpattern(solid) ///
        title("", size(medium)) ///
        ytitle("Probability of Reporting Anxiety") xtitle("Week Number") ///
        legend(label(1 "Treatment: Parents (Age-Matched)"))) ///
       (line anxious_binary time if control == 1, lcolor(red) lpattern(dash) ///
        legend(label(2 "Control: Non-Parents (Age-Matched)"))) ///
       , xline(34, lpattern(dash) lcolor(gray) lwidth(medium)) ///
         xscale(range(28 41)) xlabel(28(2)41) ///
         note("Dashed vertical line indicates CTC implementation (Week 34)", size(vsmall))
restore 

**********************************************************************
  *Difference-in-Differences Analysis*
**********************************************************************
//Baseline DID Regression: Intent-to-Treat (ITT) Effect of CTC Eligibility on Anxiety
display "===== Running Difference-in-Differences Analysis: Baseline (No Controls) ====="
reg anxious_binary i.pre_post##i.ctc_eligible if byear74to82 == 1, robust
vif
estimate store Baseline_ITT2

//Difference-in-Differences Regression with Controls: Assessing the Impact of Household & Economic Factors
display "===== Running Difference-in-Differences Analysis: Baseline with Controls ====="
reg anxious_binary i.pre_post##i.ctc_eligible i.income_cat i.eeduc i.ms gender2 thhld_numper white rhispanic seeing_d hearing_d mobility_d snap_yn if byear74to82 == 1, robust
vif
estimate store DiD_Controls2

//Event-Study Regression: Weekly Effects of CTC Eligibility on Anxiety Over Time
display "===== Running Event-Study Analysis: CTC Eligibility & Anxiety Trends ====="
reg anxious_binary i.week##i.ctc_eligible i.income_cat i.eeduc i.ms gender2 thhld_numper white rhispanic seeing_d hearing_d mobility_d snap_yn if byear74to82 == 1, robust
vif
estimate store Event_Study2

//Export Regression Results for Documentation
etable, estimates(Baseline_ITT2 DiD_Controls2 Event_Study2) mstat(r2) mstat(N) ///
    showstars stars(.1 "*" .05 "**" .01 "***") ///
    export(RevisedRegression2.docx, replace)
	
**********************************************************************
  *Parallel Trends Assumption: Single-Parent vs. Two-Parent Households*
**********************************************************************
//Define single-parent households: At least one child, but only one adult
//Define the number of adults in the household
gen num_adults = thhld_numper - thhld_numkid 
label variable num_adults "Number of adults in household"

//Define single-parent households: At least one child and only one adult
gen single_parent = (thhld_numkid > 0 & num_adults == 1) 
label variable single_parent "Single-parent household"

//Label for single-parent household indicator
label define single_parent_lbl 0 "No" 1 "Yes"
label values single_parent single_parent_lbl

//Define two-parent households: At least one child and at least two adults
gen two_parent = (thhld_numkid > 0 & num_adults >= 2) 
label variable two_parent "Two-parent household"
preserve
collapse (mean) anxious_binary, by(week single_parent)
gen time = week
twoway (line anxious_binary time if single_parent == 1, lcolor(blue) lpattern(solid) ///
        title("", size(medium)) ///
        ytitle("Probability of Reporting Anxiety") xtitle("Week Number") ///
        legend(label(1 "Single-Parent Households"))) ///
       (line anxious_binary time if single_parent == 0, lcolor(red) lpattern(dash) ///
        legend(label(2 "Two-Parent Households"))) ///
       , xline(34, lpattern(dash) lcolor(gray) lwidth(medium)) ///
         xscale(range(28 41)) xlabel(28(2)41) ///
         note("Dashed vertical line indicates CTC implementation (Week 34)", size(vsmall))
restore 

**********************************************************************
  *Difference-in-Differences Analysis: Single-Parent vs. Two-Parent Households*
**********************************************************************
//DID Regression: Comparing Anxiety Trends for Single-Parent vs. Two-Parent Households (CTC-Eligible Only)
display "===== Running Difference-in-Differences Analysis: Single-Parent vs. Non-Single-Parent Households ====="
reg anxious_binary i.pre_post##i.single_parent i.income_cat i.eeduc i.ms gender2 thhld_numper white rhispanic seeing_d hearing_d mobility_d snap_yn if byear74to82 == 1 & ctc_eligible == 1, robust
vif
estimate store SingleParentDiD2

//Event-Study Regression: Weekly Effects of CTC on Anxiety for Single-Parent vs. Two-Parent Households (CTC-Eligible Only)
reg anxious_binary i.week##i.single_parent i.income_cat i.eeduc i.ms gender2 thhld_numper white rhispanic seeing_d hearing_d mobility_d snap_yn if byear74to82 == 1 & ctc_eligible == 1, robust
vif
estimate store SingleParentEventStudy2

//Export Regression Results for Documentation
etable, estimates(SingleParentDiD2 SingleParentEventStudy2) mstat(r2) mstat(N) ///
    showstars stars(.1 "*" .05 "**" .01 "***") ///
    export(Single-Parent2.docx, replace)

**********************************************************************
  *Parallel Trends Assumption: Non-College vs. College Households*
**********************************************************************
//Define non-college-educated households: High school or less
gen non_college = (eeduc <= 4)  
label variable non_college "Non-College Household"
label define non_college_lbl 0 "College-Educated Household" 1 "Non-College Household"
label values non_college non_college_lbl

//Define college-educated households: Associate's degree or higher
gen college_educated = (eeduc >= 5)  
label variable college_educated "College-Educated Household"
label define college_educated_lbl 0 "Non-College Household" 1 "College-Educated Household"
label values college_educated college_educated_lbl

// Parallel Trends Visualization: Anxiety Over Time (Non-College vs. College)
preserve
collapse (mean) anxious_binary, by(week non_college)
gen time = week
twoway (line anxious_binary time if non_college == 1, lcolor(red) lpattern(dash) ///
        title("", size(medium)) ///
        ytitle("Probability of Reporting Anxiety") xtitle("Week Number") ///
        legend(label(1 "Non-College (High School or Less)"))) ///
       (line anxious_binary time if non_college == 0, lcolor(blue) lpattern(solid) ///
        legend(label(2 "College-Educated (Associate's or Higher)"))) ///
       , xline(34, lpattern(dash) lcolor(gray) lwidth(medium)) ///
         xscale(range(28 41)) xlabel(28(2)41) ///
         note("Dashed vertical line marks CTC implementation (Week 34)", size(vsmall))
restore 

**********************************************************************
  *Difference-in-Differences Analysis: Non-College vs. College Households*
**********************************************************************

//DID Regression: Comparing Anxiety Trends for Non-College vs. College Households (CTC-Eligible Only)
display "===== Running Difference-in-Differences: Non-College vs. College Households ====="
reg anxious_binary i.pre_post##i.non_college i.income_cat i.eeduc i.ms gender2 thhld_numper white rhispanic seeing_d hearing_d mobility_d snap_yn ///
    if byear74to82 == 1 & ctc_eligible == 1, robust
vif
estimate store NonCollegeDiD2

//Event-Study Regression: Weekly Effects of CTC on Anxiety for Non-College vs. College Households (CTC-Eligible Only)
display "===== Running Event-Study: Non-College vs. College Households ====="
reg anxious_binary i.week##i.non_college i.income_cat i.eeduc i.ms gender2 thhld_numper white rhispanic seeing_d hearing_d mobility_d snap_yn ///
    if byear74to82 == 1 & ctc_eligible == 1, robust
vif
estimate store NonCollegeEventStudy2

//Export Regression Results for Documentation
etable, estimates(NonCollegeDiD2 NonCollegeEventStudy2) mstat(r2) mstat(N) ///
    showstars stars(.1 "*" .05 "**" .01 "***") ///
    export(Non-College2.docx, replace)

**********************************************************************
  *Parallel Trends Assumption: Low-Income vs. Non-Low-Income Households*
**********************************************************************
//Define low-income households (Income categories 1-4, ≤ $58,020)
gen low_income = inlist(income, 1, 2, 3, 4)
label variable low_income "Low-Income Household (≤ $58,020)"
label define low_income_lbl 0 "No (> $58,020)" 1 "Yes (≤ $58,020)"
label values low_income low_income_lbl

//Define non-low-income households (Income categories 5-8, > $58,020)
gen non_low_income = inlist(income, 5, 6, 7, 8)
label variable non_low_income "Non-Low-Income Household (> $58,020)"
label define non_low_income_lbl 0 "No (≤ $58,020)" 1 "Yes (> $58,020)"
label values non_low_income non_low_income_lbl

//Parallel Trends Visualization: Anxiety Over Time (Low-Income vs. Non-Low-Income)
preserve
collapse (mean) anxious_binary, by(week low_income)
gen time = week
twoway (line anxious_binary time if low_income == 1, lcolor(red) lpattern(dash) ///
        title("", size(medium)) ///
        ytitle("Probability of Reporting Anxiety") xtitle("Week Number") ///
        legend(label(1 "Low-Income (≤ $58,020)"))) ///
       (line anxious_binary time if low_income == 0, lcolor(blue) lpattern(solid) ///
        legend(label(2 "Non-Low-Income (> $58,020)"))) ///
       , xline(34, lpattern(dash) lcolor(gray) lwidth(medium)) ///
         xscale(range(28 41)) xlabel(28(2)41) ///
         note("Dashed vertical line marks CTC implementation (Week 34)", size(vsmall))
restore 

**********************************************************************
  *Difference-in-Differences Analysis: Low-Income vs. Non-Low-Income Households*
**********************************************************************
//DID Regression: Comparing Anxiety Trends for Low-Income vs. Non-Low-Income Households (CTC-Eligible Only)
display "===== Running Difference-in-Differences: Low-Income vs. Non-Low-Income Households ====="
reg anxious_binary i.pre_post##i.low_income i.income_cat i.eeduc i.ms gender2 thhld_numper white rhispanic seeing_d hearing_d mobility_d snap_yn ///
    if byear74to82 == 1 & ctc_eligible == 1, robust
vif
estimate store LowIncomeDiD2

//Event-Study Regression: Weekly Effects of CTC on Anxiety for Low-Income vs. Non-Low-Income Households (CTC-Eligible Only)
display "===== Running Event-Study: Low-Income vs. Non-Low-Income Households ====="
reg anxious_binary i.week##i.low_income i.income_cat i.eeduc i.ms gender2 thhld_numper white rhispanic seeing_d hearing_d mobility_d snap_yn ///
    if byear74to82 == 1 & ctc_eligible == 1, robust
vif
estimate store LowIncomeEventStudy2

//Export Regression Results for Documentation
etable, estimates(LowIncomeDiD2 LowIncomeEventStudy2) mstat(r2) mstat(N) ///
    showstars stars(.1 "*" .05 "**" .01 "***") ///
    export(Low-Income2.docx, replace)
	
/**********************************************************************
Descriptive Statistics for Thesis: UPDATED 
**********************************************************************/
//Summary statistics for dependent variable(s)
sum anxious 
sum anxious, detail

/**********************************************************************
Descriptive Statistics for Thesis
**********************************************************************/
//Summary statistics for the newly created binary dependent variable(s)
sum anxious_binary
sum anxious_binary, detail
tab anxious_binary

//Summary statistics for key independent variable(s)
sum ctc_eligible
sum ctc_eligible, detail 
tab ctc_eligible 
tab ctc_eligible if inrange(week, 34, 41) // Post-Treatment  

sum single_parent
sum single_parent, detail
tab single_parent
tab single_parent if inrange(week, 34, 41) // Post-Treatment    

sum non_college
sum non_college, detail 
tab non_college
tab non_college if inrange(week, 34, 41) // Post-Treatment  

sum low_income
sum low_income, detail
tab low_income
tab low_income if inrange(week, 34, 41) // Post-Treatment  

//Summary statistics for potential control variable(s)
sum income_cat
sum income_cat, detail 
tab income_cat 

sum eeduc
sum eeduc, detail 
tab eeduc

sum seeing hearing mobility
sum seeing hearing mobility, detail 
tab seeing 
tab hearing 
tab mobility

sum snap_yn
sum snap_yn, detail 
tab snap_yn

sum ms  
sum ms, detail
tab ms

sum thhld_numper  
sum thhld_numper, detail
tab thhld_numper

sum white
sum white, detail
tab white

sum rhispanic
sum rhispanic, detail 
tab rhispanic

/**********************************************************************
Correlation Coefficients 
**********************************************************************/
correlate ctc_eligible anxious_binary 
