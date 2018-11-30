program define PEF, return
quietly {




	************************
	*** 1. BASE DE DATOS ***
	************************
	capture use "`c(sysdir_site)'/bases/SIM/PEF.dta", clear
	local rc = _rc
	syntax [if] [, ANIO(int $anioVP) Graphs Update Base ID(string) ///
		BY(varname) Datosabiertos Fast ROWS(int 1) COLS(int 4) ///
		MINimum(real 1)]


	** Base PEF **
	if `rc' != 0 | "`update'" == "update" {
		noisily run "`c(sysdir_site)'/UpdatePEF.do" `update'
	}


	** Base ID **
	if "`id'" != "" {
		use "`c(sysdir_site)'/users/`id'/PEF", clear
	}

	noisily di _newline(5) in g "{bf:SISTEMA FISCAL: " in y "GASTOS `anio'}"

	if "`base'" == "base" {
		exit
	}

	if "`fast'" == "fast" {
		keep if anio == `anio'
	}

	if "`by'" == "" {
		local by = "desc_funcion"
	}




	**************
	*** 2. PIB ***
	**************
	preserve
	PIBDeflactor
	tempfile PIB
	save `PIB'
	restore

	merge m:1 (anio) using `PIB', nogen keepus(pibY indiceY deflator var_pibY) update replace keep(matched)
	foreach k of varlist gasto aprobado ejercido proyecto {
		g double `k'PIB = `k'/pibY*100
		g double `k'netoPIB = `k'neto/pibY*100
		format *PIB %10.3fc
	}


	************************************************
	** 2.1 Aportaciones y cuotas de la Federacion **
	capture tabstat gasto gastoPIB if anio == `anio' & neto == 1, stat(sum) f(%20.0fc) save
	tempname Aportaciones_Federacion
	matrix `Aportaciones_Federacion' = r(StatTotal)
	return scalar Aportaciones_Federacion = `Aportaciones_Federacion'[1,1]

	capture tabstat gasto gastoPIB if `by' == -1 & anio == `anio', stat(sum) f(%20.0fc) save
	tempname Cuotas_ISSSTE
	matrix `Cuotas_ISSSTE' = r(StatTotal)
	return scalar Cuotas_ISSSTE = `Cuotas_ISSSTE'[1,1]

	collapse (sum) gasto* aprobado* ejercido* proyecto* `if', by(`by' anio neto `varSerie' modulo) fast



	****************
	*** 3. Graph ***
	****************
	replace `by' = 999 if `by' == -2
	label define `by' 999 "Ingreso b{c a'}sico", add modify
	
	tempvar over
	g `over' = `by'

	tempname label
	label copy `by' `label'
	label values `over' `label'

	replace `over' = -99 if (abs(gastonetoPIB) < `minimum' | gastonetoPIB == .)
	label define `label' -99 "Otros (< `minimum'% PIB)", add modify

	if "$graphs" == "on" | "`graphs'" == "graphs" {
		replace aprobadonetoPIB = proyectonetoPIB if anio == 2019
		replace gastonetoPIB = 0 if anio == 2019 | anio == 2018
		
		graph bar (sum) aprobadonetoPIB gastonetoPIB if anio >= 2010 & `by' != -1 ///
			& neto == 0 & aprobadonetoPIB != 0, ///
			over(`over', relabel(1 "PEF" 2 "Obs")) ///
			over(anio, label(labgap(vsmall))) ///
			stack asyvars ///
			title("{bf:Gastos presupuestarios aprobados y ejercidos}", /*position(5)*/) ///
			ytitle(% PIB) ylabel(0(5)30, labsize(small)) ///
			legend(on position(6) rows(`rows') cols(`cols')) ///
			name(gastos, replace) ///
			/// yreverse xalternate yalternate ///
			blabel(bar, format(%7.1fc)) ///
			caption("{it:Fuente: Elaborado por el CIEP, con informaci{c o'}n de la SHCP (Datos Abiertos y Paquetes Econ{c o'}micos).}")
		gr_edit .plotregion1.GraphEdit, cmd(_set_rotate)
		gr_edit .plotregion1.GraphEdit, cmd(_set_rotate)
		gr_edit .grpaxis.major.num_rule_ticks = 0
		gr_edit .grpaxis.edit_tick 13 92.9825 `"PPEF"', tickset(major)
		
		replace aprobadonetoPIB = 0 if anio == 2019
		replace gastonetoPIB = proyectonetoPIB if anio == 2019
		replace gastonetoPIB = aprobadonetoPIB if anio == 2018
	}




	********************
	** 4. Display PEF **

	** 4.1. Concepto **
	noisily di _newline in g "{bf: A. Gasto presupuestario (`by') " ///
		_col(44) in g %20s "MXN" ///
		_col(66) %7s "% PIB" ///
		_col(77) %7s "% Total" "}"

	tabstat gasto gastoPIB if anio == `anio' & `by' != -1, by(`by') stat(sum) f(%20.0fc) save
	tempname mattot
	matrix `mattot' = r(StatTotal)

	local k = 1
	while "`=r(name`k')'" != "." {
		tempname mat`k'
		matrix `mat`k'' = r(Stat`k')

		if substr(`"`=r(name`k')'"',1,31) == "'" {
			local disptext = substr(`"`=r(name`k')'"',1,30)
		}
		else {
			local disptext = substr(`"`=r(name`k')'"',1,31)
		}
		local name = strtoname(`"`disptext'"')
		return scalar `name' = `mat`k''[1,1]
		local division `"`division' `name'"'

		noisily di in g `"  (+) `disptext'"' ///
			_col(44) in y %20.0fc `mat`k''[1,1] ///
			_col(66) in y %7.3fc `mat`k''[1,2] ///
			_col(77) in y %7.1fc `mat`k''[1,1]/`mattot'[1,1]*100
		local ++k
	}
	return local division "`division'"

	noisily di in g _dup(83) "-"
	noisily di in g "{bf:  (=) Gasto bruto" ///
		_col(44) in y %20.0fc `mattot'[1,1] ///
		_col(66) in y %7.3fc `mattot'[1,2] ///
		_col(77) in y %7.1fc `mattot'[1,1]/`mattot'[1,1]*100 "}"

	if "`if'" == "" {
		noisily di in g `"  (-) `=substr("Cuotas ISSSTE",1,35)'"' ///
			_col(44) in y %20.0fc `Cuotas_ISSSTE'[1,1] ///
			_col(66) in y %7.3fc `Cuotas_ISSSTE'[1,2] ///
			_col(77) in y %7.1fc `Cuotas_ISSSTE'[1,1]/`mattot'[1,1]*100
		noisily di in g `"  (-) `=substr("Aportaciones a la seguridad social",1,35)'"' ///
			_col(44) in y %20.0fc `Aportaciones_Federacion'[1,1] ///
			_col(66) in y %7.3fc `Aportaciones_Federacion'[1,2] ///
			_col(77) in y %7.1fc `Aportaciones_Federacion'[1,1]/`mattot'[1,1]*100
		noisily di in g _dup(83) "-"
		noisily di in g "{bf:  (=) Gasto neto" ///
			_col(44) in y %20.0fc `mattot'[1,1]-`Cuotas_ISSSTE'[1,1]-`Aportaciones_Federacion'[1,1] ///
			_col(66) in y %7.3fc  `mattot'[1,2]-`Cuotas_ISSSTE'[1,2]-`Aportaciones_Federacion'[1,2] ///
			_col(77) in y %7.1fc (`mattot'[1,1]-`Cuotas_ISSSTE'[1,1]-`Aportaciones_Federacion'[1,1])/`mattot'[1,1]*100 "}"
	}
	else {
		matrix `Aportaciones_Federacion' = J(1,1,0)
	}

	return scalar `=strtoname("Gasto bruto")' = `mattot'[1,1]
	return scalar `=strtoname("Gasto neto")' = `mattot'[1,1]-`Cuotas_ISSSTE'[1,1]-`Aportaciones_Federacion'[1,1]


	** 5.2. Resumido **
	noisily di _newline in g "{bf: B. Gasto presupuestario (Resumido) " ///
		_col(44) in g %20s "MXN" ///
		_col(66) %7s "% PIB" ///
		_col(77) %7s "% Total" "}"

	tabstat gastoneto gastonetoPIB if anio == `anio' & `by' != -1 & neto == 0, by(`over') stat(sum) f(%20.1fc) save
	tempname mattot
	matrix `mattot' = r(StatTotal)

	local k = 1
	while "`=r(name`k')'" != "." {
		tempname mat`k'
		matrix `mat`k'' = r(Stat`k')

		if substr(`"`=r(name`k')'"',1,25) == "'" {
			local disptext = substr(`"`=r(name`k')'"',1,24)
		}
		else {
			local disptext = substr(`"`=r(name`k')'"',1,25)
		}
		local name = strtoname(`"`disptext'"')

		return scalar neto_`name' = `mat`k''[1,1]
		local resumido `"`resumido' neto_`name'"'


		noisily di in g `"  (+) `disptext'"' ///
			_col(44) in y %20.0fc `mat`k''[1,1] ///
			_col(66) in y %7.3fc `mat`k''[1,2] ///
			_col(77) in y %7.1fc `mat`k''[1,1]/`mattot'[1,1]*100
		local ++k
	}
	return local resumido "`resumido'"

	noisily di in g _dup(83) "-"
	noisily di in g "{bf:  (=) Gasto neto" ///
		_col(44) in y %20.0fc `mattot'[1,1] ///
		_col(66) in y %7.3fc `mattot'[1,2] ///
		_col(77) in y %7.1fc `mattot'[1,1]/`mattot'[1,1]*100 "}"


	tempname Resumido_total
	matrix `Resumido_total' = r(StatTotal)
	return scalar Resumido_total = `Resumido_total'[1,1]


	** Crecimientos **
	preserve
	collapse (sum) gastoneto* if `by' != -1 & neto == 0, by(anio `by')
	if `=_N' > 5 {
		xtset `by' anio
		tsfill, full
		tabstat gastoneto gastonetoPIB if anio == `anio', by(`by') stat(sum) f(%20.1fc) missing save
		tempname mattot
		matrix `mattot' = r(StatTotal)

		local k = 1
		while "`=r(name`k')'" != "." {
			tempname mat`k'
			matrix `mat`k'' = r(Stat`k')
			local ++k
		}

		capture tabstat gastoneto gastonetoPIB if anio == `anio'-5, by(`by') stat(sum) f(%20.1fc) missing save
		if _rc == 0 {
			tempname mattot5
			matrix `mattot5' = r(StatTotal)

			noisily di _newline in g "{bf: C. Mayores cambios:" in y " `=`anio'-5' - `anio'" in g ///
				_col(55) %7s "`=`anio'-5'" ///
				_col(66) %7s "`anio'" ///
				_col(77) %7s "Cambio PIB" "}"

			local k = 1
			while "`=r(name`k')'" != "." {
				tempname mat5`k'
				matrix `mat5`k'' = r(Stat`k')

				if substr(`"`=r(name`k')'"',1,25) == "'" {
					local disptext = substr(`"`=r(name`k')'"',1,24)
				}
				else {
					local disptext = substr(`"`=r(name`k')'"',1,25)
				}
				
				if abs(`mat`k''[1,2]-`mat5`k''[1,2]) > .4 {
					noisily di in g `"  (+) `disptext'"' ///
						_col(55) in y %7.3fc `mat5`k''[1,2] ///
						_col(66) in y %7.3fc `mat`k''[1,2] ///
						_col(77) in y %7.3fc `mat`k''[1,2]-`mat5`k''[1,2]
				}
				local ++k
			}

			noisily di in g _dup(83) "-"
			noisily di in g "{bf:  (=) Total" ///
				_col(55) in y %7.3fc `mattot5'[1,2] ///
				_col(66) in y %7.3fc `mattot'[1,2] ///
				_col(77) in y %7.3fc `mattot'[1,2]-`mattot5'[1,2] "}"
		}
	}
	restore

	capture drop __*
}
end
