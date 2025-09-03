***
* Adaptation project
* Purpose: main regressions 
* Date: 7/17/2022
***

global dirc "C:\Users\mm_wi\Documents\research\vietnam_adaptation\analysis"
global output "C:\Users\mm_wi\Documents\research\vietnam_adaptation\analysis\output"

******** Preparation ********
* data
use $dirc/VN-adaptation.dta, clear
//import excel $data/VN_adaptation_revised.xlsx, sheet("data2") firstrow clear
* village
encode province, gen(prov)
encode district, gen(dist)
encode commune, gen(com)
encode village, gen(vil)
replace village = "Tam Tri" if village == "Tam tri"
replace village = "Thanh Long" if village == "Thanh Lang"
replace village = "Tân Định" if village == "Tăng Định"
replace village = "Vị Dương Đoài" if village == "Vị Dương Đoài "
replace village = "Xuân Phương Đông" if village == "Xuân Phương Hồng"
replace village = "Tân Hòa" if village == "Tân hòa"
replace village = "Tam Phú A" if village == "Tân Phú A"
replace village = "Vị Dương Đông" if village == "Vị Dương Đông "
replace village = "Vĩnh Long" if village == "vĩnh long"
replace village = "Xuân Phương Đông" if village == "Xuân Phương Đông "
replace village = "Vĩnh Phú" if village == "vĩnh phú"
replace village = "Dương Quang" if village == "Đồng Xuân"
* reshape long
local inputs "area prod flaborhr flabor hlaborhr hlabor seed tfert urea phosphate kali npk otherfert otherfert_name insect herbicide molluscicide fungicide"
foreach v in `inputs' {
	rename `v'_ds `v'1
	rename `v'_ws `v'2
	}
