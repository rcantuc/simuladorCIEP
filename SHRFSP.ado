program define SHRFSP
quietly {


	timer on 5
	***********************
	*** 1 BASE DE DATOS ***
	***********************

	** 1.1 Anio valor presente **
	local fecha : di %td_CY-N-D  date("$S_DATE", "DMY")
	local aniovp = substr(`"`=trim("`fecha'")'"',1,4)

	** 1.2 Datos Abiertos (México) **
	if "$pais" == "" {
		UpdateDatosAbiertos
		local updated = r(updated)
		local ultanio = r(ultanio)
		local ultmes = r(ultmes)
	}
	else {
		local updated = "yes"
	}



	****************
	*** 2 SYNTAX ***
	****************
	syntax [if/] [, ANIO(int `aniovp' ) DEPreciacion(int 5) NOGraphs Update Base ID(string)]
	noisily di _newline(2) in g _dup(20) "." "{bf:  Sistema Fiscal: DEUDA $pais " in y `anio' "  }" in g _dup(20) "."

	** 2.1 Update SHRFSP **
	capture confirm file `"`c(sysdir_personal)'/SIM/$pais/SHRFSP.dta"'
	if ("`update'" == "update" | _rc != 0) & "$pais" != "" {
		noisily run `"`c(sysdir_personal)'/UpdateSHRFSPMundial.do"' `anio'
	}
	if ("`update'" == "update" | _rc != 0) & "$pais" == "" {
		noisily run `"`c(sysdir_personal)'/UpdateSHRFSP.do"'
	}

	** 2.2 PIB + Deflactor **
	*PIBDeflactor, anio(`anio') nographs nooutput
	use "`c(sysdir_personal)'/users/$pais/$id/PIB.dta", clear
	local currency = currency[1]
	tempfile PIB
	save `PIB'

	** 2.3 Base SHRFSP **
	use `"`c(sysdir_personal)'/SIM/$pais/SHRFSP.dta"', clear



	***************
	*** 3 Merge ***
	***************
	merge 1:1 (anio) using `PIB', nogen keepus(pibY pibYR var_*) update replace
	tsset anio

	** 3.1 NUEVOS par{c a'}metros ** 
	if "$pais" == "" {
		replace shrfsp = 51/100*pibY if anio == 2022
		replace shrfspInterno = 34.5/100*pibY if anio == 2022
		replace shrfspExterno = 16.5/100*pibY if anio == 2022
		replace rfsp = 3.5/100*pibY if anio == 2022
		replace rfspBalance = -3.1/100*pibY if anio == 2022
		replace rfspPIDIREGAS = -0.0/100*pibY if anio == 2022
		replace rfspIPAB = -0.1/100*pibY if anio == 2022
		replace rfspFONADIN = -0.0/100*pibY if anio == 2022
		replace rfspDeudores = 0.1/100*pibY if anio == 2022
		replace rfspBanca = -0.0/100*pibY if anio == 2022
		replace rfspAdecuacion = -0.4/100*pibY if anio == 2022
		replace tipoDeCambio = 20.4 if anio == 2022

		replace shrfsp = 51/100*pibY if anio == 2023
		replace shrfspInterno = 35.1/100*pibY if anio == 2023
		replace shrfspExterno = 15.9/100*pibY if anio == 2023
		replace rfsp = 3.2/100*pibY if anio == 2023
		replace rfspBalance = -2.7/100*pibY if anio == 2023
		replace rfspPIDIREGAS = -0.0/100*pibY if anio == 2023
		replace rfspIPAB = -0.1/100*pibY if anio == 2023
		replace rfspFONADIN = -0.0/100*pibY if anio == 2023
		replace rfspDeudores = 0.0/100*pibY if anio == 2023
		replace rfspBanca = -0.0/100*pibY if anio == 2023
		replace rfspAdecuacion = -0.4/100*pibY if anio == 2023
		replace tipoDeCambio = 20.6 if anio == 2023

		replace shrfsp = 51/100*pibY if anio == 2024
		replace shrfspInterno = 35.5/100*pibY if anio == 2024
		replace shrfspExterno = 15.5/100*pibY if anio == 2024
		replace rfsp = 2.9/100*pibY if anio == 2024
		replace rfspBalance = -2.4/100*pibY if anio == 2024
		replace rfspPIDIREGAS = -0.0/100*pibY if anio == 2024
		replace rfspIPAB = -0.1/100*pibY if anio == 2024
		replace rfspFONADIN = -0.0/100*pibY if anio == 2024
		replace rfspDeudores = 0.0/100*pibY if anio == 2024
		replace rfspBanca = -0.0/100*pibY if anio == 2024
		replace rfspAdecuacion = -0.4/100*pibY if anio == 2024
		replace tipoDeCambio = 20.8 if anio == 2024

		replace shrfsp = 51/100*pibY if anio == 2025
		replace shrfspInterno = 36.0/100*pibY if anio == 2025
		replace shrfspExterno = 15.0/100*pibY if anio == 2025
		replace rfsp = 2.8/100*pibY if anio == 2025
		replace rfspBalance = -2.3/100*pibY if anio == 2025
		replace rfspPIDIREGAS = -0.0/100*pibY if anio == 2025
		replace rfspIPAB = -0.1/100*pibY if anio == 2025
		replace rfspFONADIN = -0.0/100*pibY if anio == 2025
		replace rfspDeudores = 0.0/100*pibY if anio == 2025
		replace rfspBanca = -0.0/100*pibY if anio == 2025
		replace rfspAdecuacion = -0.4/100*pibY if anio == 2025
		replace tipoDeCambio = 20.9 if anio == 2025

		replace shrfsp = 51/100*pibY if anio == 2026
		replace shrfspInterno = 36.5/100*pibY if anio == 2026
		replace shrfspExterno = 14.5/100*pibY if anio == 2026
		replace rfsp = 2.8/100*pibY if anio == 2026
		replace rfspBalance = -2.3/100*pibY if anio == 2026
		replace rfspPIDIREGAS = -0.0/100*pibY if anio == 2026
		replace rfspIPAB = -0.1/100*pibY if anio == 2026
		replace rfspFONADIN = -0.0/100*pibY if anio == 2026
		replace rfspDeudores = 0.0/100*pibY if anio == 2026
		replace rfspBanca = -0.0/100*pibY if anio == 2026
		replace rfspAdecuacion = -0.4/100*pibY if anio == 2026
		replace tipoDeCambio = 21.0 if anio == 2026

		replace shrfsp = 51/100*pibY if anio == 2027
		replace shrfspInterno = 36.9/100*pibY if anio == 2027
		replace shrfspExterno = 14.1/100*pibY if anio == 2027
		replace rfsp = 2.8/100*pibY if anio == 2027
		replace rfspBalance = -2.3/100*pibY if anio == 2027
		replace rfspPIDIREGAS = -0.0/100*pibY if anio == 2027
		replace rfspIPAB = -0.1/100*pibY if anio == 2027
		replace rfspFONADIN = -0.0/100*pibY if anio == 2027
		replace rfspDeudores = 0.1/100*pibY if anio == 2027
		replace rfspBanca = -0.0/100*pibY if anio == 2027
		replace rfspAdecuacion = -0.5/100*pibY if anio == 2027
		replace tipoDeCambio = 21.3 if anio == 2027

		g porInterno = shrfspInterno/shrfsp
		g porExterno = shrfspExterno/shrfsp

		replace costodeudaInterno = 2.8/100*porInterno*pibY if anio == 2022
		replace costodeudaExterno = 2.8/100*porExterno*pibY if anio == 2022
		replace costodeudaInterno = 3.0/100*porInterno*pibY if anio == 2023
		replace costodeudaExterno = 3.0/100*porExterno*pibY if anio == 2023
		replace costodeudaInterno = 3.0/100*porInterno*pibY if anio == 2024
		replace costodeudaExterno = 3.0/100*porExterno*pibY if anio == 2024
		replace costodeudaInterno = 3.0/100*porInterno*pibY if anio == 2025
		replace costodeudaExterno = 3.0/100*porExterno*pibY if anio == 2025
		replace costodeudaInterno = 3.0/100*porInterno*pibY if anio == 2026
		replace costodeudaExterno = 3.0/100*porExterno*pibY if anio == 2026
		replace costodeudaInterno = 3.1/100*porInterno*pibY if anio == 2027
		replace costodeudaExterno = 3.1/100*porExterno*pibY if anio == 2027
		
		replace nopresupuestario = 0 if anio >= 2022

		g tasaInterno = costodeudaInterno/shrfspInterno
		*replace tasaInterno = L.tasaInterno if tasaInterno == .
		g tasaExterno = costodeudaExterno/shrfspExterno
		*replace tasaExterno = L.tasaExterno if tasaExterno == .

		g balprimario = (-rfspBalance-costodeudaInterno-costodeudaExterno)/pibY*100
		g depreciacion = tipoDeCambio-L.tipoDeCambio
		g Depreciacion = tipoDeCambio/L.tipoDeCambio-1
		g tasaEfectiva = L.porInterno*tasaInterno + L.porExterno*tasaExterno

		replace balprimario = 0.3 if anio == 2022
		replace balprimario = -0.3 if anio == 2023
		replace balprimario = -0.6 if anio == 2024
		replace balprimario = -0.6 if anio == 2025
		replace balprimario = -0.7 if anio == 2026
		replace balprimario = -0.8 if anio == 2027

		g efectoIntereses = (tasaEfectiva/((1+var_pibY/100)*(1+var_indiceY/100)))*L.shrfsp/L.pibY*100 
		g efectoInflacion = (-(var_indiceY/100*(1+var_pibY/100))/((1+var_pibY/100)*(1+var_indiceY/100)))*L.shrfsp/L.pibY*100
		g efectoCrecimiento = (-(var_pibY/100)/((1+var_pibY/100)*(1+var_indiceY/100)))*L.shrfsp/L.pibY*100
		g efectoTipoDeCambio = ((L.porExterno*Depreciacion*(1+tasaExterno))/((1+var_pibY/100)*(1+var_indiceY/100)))*L.shrfsp/L.pibY*100
		g efectoOtros = -(rfspPIDIREGAS+rfspIPAB+rfspFONADIN+rfspDeudores+rfspBanca+rfspAdecuacion+nopresupuestario)/pibY*100
		g efectoTotal = efectoIntereses+efectoInflacion+efectoCrecimiento+efectoTipoDeCambio+efectoOtros+balprimario

		if "`nographs'" != "nographs" & "$nographs" == "" {
			local j = 100/(2027-2008+1)/2
			forvalues k=1(1)`=_N' {
				if efectoTotal[`k'] != . {
					local textDeuda `"`textDeuda' `=efectoTotal[`k']*0+.1' `j' "{bf:`=string(efectoTotal[`k'],"%5.1fc")'}""'
					local j = `j' + 100/(2027-2008+1)
				}
			}
			graph bar efectoIntereses efectoInflacion efectoCrecimiento balprimario efectoTipoDeCambio efectoOtros ///
				if Depreciacion != . & anio >= 2008, ///
				over(anio, gap(0)) stack blabel(, format(%5.1fc)) outergap(0) ///
				text(`textDeuda', color(black)) ///
				ytitle("% PIB") ///
				legend(on position(6) rows(1) label(1 "Tasas de inter{c e'}s") label(2 "Inflaci{c o'}n") label(3 "Crec. Econ{c o'}mico") ///
				label(4 "Balance Primario") label(5 "Tipo de cambio") label(6 "Otros") region(margin(zero))) ///
				title("Efectos sobre el {bf:Indicador de la Deuda}") ///
				name(efectoDeuda, replace) ///
				note("{bf:{c U'}ltimo dato}: `ultanio'm`ultmes'") ///
				caption("{bf:Fuente}: Elaborado con el Simulador Fiscal CIEP v5.")

			capture confirm existence $export
			if _rc == 0 {
				graph export "$export/efectoDeuda.png", replace name(efectoDeuda)
			}			
		}

		tabstat depreciacion if anio <= `anio' & anio >= `=`anio'-`depreciacion'+1', stat(sum) save
		tempname depre
		matrix `depre' = r(StatTotal)

		replace depreciacion = `depre'[1,1] if depreciacion == . & anio > `anio'

		tabstat depreciacion if anio <= `anio' & anio >= `=`anio'-`depreciacion'+1+1', stat(sum) save
		tempname deprea
		matrix `deprea' = r(StatTotal)

		tabstat depreciacion if anio <= `anio' & anio >= `=`anio'-`depreciacion'+1+2', stat(sum) save
		tempname depreb
		matrix `depreb' = r(StatTotal)

		tabstat depreciacion if anio <= `anio' & anio >= `=`anio'-`depreciacion'+1+3', stat(sum) save
		tempname deprec
		matrix `deprec' = r(StatTotal)

		tabstat depreciacion if anio <= `anio' & anio >= `=`anio'-`depreciacion'+1+4', stat(sum) save
		tempname depred
		matrix `depred' = r(StatTotal)

		noisily di _newline(2) in g "  {bf:Depreciaci{c o'}n acumulada}: " 
		noisily di in g "   `anio'-`=`anio'-`depreciacion'': " in y %7.3fc `depre'[1,1] in g " `currency'"
		noisily di in g "   `anio'-`=`anio'-`depreciacion'+1': " in y %7.3fc `deprea'[1,1] in g " `currency'"
		noisily di in g "   `anio'-`=`anio'-`depreciacion'+2': " in y %7.3fc `depreb'[1,1] in g " `currency'"
		noisily di in g "   `anio'-`=`anio'-`depreciacion'+3': " in y %7.3fc `deprec'[1,1] in g " `currency'"
		noisily di in g "   `anio'-`=`anio'-`depreciacion'+4': " in y %7.3fc `depred'[1,1] in g " `currency'"

	}

	foreach k of varlist shrfsp* {
		tempvar `k'
		g ``k'' = `k'/pibY*100
	}

	noisily di _newline in g _col(3) "A{c N~}O" _col(15) %10s "Interna" _col(25) %10s "Externa" _col(35) %10s "Total"
	forvalues k=1(1)`=_N' {
		if `shrfsp'[`k'] != . {
			noisily di in y _col(3) anio[`k'] ///
			%10.1fc _col(15) `shrfspInterno'[`k'] ///
			%10.1fc _col(25) `shrfspExterno'[`k'] ///
			%10.1fc _col(35) `shrfsp'[`k']
		}
	}



	***************
	*** 4 Graph ***
	***************	
	if "`nographs'" != "nographs" & "$nographs" == "" {
		tempvar interno externo rfspBalance rfspAdecuacion rfspOtros rfspBalance0 rfspAdecuacion0 rfspOtros0 rfsppib
		g `externo' = shrfspExterno/pibY*100
		g `interno' = `externo' + shrfspInterno/pibY*100
		
		g `rfspOtros0' = - rfspPIDIREGAS/pibY*100 - rfspIPAB/pibY*100 - rfspFONADIN/pibY*100 - rfspDeudores/pibY*100 - rfspBanca/pibY*100
		g `rfspAdecuacion0' = - rfspAdecuacion/pibY*100		
		g `rfspBalance0' = - rfspBalance/pibY*100

		g `rfspOtros' = - rfspPIDIREGAS/pibY*100 - rfspIPAB/pibY*100 - rfspFONADIN/pibY*100 - rfspDeudores/pibY*100 - rfspBanca/pibY*100
		
		g `rfspAdecuacion' = `rfspOtros' - rfspAdecuacion/pibY*100 if rfspAdecuacion <= 0
		replace `rfspAdecuacion' = - rfspAdecuacion/pibY*100 if rfspAdecuacion > 0
		replace `rfspAdecuacion' = 0 if `rfspAdecuacion' == .
		
		g `rfspBalance' = `rfspAdecuacion' - rfspBalance/pibY*100 if rfspAdecuacion <= 0 & `rfspOtros' >= 0
		replace `rfspBalance' = - rfspBalance/pibY*100 if rfspAdecuacion > 0 & `rfspOtros' < 0
		replace `rfspBalance' = `rfspOtros' - rfspBalance/pibY*100 if rfspAdecuacion > 0 & `rfspOtros' >= 0
		replace `rfspBalance' = `rfspAdecuacion' - `rfspOtros' - rfspBalance/pibY*100 if rfspAdecuacion <= 0 & `rfspOtros' < 0

		g `rfsppib' = rfsp/pibY*100

		local j = 100/(2027-2008+1)/2
		forvalues k=1(1)`=_N' {
			if `shrfsp'[`k'] != . & anio[`k'] >= 2003 {
				if "`anioshrfsp'" == "" {
					local anioshrfsp = anio[`k']
				}
				local text `"`text' `=`shrfsp'[`k']*1.005' `=anio[`k']' "{bf:`=string(`shrfsp'[`k'],"%5.1fc")'}""'
				local textI `"`textI' `=`interno'[`k']/2+`externo'[`k']/2' `=anio[`k']' "`=string(shrfspInterno[`k']/pibY[`k']*100,"%5.1fc")'""'
				local textE `"`textE' `=`externo'[`k']/2' `=anio[`k']' "`=string(shrfspExterno[`k']/pibY[`k']*100,"%5.1fc")'""'
			}

			if `rfsppib'[`k'] != . {
				local textRFSP `"`textRFSP' `=`rfsppib'[`k']*1.005' `=anio[`k']' "{bf:`=string(`rfsppib'[`k'],"%5.1fc")'}""'
				local textRFBa `"`textRFBa' `=`rfspBalance'[`k']/2+max(`rfspAdecuacion'[`k']/2,0)+max(`rfspOtros'[`k']/2,0)' `=anio[`k']' "{bf:`=string(`rfspBalance0'[`k'],"%5.1fc")'}""'
				if `rfspAdecuacion'[`k'] < 0 {
					local textRFAd `"`textRFAd' `=`rfspAdecuacion'[`k']/2+min(`rfspOtros'[`k']/2,0)' `=anio[`k']' "{bf:`=string(`rfspAdecuacion0'[`k'],"%5.1fc")'}""'
				}
				else {
					local textRFAd `"`textRFAd' `=`rfspAdecuacion'[`k']/2+max(`rfspOtros'[`k']/2,0)' `=anio[`k']' "{bf:`=string(`rfspAdecuacion0'[`k'],"%5.1fc")'}""'					
				}
				local textRFOt `"`textRFOt' `=`rfspOtros'[`k']/2' `=anio[`k']' "{bf:`=string(`rfspOtros0'[`k'],"%5.1fc")'}""'
				local j = `j' + 100/(2027-2008+1)
			}
		}

		twoway (bar `rfspBalance' `rfspAdecuacion' `rfspOtros' anio if anio < `anio', bstyle(p1bar p2bar p3bar)) ///
			(bar `rfspBalance' `rfspAdecuacion' `rfspOtros' anio if anio >= `anio', bstyle(p5bar p6bar p7bar)) if rfsp != ., ///
			title("{bf:Requerimientos financieros} del sector p{c u'}blico") ///
			subtitle($pais) xtitle("") ///
			name(rfsp, replace) ///
			ylabel(, format(%15.0fc) labsize(small)) ///
			xlabel(2008(1)2027, noticks) ///	
			yscale(range(0) axis(1) noline) ///
			text(`textRFSP', placement(n)) ///
			text(`textRFBa', color(white)) ///
			text(`textRFAd', color(white)) ///
			text(`textRFOt', color(white)) ///
			ytitle("% PIB") ///
			legend(on position(6) rows(1) label(3 "Otros") label(2 "Adecuaciones") label(1 "Balance presupuestario") ///
			label(6 "Proy. Otros") label(5 "Proy. Adecuaciones") label(4 "Proy. Balance presupuestario") region(margin(zero))) ///
			note("{bf:{c U'}ltimo dato}: `ultanio'm`ultmes'") ///
			caption("{bf:Fuente}: Elaborado por el CIEP, con informaci{c o'}n de la SHCP (Estadísticas Oportunas y Paquete Econ{c o'}mico 2022).")

		twoway (bar `interno' `externo' anio if anio < `anio') ///
			(bar `interno' `externo' anio if anio >= `anio') if `externo' != ., ///
			title("{bf:Saldo hist{c o'}rico} de RFSP") ///
			subtitle($pais) ///
			ylabel(, format(%15.0fc) labsize(small)) ///
			xlabel(`anioshrfsp'(1)2027, noticks) ///	
			text(`textE' `textI', color(white)) ///
			text(`text', placement(n)) ///
			///text(2 `=`anio'+1.45' "{bf:Proyecci{c o'}n PE 2022}", color(white)) ///
			///text(2 `=2003+.45' "{bf:Externo}", color(white)) ///
			///text(`=2+`externosize2003'' `=2003+.45' "{bf:Interno}", color(white)) ///
			yscale(range(0) axis(1) noline) ///
			ytitle("% PIB") xtitle("") ///
			legend(on position(6) rows(1) order(1 2 3 4) label(1 "Interno") label(2 "Externo") ///
			label(3 "Proy. Interno") label(4 "Proy. Externo") region(margin(zero))) ///
			name(shrfsp, replace) ///
			note("{bf:{c U'}ltimo dato}: `ultanio'm`ultmes'") ///
			caption("{bf:Fuente}: Elaborado por el CIEP, con informaci{c o'}n de la SHCP (Estadísticas Oportunas y PE 2022).")

		capture confirm existence $export
		if _rc == 0 {
			graph export "$export/RFSP.png", replace name(rfsp)
			graph export "$export/SHRFSP.png", replace name(shrfsp)
		}			
	}


	***********
	*** END ***
	***********
	capture drop __*
	timer off 5
	timer list 5
	noisily di _newline in g "{bf:Tiempo:} " in y round(`=r(t5)/r(nt5)',.1) in g " segs."

}
end


