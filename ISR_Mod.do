** 4.1 ISR PF + PM **
timer on 94
local fecha : di %td_CY-N-D  date("$S_DATE", "DMY")
local anio = substr(`"`=trim("`fecha'")'"',1,4) // 								<-- anio base: HOY
noisily di _newline(2) in g "   MODULO: " in y "ISR"



*******************
* Microsimulacion *
use if anio == `anio' | anio == 2018 using "`c(sysdir_personal)'/users/$pais/$id/PIB.dta", clear
local lambda = lambda[1]
local deflator = deflator[1]
scalar PIB = pibY[_N]


* Verificar limites *
forvalues k=2(1)11 {
	matrix ISR[`k',1] = ISR[`=`k'-1',2]+.01
	if ISR[`k',1] >= ISR[`k',2] {
		matrix ISR[`k',2] = ISR[`k',1]+.01
	}
	matrix ISR[`k',3] = (ISR[`=`k'-1',2] - ISR[`=`k'-1',1])*ISR[`=`k'-1',4]/100 + ISR[`=`k'-1',3]
}
forvalues k=2(1)12 {
	matrix SE[`k',1] = SE[`=`k'-1',2]+.01
	if SE[`k',1] >= SE[`k',2] {
		matrix SE[`k',2] = SE[`k',1]+.01
	}
}
local smdf = 141.7																// Salario minimo general


* Households *
use `"`c(sysdir_personal)'/users/$pais/$id/households.dta"', clear
replace ing_bruto_tax = ing_bruto_tax/(`lambda'*`deflator')
*replace ing_capital = ing_capital*25.438/28.491 //(`lambda'*`deflator')


* Cuotas a la Seguridad Social IMSS *
tabstat cuotasTP [fw=factor_cola] if formal2 == 1, stat(sum) f(%25.0fc) save
tempname cuotasTP
matrix `cuotasTP' = r(StatTotal)

replace cuotasTP = cuotasTP*(scalar(CuotasT)/100*scalar(PIB))/`cuotasTP'[1,1] if formal2 == 1
replace cuotasTPF = cuotasF + cuotasTP


**************************
** CALCULO DE ISR FINAL **
capture g ISR0 = ISR
capture g ISR__asalariados0 = ISR__asalariados

replace ISR = 0
replace ISR__asalariados = 0
replace ISR__PF = 0
replace ISR__PM = 0

label var ISR "ISR (f{c i'}sicas y asalariados)"

* Deducciones personales y gastos profesionales *
*noisily di _newline _col(04) in g "{bf:3.3. Deducciones personales y gastos profesionales}"
*noisily di _newline _col(04) in g "{bf:SUPUESTO: " in y "Las deducciones personales son beneficios para el jefe del hogar.}"

* Limitar deducciones *
replace deduc_isr = `=DED[1,1]'*`smdf'*365 ///
	if `=DED[1,1]'*`smdf'*365 <= `=DED[1,2]'/100*(ing_bruto_tax) & deduc_isr >= `=DED[1,1]'*`smdf'*365
replace deduc_isr = `=DED[1,2]'/100*(ing_bruto_tax) ///
	if `=DED[1,1]'*`smdf'*365 >= `=DED[1,2]'/100*(ing_bruto_tax) & deduc_isr >= `=DED[1,2]'/100*(ing_bruto_tax)

replace categF = ""
forvalues j=`=rowsof(ISR)'(-1)1 {
	forvalues k=`=rowsof(SE)'(-1)1 {
		replace categF = "J`j'K`k'" ///
			if (ing_bruto_tax - exen_tot - deduc_isr - cuotasTPF) >= ISR[`j',1] ///
			 & (ing_bruto_tax - exen_tot - deduc_isr - cuotasTPF) <= ISR[`j',2] ///
			 & (ing_bruto_tax - exen_tot - deduc_isr - cuotasTPF) >= SE[`k',1] ///
			 & (ing_bruto_tax - exen_tot - deduc_isr - cuotasTPF) <= SE[`k',2] ///
			 //& formal != 0

		replace ISR = ISR[`j',3] + (ISR[`j',4]/100)*(ing_bruto_tax - exen_tot - deduc_isr - cuotasTPF - ISR[`j',1]) ///
			- SE[`k',3]*htrab/48 if categF == "J`j'K`k'" /*& formal != 0*/ & htrab < 48 & ing_t4_cap1 > 0
		replace ISR = ISR[`j',3] + (ISR[`j',4]/100)*(ing_bruto_tax - exen_tot - deduc_isr - cuotasTPF - ISR[`j',1]) ///
			- SE[`k',3] if categF == "J`j'K`k'" /*& formal != 0*/ & htrab >= 48 & ing_t4_cap1 > 0
		replace ISR = ISR[`j',3] + (ISR[`j',4]/100)*(ing_bruto_tax - exen_tot - deduc_isr - cuotasTPF - ISR[`j',1]) ///
			if categF == "J`j'K`k'" /*& formal != 0*/ & ((ing_t4_cap1 == 0 & ing_bruto_tax > 0) | htrab == . | htrab == 0)
	}
}

capture g TE = ISR/(ing_bruto_tax - exen_tot - deduc_isr - cuotasTPF)
if _rc != 0 {
	replace TE = ISR/(ing_bruto_tax - exen_tot - deduc_isr - cuotasTPF)
}
replace TE = 0 if TE == .


***********************
* FORMALIDAD SALARIOS *
replace formal_asalariados = 0
replace formal_asalariados = 1 //if prop_formal <= (1-DED[1,4]/100)

* ISR SALARIOS + SUBSIDIO AL EMPLEO *
replace ISR__asalariados = ISR /*3.491/3.232*3.491/2.611*/ if formal_asalariados == 1
replace ISR__asalariados = 0 if ISR__asalariados == .
label var ISR__asalariados "ISR (retenciones por salarios)"


************************
* ISR PERSONAS FISICAS *
replace formal_fisicas = 0
replace formal_fisicas = 1 if prop_formal <= (1-DED[1,3]/100)
replace ISR__PF = ISR - ISR__asalariados /*0.195/0.186*0.227/0.469*/ if ISR - ISR__asalariados > 0 & ISR > 0 & formal_fisicas == 1
replace ISR__PF = 0 if ISR__PF == .
label var ISR__PF "ISR (personas f{c i'}sicas)"


**********************
* FORMALIDAD MORALES *
replace formal_morales = 0
replace formal_morales = 1 if prop_formal <= (1-PM[1,2]/100)

* ISR PERSONAS MORALES *
replace ISR__PM = (ing_t2_cap1+ing_t2_cap8)*PM[1,1]/100 // *3.839/3.840			// 0.31353561: Ahorro bruto de Sociedad e ISFLSH
replace ISR__PM = 0 if ISR__PM == .
label var ISR__PM "ISR (personas morales)"

replace ISR = ISR__asalariados + ISR__PF + ISR__PM

* Results *
tabstat ISR__PF [fw=factor_cola] if formal_fisicas == 1, stat(sum) f(%25.2fc) save
tempname SIMTAX
matrix `SIMTAX' = r(StatTotal)

tabstat ISR__PM [fw=factor_cola] if formal_morales == 1, stat(sum) f(%25.2fc) save
tempname SIMTAXM
matrix `SIMTAXM' = r(StatTotal)

tabstat ISR__asalariados [fw=factor_cola] if formal_asalariados == 1, stat(sum) f(%25.2fc) save
tempname SIMTAXS
matrix `SIMTAXS' = r(StatTotal)

tabstat ing_capital gasto_anualDepreciacion [fw=factor_cola], stat(sum) f(%25.2fc) save
tempname SIMTAXT
matrix `SIMTAXT' = r(StatTotal)

scalar ISR_AS_Mod = `SIMTAXS'[1,1]/scalar(PIB)*100 								// ISR (asalariados)
scalar ISR_PF_Mod = `SIMTAX'[1,1]/scalar(PIB)*100 								// ISR (personas f{c i'}sicas)
scalar ISR_PM_Mod = `SIMTAXM'[1,1]/scalar(PIB)*100 								// ISR (personas morales)

noisily di _newline in g " RESULTADOS ISR (salarios): " _col(29) in y %10.3fc ISR_AS_Mod
noisily di in g " RESULTADOS ISR (f{c i'}sicas):  " _col(29) in y %10.3fc ISR_PF_Mod
noisily di in g " RESULTADOS ISR (morales):  " _col(29) in y %10.3fc ISR_PM_Mod

noisily di _newline in g " INGRESO CAPITAL:  " _col(29) in y %10.3fc `SIMTAXT'[1,1]/scalar(PIB)*100
noisily di in g " DEPRECIACION CAPITAL:  " _col(29) in y %10.3fc `SIMTAXT'[1,2]/scalar(PIB)*100

tabstat cuotasTP [fw=factor_cola] if formal2 == 1, stat(sum) f(%25.2fc) save
tempname SIMCSS
matrix `SIMCSS' = r(StatTotal)
scalar CuotasT = `SIMCSS'[1,1]/scalar(PIB)*100 //								Cuotas IMSS



* SIMULACI{c O'}N: Impuesto al ingreso laboral *
drop Laboral
egen Laboral = rsum(ISR__asalariados ISR__PF cuotasTP) if formal != 0
replace Laboral = 0 if Laboral == .
label var Laboral "los impuestos al ingreso laboral"

*noisily Simulador Laboral [fw=factor_cola], base("ENIGH 2018") boot(1) reboot $nographs nooutput
*noisily Simulador ISR__PM if ISR__PM != 0 [fw=factor], base("ENIGH 2018") boot(1) reboot $nographs nooutput

save `"`c(sysdir_personal)'/users/$pais/$id/households.dta"', replace




************************/
**** Touchdown!!! :) ****
*************************
timer off 94
timer list 94
noisily di _newline(2) in g _dup(20) "." "  " in y round(`=r(t94)/r(nt94)',.1) in g " segs  " _dup(20) "."

