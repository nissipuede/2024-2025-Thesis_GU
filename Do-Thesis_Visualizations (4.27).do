cls
clear
set scheme white_tableau 
use "/Users/nissicantu/Desktop/Hoya Saxa/Year 3/Spring 2025/Thesis Workshop II/Thesis Workshop/Thesis - Data/HPS/HPS_Final_Data IV.dta", clear 
**********************************************************************
  *Parallel Trends Assumption: All Individuals (Not Age-Matched)*
**********************************************************************
preserve
collapse (mean) anxious_binary, by(week ctc_eligible)
gen time = week
twoway (line anxious_binary time if ctc_eligible == 1, lcolor(dknavy) lpattern(solid) lwidth(thick) ///
        title("", size(medium)) ///
        ytitle("Probability of Reporting Anxiety") xtitle("Week Number") ///
        legend(label(1 "Treatment: Parents"))) ///
       (line anxious_binary time if ctc_eligible == 0, lcolor(mint) lpattern(solid) lwidth(thick) ///
        legend(label(2 "Control: Non-Parents"))) ///
       , xline(34, lpattern(dash) lcolor(red) lwidth(medium)) ///
         xscale(range(28 41)) xlabel(28(2)41) ///
		 aspect(1.2) ///
         note("Dashed vertical line indicates CTC implementation (Week 34)", size(vsmall))
restore 

**********************************************************************
  *Parallel Trends Assumption: Age-Matched*
**********************************************************************
preserve
keep if byear74to82 == 1
collapse (mean) anxious_binary, by(week ctc_eligible)
gen time = week
twoway (line anxious_binary time if ctc_eligible == 1, lcolor(dknavy) lpattern(solid) lwidth(thick) ///
        title("", size(medium)) ///
        ytitle("Probability of Reporting Anxiety") xtitle("Week Number") ///
        legend(label(1 "Treatment: Parents (Age-Matched)"))) ///
       (line anxious_binary time if ctc_eligible == 0, lcolor(mint) lpattern(solid) lwidth(thick) ///
        legend(label(2 "Control: Non-Parents (Age-Matched)"))) ///
       , xline(34, lpattern(dash) lcolor(red) lwidth(medium)) ///
         xscale(range(28 41)) xlabel(28(2)41) ///
		 aspect(1.2) ///
         note("Dashed vertical line indicates CTC implementation (Week 34)", size(vsmall))
restore 

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
keep if byear74to82 == 1
collapse (mean) anxious_binary, by(week single_parent)
gen time = week
twoway (line anxious_binary time if single_parent == 1, lcolor(dknavy) lpattern(solid) lwidth(thick) ///
        title("", size(medium)) ///
        ytitle("Probability of Reporting Anxiety") xtitle("Week Number") ///
        legend(label(1 "Single-Parent Households"))) ///
       (line anxious_binary time if single_parent == 0, lcolor(mint) lpattern(solid) lwidth(thick) ///
        legend(label(2 "Two-Parent Households"))) ///
       , xline(34, lpattern(dash) lcolor(red) lwidth(medium)) ///
         xscale(range(28 41)) xlabel(28(2)41) ///
		 aspect(1.2) ///
         note("Dashed vertical line indicates CTC implementation (Week 34)", size(vsmall))
restore 

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
keep if byear74to82 == 1
collapse (mean) anxious_binary, by(week non_college)
gen time = week
twoway (line anxious_binary time if non_college == 1, lcolor(dknavy) lpattern(solid) lwidth(thick) ///
        title("", size(medium)) ///
        ytitle("Probability of Reporting Anxiety") xtitle("Week Number") ///
        legend(label(1 "Non-College (High School or Less)"))) ///
       (line anxious_binary time if non_college == 0, lcolor(mint) lpattern(solid) lwidth(thick) ///
        legend(label(2 "College-Educated (Associate's or Higher)"))) ///
       , xline(34, lpattern(dash) lcolor(red) lwidth(medium)) ///
         xscale(range(28 41)) xlabel(28(2)41) ///
		 aspect(1.2) ///
         note("Dashed vertical line marks CTC implementation (Week 34)", size(vsmall))
restore 

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
keep if byear74to82 == 1
collapse (mean) anxious_binary, by(week low_income)
gen time = week
twoway (line anxious_binary time if low_income == 1, lcolor(dknavy) lpattern(solid) lwidth(thick)  ///
        title("", size(medium)) ///
        ytitle("Probability of Reporting Anxiety") xtitle("Week Number") ///
        legend(label(1 "Low-Income (≤ $58,020)"))) ///
       (line anxious_binary time if low_income == 0, lcolor(mint) lpattern(solid) lwidth(thick)  ///
        legend(label(2 "Non-Low-Income (> $58,020)"))) ///
       , xline(34, lpattern(dash) lcolor(red) lwidth(medium)) ///
         xscale(range(28 41)) xlabel(28(2)41) ///
		 aspect(1.2) ///
         note("Dashed vertical line marks CTC implementation (Week 34)", size(vsmall))
restore 
