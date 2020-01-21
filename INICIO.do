**************************
**** HOLA, HUMANO! :) ****
**************************
clear all
macro drop _all
capture log close _all
set scheme ciepnew
timer on 1




*****************
*** 0. Github ***
*****************
if "`c(os)'" == "Unix" {
	cd "/home/ciepmx/Dropbox (CIEP)/Simulador v5/Github/simuladorCIEP"
	sysdir set PERSONAL "/home/ciepmx/Dropbox (CIEP)/Simulador v5/Github/simuladorCIEP"
	*global export "/home/ciepmx/Dropbox (CIEP)/Simulador v5/Textbook/images/"
}
if "`c(os)'" == "MacOSX" {
	cd "/Users/ricardo/Dropbox (CIEP)/Simulador v5/Github/simuladorCIEP"
	sysdir set PERSONAL "/Users/ricardo/Dropbox (CIEP)/Simulador v5/Github/simuladorCIEP"
	*global export "/Users/ricardo/Dropbox (CIEP)/Simulador v5/Textbook/images/"
}
adopath ++ PERSONAL



******************
** 0.1 Globales **
global pib2022 = 4.5
global discount = 3.0

global pais = "ElSalvador"




********************
***              ***
*** 1. POBLACIÓN ***
***              ***
********************
noisily Poblacion, g anio(2018) //update




*************************************************/
***                                            ***
*** 2. Capítulo 2: Las tres caras de la moneda ***
***                                            ***
***               ACTUALIZACIÓN                *** 
*** 1) abrir archivos .iqy en Excel de Windows ***
*** 2) guardar y reemplazar .xls dentro de     ***
***      ./TemplateCIEP/basesCIEP/INEGI/SCN/   ***
*** 3) correr SCN con opción "update"          ***
***                                            ***
**************************************************
if "$pais" == "" {
	noisily SCN, graphs //update
}
else {
	noisily PIBDeflactor, g aniovp(2018) //update
}




*********************************************************/
***                                                    ***
*** 3. Capítulo 3: La economía-sistema antropocéntrica ***
***                                                    ***
**********************************************************
*noisily run Income.do 2018
use "`c(sysdir_site)'../basesCIEP/SIM/`enighanio'/income.dta", clear
Simulador ing_laboral if ing_laboral != 0 [fw=factor], anio(2018) noisily graphs







exit
*noisily run Expenditure.do 2018
*noisily Sankey escol sexo grupo_edad rural formalmax decil ///
	using "`c(sysdir_site)'../basesCIEP/SIM/2018/income.dta", ///
	anio(2018) profile(Poblacion)

	
use "`c(sysdir_site)'../basesCIEP/SIM/2018/income.dta", clear
rename Depreciacion ing_Depreciacion
collapse (sum) ing_laboral ing_capital ing_Depreciacion, by(escol)