reshape long `inputs', i(hhid) j(season)

* commune
tabulate village, gen(village)
global vill_dum village1 village2 village3 village4 village5 village6 village7 village8 village9 village10 village11 village12 village13 village14 village15 village16 village17 village18 village19 village20 village21

* variables: input
replace prod = . if prod == 0
replace area = . if area == 0
gen yield = prod/area
label var yield "Yield (kg/ha)"
label var area "Area (ha)"
gen ln_yield = log(prod/area + 1)
gen ln_prod = log(prod + 1)
label var ln_prod "Ln Production"
gen ln_area = log(area + 1)
label var ln_area "Ln Area"
gen Seed = seed/area
label var Seed "Seed (kg/ha)"
gen ln_seed = log(seed/area + 1)
label var ln_seed "Ln Seed"
gen Flabor = (flaborhr/8)/area
label var Flabor "Family labor (man-days/ha)"
gen ln_flabor = log(Flabor + 1)
label var ln_flabor "Ln Family labor"
gen Hlabor = (hlaborhr/8)/area
label var Hlabor "Hired labor (man-days/ha)"
gen ln_hlabor = log(Hlabor + 1)
label var ln_hlabor "Ln Hired labor"
gen Labor = Hlabor + Flabor
label var Labor "Labor (man-days/ha/ha)"
gen ln_labor = log(Labor/area + 1)
label var ln_labor "Ln labor"
gen Tfert = urea/area
label var Tfert "Fertilizer (kg/ha)"
gen ln_tfert = log(tfert/area + 1)
label var ln_tfert "Ln Fertilizer"
gen ins = 1 - (insect == 0) 
gen herb = 1 - (herbicide == 0) 
gen moll = 1 - (molluscicide == 0) 
gen fung = 1 - (fungicide == 0) 
gen dry = (season == 1)
label var dry "Dry season"
gen irrig = (ecosystem == 1)
label var irrig "Irrigation"


foreach x in ln_seed ln_labor ln_tfert {
gen `x'_sq = `x'*`x'
}
gen ln_seed_labor = ln_seed*ln_labor
gen ln_seed_fert = ln_seed*ln_tfert
gen ln_labor_fert = ln_labor*ln_tfert

******** Descriptive ********
rename ccstrat1 FAS1
rename fachg1 FAS2
rename ccstrat6 FAS3
label var FAS1 "Use of stress-tolerant varieties"
label var FAS2 "Change in cropping pattern"
label var FAS3 "Pest and disease management techniques"
*label var ccstrat3 "Changes in varieties"
*label var ccstrat4 "New land management techniques"
*label var ccstrat5 "Changes in water-management"
*label var ccstrat7 "Develop and use of crop varieties resistant to pests and diseases"
*label var ccstrat8 "New livestock breeds"
*label var ccstrat9 "Improved animal health management"
*label var ccstrat10 "Changing crop calendar"
*label var ccstrat11 "Changing level of input used"
*label var ccstrat12 "Crop rotation"
label var m_stress5 "Heat"
label var m_stress1 "Flood"
label var m_stress4 "Drought"
label var m_stress3 "Salinity"
label var m_stress6 "Sea-level rise"
label var m_stress2 "Storm"
label var m_stress7 "None"


* variables: IV
for num 1/3: bysort village: egen ivX = sum(FASX)
bysort village: egen n_vil = count(FAS1)
drop if n_vil < 10
for num 1/3: replace ivX = ivX - 1 if FASX == 1
for num 1/3: replace ivX = ivX/(n_vil - 1)

save data_analysis, replace

******** Table 2: Descriptive statistics ********
eststo CVN1: qui estpost su prod area Seed Labor Tfert FAS1 FAS2 FAS3 ///
	hh_age hhschl hhyrfarm tothsz if region == "CVN" & season == 1
eststo RRD1: qui estpost su prod area Seed Labor Tfert FAS1 FAS2 FAS3 ///
	hh_age hhschl hhyrfarm tothsz if region == "RRD" & season == 1
eststo Diff1: qui estpost ttest prod area Seed Labor Tfert FAS1 FAS2 FAS3 ///
	hh_age hhschl hhyrfarm tothsz if season == 1, by(region) // Diff.
eststo CVN2: qui estpost su prod area Seed Labor Tfert ///
	if region == "CVN" & season == 2
eststo RRD2: qui estpost su prod area Seed Labor Tfert ///
	if region == "RRD" & season == 2
eststo Diff2: qui estpost ttest prod area Seed Labor Tfert ///
	if season == 2, by(region) // Diff.
esttab CVN1 RRD1 Diff1 using $output\table2_1.csv, ///
	label nogap nonotes nomtitle nonumber b(%4.3f) ///
	cells("mean(pattern(1 1 0) fmt(3)) sd(pattern(1 1 0) fmt(3)) b(star pattern(0 0 1) fmt(3)) se(pattern(0 0 1) fmt(3)) ") ///
	mgroups("CVN" "RRD" "Difference", pattern(1 1 0)) replace
	
esttab CVN2 RRD2 Diff2 using $output\table2_2.csv, ///
	label nogap nonotes nomtitle nonumber ///
	cells("mean(pattern(1 1 0) fmt(3)) sd(pattern(1 1 0) fmt(3)) b(star pattern(0 0 1) fmt(3)) se(pattern(0 0 1) fmt(3)) ") ///
	mgroups("CVN" "RRD" "Difference", pattern(1 1 0)) replace
estimates drop CVN1 RRD1 Diff1 CVN2 RRD2 Diff2


******** Table 3: adaptation and production ********
global FAS "FAS1 FAS2 FAS3"
global res "res1 res2 res3"
global xvar "ln_seed ln_labor ln_tfert"
global socio "hh_age hhschl hhyrfarm tothsz"


* OLS
eststo model2: reg ln_yield $FAS $xvar $socio dry i.prov
qui estadd local prov "Yes"
qui estadd local hh "Yes"

* 2SRI: 1st stage
probit FAS1 iv1 $xvar $socio dry i.prov
predict yhat1
gen res1 = FAS1 - yhat1

probit FAS2 iv2 $xvar $socio dry i.prov
predict yhat2
gen res2 = FAS2 - yhat2

probit FAS3 iv3 $xvar $socio dry i.prov
predict yhat3
gen res3 = FAS3 - yhat3

* 2SRI: 2nd stage
eststo model3: bootstrap: reg ln_yield $FAS $xvar dry i.prov $res
qui estadd local prov "Yes"
qui estadd local hh "No"

eststo model4: bootstrap: reg ln_yield $FAS $xvar $socio dry i.prov $res
qui estadd local prov "Yes"
qui estadd local hh "Yes"

* table
esttab model2 model3 model4 ///
	using $output\table3_1.csv, ///
	se label nogap nonotes nomtitles b(%4.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	s(prov hh r2 N, fmt(%9.3f %9.3f %9.3f %9.0g) ///
	labels("Province FE" "Household characteristics" "R squared" "Observations")) ///
	keep(FAS1 FAS3 FAS2 ln_seed ln_labor ln_tfert dry ///
	res1 res2 res3 _cons) ///
	mgroups("OLS" "2SRI" "2SRI", pattern(1 0 1 0 1 0) span)  replace
estimates drop model2 model3 model4


******** Table 3: adaptation and downside risk ********
* estimates skewness
foreach x in $xvar ln_yield {
	bysort commune season: egen `x'_bar = mean(`x')
	}

reg ln_yield $xvar if season == 1
gen residual_risk = ln_yield - ln_yield_bar - e(b)[1,1]*(ln_seed - ln_seed_bar) ///
	- e(b)[1,2]*(ln_labor - ln_labor_bar) - e(b)[1,3]*(ln_tfert - ln_tfert_bar)
