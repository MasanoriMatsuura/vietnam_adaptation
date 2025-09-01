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
esttab CVN1 RRD1 Diff1 using $output\table1_1.csv, ///
	label nogap nonotes nomtitle nonumber b(%4.3f) ///
	cells("mean(pattern(1 1 0) fmt(3)) sd(pattern(1 1 0) fmt(3)) b(star pattern(0 0 1) fmt(3)) se(pattern(0 0 1) fmt(3)) ") ///
	mgroups("CVN" "RRD" "Difference", pattern(1 1 0)) replace
	
esttab CVN2 RRD2 Diff2 using $output\table1_2.csv, ///
	label nogap nonotes nomtitle nonumber ///
	cells("mean(pattern(1 1 0) fmt(3)) sd(pattern(1 1 0) fmt(3)) b(star pattern(0 0 1) fmt(3)) se(pattern(0 0 1) fmt(3)) ") ///
	mgroups("CVN" "RRD" "Difference", pattern(1 1 0)) replace
estimates drop CVN1 RRD1 Diff1 CVN2 RRD2 Diff2


******** Regression: adaptation and production ********
global xvar "ln_seed ln_labor ln_tfert"
foreach x in ln_seed ln_labor ln_tfert {
gen `x'_sq = `x'*`x'
}
gen ln_seed_labor = ln_seed*ln_labor
gen ln_seed_fert = ln_seed*ln_tfert
gen ln_labor_fert = ln_labor*ln_tfert
global xvar2 "ln_seed ln_labor ln_tfert ln_seed_sq ln_labor_sq ln_tfert_sq ln_seed_labor ln_seed_fert ln_labor_fert"
global socio "hh_age hhschl hhyrfarm tothsz"

* variables: IV
for num 1/3: bysort village: egen ivX = sum(FASX)
bysort village: egen n_vil = count(FAS1)
drop if n_vil < 10
for num 1/3: replace ivX = ivX - 1 if FASX == 1
for num 1/3: replace ivX = ivX/(n_vil - 1)

* OLS 
regress ln_yield FAS1 $xvar $socio irrig dry $vil_dum
regress ln_yield FAS2 $xvar $socio irrig dry $vil_dum
regress ln_yield FAS3 $xvar $socio irrig dry $vil_dum

* 2SLS
eststo model1a: ivregress 2sls ln_yield (FAS1 = iv1 ) $xvar irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "No"
eststo model1b: ivregress 2sls ln_yield (FAS1 = iv1 ) $xvar $socio irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "Yes"

eststo model2a: ivregress 2sls ln_yield (FAS2 = iv2 ) $xvar irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "No"
eststo model2b: ivregress 2sls ln_yield (FAS2 = iv2 ) $xvar $socio irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "Yes"

eststo model3a: ivregress 2sls ln_yield (FAS3 = iv3 ) $xvar irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "No"
eststo model3b: ivregress 2sls ln_yield (FAS3 = iv3 ) $xvar $socio irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "Yes"

eststo model4a: ivregress 2sls ln_yield (FAS1 FAS2 FAS3 = iv1 iv2 iv3) ///
	$xvar irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "No"
eststo model4b: ivregress 2sls ln_yield (FAS1 FAS2 FAS3 = iv1 iv2 iv3) ///
	$xvar $socio irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "Yes"

ivregress 2sls ln_yield (FAS1 = iv1 ) $xvar2 $socio dry i.prov if irrig == 0
ivregress 2sls ln_yield (FAS2 = iv2 ) $xvar2 $socio dry i.prov if irrig == 0
ivregress 2sls ln_yield (FAS3 = iv3 ) $xvar2 $socio dry i.prov if irrig == 0
ivregress 2sls ln_yield (FAS1 = iv1 ) $xvar2 $socio dry i.prov if irrig == 1
ivregress 2sls ln_yield (FAS2 = iv2 ) $xvar2 $socio dry i.prov if irrig == 1
ivregress 2sls ln_yield (FAS3 = iv3 ) $xvar2 $socio dry i.prov if irrig == 1