tempvar cuenta
reshape long ing_, i(escol) j(`cuenta') string
encode `cuenta', g(cuenta)

rename escol from
rename cuenta to
rename ing_ profile

tempfile eje1
save `eje1'


use "`c(sysdir_site)'../basesCIEP/SIM/2018/income.dta", clear
rename Depreciacion ing_Depreciacion
collapse (sum) ing_laboral ing_capital ing_Depreciacion, by(sexo)

tempvar cuenta
reshape long ing_, i(sexo) j(`cuenta') string
encode `cuenta', g(cuenta)

rename cuenta from
rename sexo to
rename ing_ profile

tempfile eje2
save `eje2'


use "`c(sysdir_site)'../basesCIEP/SIM/2018/income.dta", clear
collapse (sum) ing_honor ing_sueldos, by(sexo)
tempvar cuenta
reshape long ing_, i(sexo) j(`cuenta') string
encode `cuenta', g(cuenta)

rename sexo from
rename cuenta to
rename ing_ profile

tempfile eje3
save `eje3'


use "`c(sysdir_site)'../basesCIEP/SIM/2018/income.dta", clear
collapse (sum) ing_honor ing_sueldos, by(escol)
tempvar cuenta
reshape long ing_, i(escol) j(`cuenta') string
encode `cuenta', g(cuenta)

rename cuenta from
rename escol to
rename ing_ profile

tempfile eje4
save `eje4'




noisily SankeySum, a(`eje1') b(`eje2') c(`eje3') d(`eje4') cycle


exit



*********************/
*** 4. Touch Down! ***
**********************
*noisily scalarlatex
timer off 1
timer list 1
noisily di _newline in g _dup(55) "+" in y round(`=r(t1)/r(nt1)',.1) in g " segs." _dup(55) "+" _newline(5)













***************************/
*** 2. Finanzas públicas ***
/****************************
noisily LIF, graphs 				//update
noisily PEF, graphs 				//update
noisily Balance, graphs
noisily SHRFSP, graphs 				//`update'



Poblacion, graphs																// update (downloads dataset again)
Poblacion defunciones, graphs 													// update (downloads dataset again)


*noisily Eficiencia, reboot graphs noisily update
*noisily TransfNetas, graphs update




**********************/
*** 3. Simulaciones ***
/***********************
local id "MexTax"
capture mkdir "`c(sysdir_personal)'/users/`id'/"
capture log using "`c(sysdir_personal)'/users/`id'/log `c(current_date)'", replace
noisily di _newline(5) in g _dup(50) "+" in y "$simuladorCIEP. (ID: `id'): `c(current_date)' `c(current_time)'" in g _dup(50) "+"



************
************
** Gastos **

* Educaci${o}n *
scalar sbasica = 1.993								// Educaci${o}n b${a}sica
scalar smedias = 0.410								// Educaci${o}n media superior
scalar ssuperi = 0.521								// Educaci${o}n superior
scalar sposgra = 0.033								// Posgrado

* Pensiones *
scalar spam    = 0.172								// Pensi${o}n para adultos mayores
scalar spenims = 1.678								// Pensi${o}n IMSS
scalar speniss = 0.901								// Pensi${o}n ISSSTE
scalar spenpem = 0.278								// Pensi${o}n Pemex
scalar spencfe = 0.168								// Pensi${o}n CFE
scalar spenlfc = 0.426								// Pensi${o}n LFC, ISSFAM, Otros

* Salud *
scalar sssa    = 0.212								// SSalud
scalar ssegpop = 0.706								// Seguro Popular
scalar simss   = 1.205								// IMSS (salud)
scalar sissste = 0.239								// ISSSTE (salud)
scalar sprospe = 0.052								// IMSS-Prospera
scalar spemex  = 0.097								// Pemex (salud)

* Extras *
scalar singbas = 0.000								// Ingreso b${a}sico	
scalar pamgeneral = 1								// PAM general
scalar ivageneral = 1								// IVA general
scalar ingbasico18 = 1								// Ingreso b${a}sico a menores de 18 a${ni}os
scalar ingbasico65 = 1								// Ingreso b${a}sico a mayores de 65 a${ni}os

* Otros gastos *
scalar servpers = 1.813								// Servicios personales
scalar matesumi = 0.933								// Materiales y suministros
scalar gastgene = 0.853								// Gastos generales
scalar substran = 1.455								// Subsidios y transferencias
scalar bienmueb = 0.196								// Bienes muebles e inmuebles
scalar obrapubl = 1.265								// Obras p${u}blicas
scalar invefina = 0.094								// Inversi${o}n financiera
scalar partapor = 4.428								// Participaciones y aportaciones
scalar deudpubl = 2.890								// Deuda p${u}blica



**************
** Ingresos **
**************

* Al ingreso *
scalar sISR__as = 2.901								// ISR (asalariados)
scalar sISR__PF = 0.402								// ISR (personas f${i}sicas)
scalar sCuotasT = 1.345								// Cuotas (IMSS)

* Al consumo *
scalar sIVA     = 3.813 							//+2.901+0.402+1.345+.709+1.125+.046+.206+2.3+(singbas*.24*(1-.06608))+(spam*.24*(1-.06608))								// IVA
scalar sIEPS    = (0.709 + 1.125) 						// IEPS (no petrolero + petrolero)
scalar sISAN    = 0.046								// ISAN
scalar sImporta = 0.206								// Importaciones

* Al capital *
scalar sISR__PM = 3.508								// ISR (personas morales)
scalar sFMP_Der = 1.986								// Fondo Mexicano del Petr${o}leo
scalar sOYE     = (0.119 + 0.228 + 1.841 + 1.656)				// Organismos y empresas (IMSS + ISSSTE + Pemex + CFE)

*noisily TasaFairTax `=sIVA-((singbas*.24*(1-.06608))+(spam*.24*(1-.06608)))'




********************
** 3.1 Resultados **
global depreMXN = 0					// % de depreciaci${o}n (SHRFSP.ado)

run "`c(sysdir_personal)'/Modulos.do" `id' $anioVP
noisily Eficiencia, id(`id') graphs
*noisily TransfNetas, id(`id') graphs reboot //noisily
*noisily SHRFSP, id(`id') graphs

capture log close