reg ln_prod $xvar if season == 2
replace residual_risk = ln_yield - ln_yield_bar - e(b)[1,1]*(ln_seed - ln_seed_bar) ///
	- e(b)[1,2]*(ln_labor - ln_labor_bar) - e(b)[1,3]*(ln_tfert - ln_tfert_bar) ///
	if season == 2
gen skewness = residual_risk^3

* OLS 
reg skewness FAS1 $xvar dry $vil_dum
reg skewness FAS2 $xvar dry $vil_dum
reg skewness FAS3 $xvar dry $vil_dum
eststo model2: reg skewness $FAS $xvar $socio dry i.prov
qui estadd local prov "Yes"
qui estadd local hh "Yes"

* 2SRI: 2nd stage
eststo model3: bootstrap: reg skewness $FAS $xvar dry i.prov $res
qui estadd local prov "Yes"
qui estadd local hh "No"
eststo model4: bootstrap: reg skewness $FAS $xvar $socio dry i.prov $res
qui estadd local prov "Yes"
qui estadd local hh "Yes"

* table
esttab model2 model3 model4 ///
	using $output\table3_2.csv, ///
	se label nogap nonotes nomtitles b(%4.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	s(prov hh r2 N, fmt(%9.3f %9.3f %9.3f %9.0g) ///
	labels("Province FE" "Household characteristics" "R squared" "Observations")) ///
	keep(FAS1 FAS3 FAS2 ln_seed ln_labor ln_tfert dry ///
	res1 res2 res3 _cons) ///
	order(FAS1 FAS2 FAS3)  replace
estimates drop model2 model3 model4
drop res1 res2 res3

******** Figure 5: Geographical heterogeneity ********
use data_analysis, clear
global FAS "FAS1 FAS2 FAS3"
global res_r "res1 res2 res3"
global res_c "res4 res5 res6"
global res_d "res7 res8 res9"
global res_w "res10 res11 res12"
global xvar "ln_seed ln_labor ln_tfert"
global socio "hh_age hhschl hhyrfarm tothsz"

label var FAS1 "FAS1"
label var FAS2 "FAS2"
label var FAS3 "FAS3"

******** Productivity:RRD
probit FAS1 iv1 $xvar $socio dry i.prov if region == "RRD"
predict yhat1
gen res1 = FAS1 - yhat1
probit FAS2 iv2 $xvar $socio dry i.prov if region == "RRD"
predict yhat2
gen res2 = FAS2 - yhat2
probit FAS3 iv3 $xvar $socio dry i.prov if region == "RRD"
predict yhat3
gen res3 = FAS3 - yhat3

eststo model1: bootstrap: reg ln_yield $FAS $xvar $socio dry i.prov $res_r if region == "RRD"
qui estadd local prov "Yes"
qui estadd local hh "Yes"

******** Productivity:CVN
probit FAS1 iv1 $xvar $socio dry i.prov if region == "CVN"
predict yhat4
gen res4 = FAS1 - yhat4
probit FAS2 iv2 $xvar $socio dry i.prov if region == "CVN"
predict yhat5
gen res5 = FAS2 - yhat5
probit FAS3 iv3 $xvar $socio dry i.prov if region == "CVN"
predict yhat6
gen res6 = FAS3 - yhat6

eststo model2: bootstrap: reg ln_yield $FAS $xvar $socio dry i.prov $res_c if region == "CVN"

coefplot (model1, label(RRD)) (model2, label(CVN)), keep($FAS) replace
graph export $output/figure5_a.jpg, as(jpg) quality(100) replace

******** Downside risk
foreach x in $xvar ln_yield {
	bysort commune season: egen `x'_bar = mean(`x')
	}

reg ln_yield $xvar if season == 1
gen residual_risk = ln_yield - ln_yield_bar - e(b)[1,1]*(ln_seed - ln_seed_bar) ///
	- e(b)[1,2]*(ln_labor - ln_labor_bar) - e(b)[1,3]*(ln_tfert - ln_tfert_bar)
reg ln_prod $xvar if season == 2
replace residual_risk = ln_yield - ln_yield_bar - e(b)[1,1]*(ln_seed - ln_seed_bar) ///
	- e(b)[1,2]*(ln_labor - ln_labor_bar) - e(b)[1,3]*(ln_tfert - ln_tfert_bar) ///
	if season == 2
gen skewness = residual_risk^3

******** 2SRI: 2nd stage
eststo model3: bootstrap: reg skewness $FAS $xvar $socio dry i.prov $res_r if region == "RRD"

eststo model4: bootstrap: reg skewness $FAS $xvar $socio dry i.prov $res_c if region == "CVN"

coefplot (model3, label(RRD)) (model4, label(CVN)), keep($FAS) replace
graph export $output/figure5_b.jpg, as(jpg) quality(100) replace

******** Figure 6: Seasonal heterogeneity ********
******** Productivity:Dry
probit FAS1 iv1 $xvar $socio dry i.prov if season == 1
predict yhat7
gen res7 = FAS1 - yhat7
probit FAS2 iv2 $xvar $socio dry i.prov if season == 1
predict yhat8
gen res8 = FAS2 - yhat8
probit FAS3 iv3 $xvar $socio dry i.prov if season == 1
predict yhat9
gen res9 = FAS3 - yhat9

eststo model5: bootstrap: reg ln_yield $FAS $xvar $socio dry i.prov $res_d if season == 1

******** Productivity:Wet
probit FAS1 iv1 $xvar $socio dry i.prov if season == 2
predict yhat10
gen res10 = FAS1 - yhat10
probit FAS2 iv2 $xvar $socio dry i.prov if season == 2
predict yhat11
gen res11 = FAS2 - yhat11
probit FAS3 iv3 $xvar $socio dry i.prov if season == 2
predict yhat12
gen res12 = FAS3 - yhat12

eststo model6: bootstrap: reg ln_yield $FAS $xvar $socio dry i.prov $res_w if season == 2

coefplot (model6, label(Wet)) (model5, label(Dry)), keep($FAS) replace
graph export $output/figure6_a.jpg, as(jpg) quality(100) replace

******** Downside risk
******** 2SRI: 2nd stage
eststo model7: bootstrap: reg skewness $FAS $xvar $socio dry i.prov $res_d if season == 1

eststo model8: bootstrap: reg skewness $FAS $xvar $socio dry i.prov $res_w if season == 2
coefplot (model8, label(Wet)) (model7, label(Dry)) , keep($FAS) replace
graph export $output/figure6_b.jpg, as(jpg) quality(100) replace

******** Table 4: perception ********
eststo model9: reg FAS1 m_stress5 m_stress1  m_stress4 m_stress3 m_ins_rttrain m_ins_rt_cgvt m_ins_rt_lgvt $socio i.prov, robust
qui estadd local prov "Yes"
qui estadd local hh "Yes"

eststo model10: reg FAS2 m_stress5 m_stress1  m_stress4 m_stress3 m_ins_cpacc winfo1 winfo6 winfo8 winfo9 winfo10 $socio i.prov, robust
qui estadd local prov "Yes"
qui estadd local hh "Yes"

eststo model11: reg FAS3 m_stress5 m_stress1 m_stress4 m_stress3 $socio i.prov, robust
qui estadd local prov "Yes"
qui estadd local hh "Yes"

******** table 
esttab model9 model10 model11 ///
	using $output\table4.csv, ///
	se label nogap nonotes nomtitles b(%4.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	s(prov hh r2 N, fmt(%9.3f %9.3f %9.3f %9.0g) ///
	labels("Province FE" "Household characteristics" "R squared" "Observations")) ///
	order(m_stress5 m_stress1 m_stress4 m_stress3 m_ins_rttrain m_ins_rt_cgvt m_ins_rt_lgvt m_ins_cpacc winfo1 winfo6 winfo8 winfo9 winfo10) ///
  replace
estimates drop model9 model10 model11

******** Figure 4: perception ********
set scheme cleanplots, perm
graph hbar (mean) m_stress5 m_stress1 m_stress4 m_stress3 m_stress6 m_stress7, ///
	ylabel(0(0.2)1.0) over(region) ///
	bargap(-10) ///
	legend(order(1 "Heat" 2 "Flood" 3 "Drought" 4 "Salinity" 5 "Sea-level rise" 6 "None") col(3) position(6))
graph export $output/figure4.jpg, as(jpg) name("Graph") quality(100) replace

******** Figure 4: perception ********
use data_analysis, clear 
global FAS "FAS1 FAS2 FAS3"
global res "res1 res2 res3"
global xvar "ln_seed ln_labor ln_tfert"
global socio "hh_age hhschl hhyrfarm tothsz"

* 2SRI: 1st stage
eststo model01: probit FAS1 iv1 $xvar $socio dry i.prov
qui estadd local prov "Yes"

eststo model02: probit FAS2 iv2 $xvar $socio dry i.prov
qui estadd local prov "Yes"

eststo model03: probit FAS3 iv3 $xvar $socio dry i.prov
qui estadd local prov "Yes"

esttab model01 model02 model03 ///
	using $output\tableA1.csv, ///
	se label nogap nonotes nomtitles b(%4.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	s(prov N, fmt(%9.3f %9.0g) ///
	labels("Province FE"  "Observations")) ///
	order(iv1 iv2 iv3) ///
	mgroups("FAS1" "FAS2" "FAS3", pattern(1 0 1 0 1 0) span)  replace
estimates drop model01 model02 model03