* table
esttab model1a model1b model2a model2b model3a model3b model4a model4b ///
	using $output\table3.csv, ///
	se label nogap nonotes nomtitles b(%4.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	s(prov hh N, fmt(%9.3f %9.3f %9.0g) ///
	labels("Province FE" "Household characteristics" "R squared" "Observations")) ///
	keep(FAS1 FAS2 FAS3 $xvar irrig dry _cons) ///
	order(FAS1 FAS2 FAS3)  replace
estimates drop model1a model1b model2a model2b model3a model3b model4a model4b

******** Regression: adaptation and downside risk ********
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
eststo model02: reg skewness $FAS $xvar dry

* 2SLS
eststo model1a: ivregress 2sls skewness (FAS1 = iv1 ) $xvar irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "No"
eststo model1b: ivregress 2sls skewness (FAS1 = iv1 ) $xvar $socio irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "Yes"

eststo model2a: ivregress 2sls skewness (FAS2 = iv2 ) $xvar irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "No"
eststo model2b: ivregress 2sls skewness (FAS2 = iv2 ) $xvar $socio irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "Yes"

eststo model3a: ivregress 2sls skewness (FAS3 = iv3 ) $xvar irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "No"
eststo model3b: ivregress 2sls skewness (FAS3 = iv3 ) $xvar $socio irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "Yes"

eststo model4a: ivregress 2sls skewness (FAS1 FAS2 FAS3 = iv1 iv2 iv3) ///
	$xvar irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "No"
eststo model4b: ivregress 2sls skewness (FAS1 FAS2 FAS3 = iv1 iv2 iv3) ///
	$xvar $socio irrig dry $vil_dum
qui estadd local prov "Yes"
qui estadd local hh "Yes"


* Falcification test
eststo fal1: reg ln_yield iv1 $xvar i.season i.com if ccstrat1 == 0
eststo fal2: reg ln_yield iv2 $xvar i.season i.com if ccstrat2 == 0
eststo fal3: reg ln_yield iv6 $xvar i.season i.prov if ccstrat6 == 0
eststo fal4: reg skewness iv1 $xvar i.season i.com if ccstrat1 == 0
eststo fal5: reg skewness iv2 $xvar i.season i.prov if ccstrat2 == 0
eststo fal6: reg skewness iv6 $xvar i.season i.prov if ccstrat6 == 0

* table
esttab model1a model1b model2a model2b model3a model3b model4a model4b ///
	using $output\table4.csv, ///
	se label nogap nonotes nomtitles b(%4.3f) star(* 0.10 ** 0.05 *** 0.01) ///
	s(prov hh N, fmt(%9.3f %9.3f %9.0g) ///
	labels("Province FE" "Household characteristics" "R squared" "Observations")) ///
	keep(FAS1 FAS2 FAS3 $xvar irrig dry _cons) ///
	order(FAS1 FAS2 FAS3)  replace
estimates drop model1a model1b model2a model2b model3a model3b model4a model4b

******** Figure: perception ********
set scheme cleanplots, perm
graph hbar (mean) m_stress5 m_stress1 m_stress4 m_stress3 m_stress6 m_stress7, ///
	ylabel(0(0.2)1.0) ///
	bargap(10) title("Climate stress in the area") ///
	legend(order(1 "Heat" 2 "Flood" 3 "Drought" 4 "Salinity" 5 "Sea-level rise" 6 "None") col(3) position(6))
graph export $output/perception.jpg, as(jpg) name("Graph") quality(100) replace
gen province2 = 1
replace province2 = 2 if province == "Nam Dinh"
replace province2 = 3 if province == "Ha Tinh"
replace province2 = 4 if province == "Quang Ngai"
label define province2 1 "Thai Binh (RRD)" 2 "Nam Dinh (RRD)" 3 "Ha Tinh (CVN)" 4 "Quang Ngai (CVN)"
label values province2 province2
graph hbar (mean) m_stress5 m_stress1 m_stress4 m_stress3 m_stress6 m_stress2, ///
	ylabel(0(0.2)1.0) over(province2) ///
	bargap(-10) title("Climate stress in the area") ///
	legend(order(1 "Heat" 2 "Flood" 3 "Drought" 4 "Salinity" 5 "Sea-level rise" 6 "Storm") col(3) position(6))


graph hbar (mean) temp1 temp2 temp6 temp5, ylabel(0(0.2)0.8) over(province2) ///
	bargap(-10) title("Change in temprature") name(g1, replace) ///
	legend(order(1 "Increase" 2 "Decrease" 3 "Irregular change" 4 "None") col(4) position(6))
graph hbar (mean) rain4 rain3 rain6 rain5, ylabel(0(0.2)0.8) over(province2) ///
	bargap(-10) title("Change in rainfall") name(g2, replace) ///
	legend(order(1 "High" 2 "Low" 3 "Irregular change" 4 "None") col(4) position(6)) 
graph hbar (mean) drought4 drought3 drought6 drought5, ylabel(0(0.2)0.8) over(province2) ///
	bargap(-10) title("Change in drought frequency") name(g3, replace) ///
	legend(order(1 "High" 2 "Low" 3 "Irregular change" 4 "None") col(4) position(6)) 
graph hbar (mean) flood1 flood2 flood6 flood4, ylabel(0(0.2)0.8) over(province2) ///
	bargap(-10) title("Change in flood frequency") name(g4, replace) ///
	legend(order(1 "Frequent" 2 "Less frequent" 3 "Irregular change" 4 "None") col(4) position(6))
grc1leg g1 g2 g3 g4
graph export $output/figure/perception2.jpg, as(jpg) name("Graph") quality(100) replace
