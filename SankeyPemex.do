********************************
***                          ***
*** LINGO, Sankey's de Pemex ***
***                          ***
********************************
clear all
if "`c(username)'" == "ricardo" ///                             // iMac Ricardo
	sysdir set PERSONAL "/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/SimuladorCIEP/"
if "`c(username)'" == "ciepmx" & "`c(console)'" == "" ///       // Servidor CIEP
	sysdir set PERSONAL "/home/ciepmx/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/SimuladorCIEP/"

cd "/home/ciepmx/CIEP Dropbox/Ricardo Cantú/LINGO/Sankeys/"





*************************
***                   ***
*** 1. Bases de datos ***
***                   ***
/*************************

** 1.1. Ventas netas de bienes y servicios **
DatosAbiertos XKC0106, nog
rename monto Ventas
keep anio Ventas
save XKC0106


** 1.2. Otros ingresos **
DatosAbiertos XKC0179, nog
rename monto OtrosIngresos
keep anio OtrosIngresos
save XKC0179


** 2.1. Derechos y enteros **
DatosAbiertos XKC0113, nog
rename monto Derechos
keep anio Derechos
save XKC0113


** 2.2. Gasto programable **
DatosAbiertos XKC0131, nog
rename monto Programable
keep anio Programable
save XKC0131


** 2.2.1 Pensiones y jubilaciones **
DatosAbiertos XKC0139, nog
rename monto Pensiones
keep anio Pensiones
save XKC0139


** 2.2.2. Gastos de inversión **
DatosAbiertos XKC0145, nog
rename monto Inversion
keep anio Inversion
save XKC0145


** 2.3. Gasto no programable **
DatosAbiertos XKC0157, nog
rename monto NoProgramable
keep anio NoProgramable
save XKC0157





** 1.1. Append y collapse **/
forvalues anio = 2019(1)2023 {

	** 1.2. Información adicional **
	if "`anio'" == "2023" {
		local reduccionduc = 157500000000
		local estimulosfiscales = 86640000000
		local apoyospatrimoniales = 166615122970
		local indirectos = 416875393557
		local fmp = 255633786073
		local tesofe = 320323565125.80
	}
	if "`anio'" == "2022" {
		local reduccionduc = 238100*1000000
		local estimulosfiscales = (7455+23000)*1000000
		local apoyospatrimoniales = 188306*1000000
		local indirectos = 299434678260
		local fmp = 529233592611
		local tesofe = 619950978054.93
	}
	if "`anio'" == "2021" {
		local reduccionduc = 77900*1000000
		local estimulosfiscales = (73280+22915)*1000000
		local apoyospatrimoniales = 316354*1000000
		local indirectos = 357608812555
		local fmp = 383922663710
		local tesofe = 349684357892.52
	}
	if "`anio'" == "2020" {
		local reduccionduc = 26500*1000000
		local estimulosfiscales = (65000+5800)*1000000
		local apoyospatrimoniales = 46256*1000000
		local indirectos = 399325085921
		local fmp = 187271584137
		local tesofe = 180066508495.78
	}
	if "`anio'" == "2019" {
		local reduccionduc = 0
		local estimulosfiscales = (25787+38704)*1000000
		local apoyospatrimoniales = 122131*1000000
		local indirectos = 443943085740
		local fmp = 410158961425
		local tesofe = 408901963776.66
	}


	**************************************/
	***                                 ***
	*** Eje 1: Ingresos propios (PEMEX) ***
	***                                 ***
	***************************************

	** 1.1. Ingresos propios **
	use XKC0106, clear
	append using XKC0179

	collapse (sum) Ing_Propios_Ventas=Ventas ///
		Ing_Propios_Otros_Ingresos=OtrosIngresos ///
		if anio == `anio', by(anio)

	replace Ing_Propios_Ventas = Ing_Propios_Ventas //+ `indirectos'
	replace Ing_Propios_Otros_Ingresos = Ing_Propios_Otros_Ingresos - `apoyospatrimoniales'

	** 1.2. Reshape para el Sankey **
	tempvar from to
	g `to' = "Pemex"
	reshape long Ing_Propios_, i(`to') j(`from') string

	encode `to', g(to)
	encode `from', g(from)

	rename Ing_Propios_ profile

	tabstat profile, s(sum) save
	local ingresosPemex = r(StatTotal)[1,1] 
	local ingresosPemex = `ingresosPemex' + `reduccionduc' + `estimulosfiscales' + `apoyospatrimoniales'

	set obs `=_N+1'
	replace anio = `anio' in -1
	replace profile = `indirectos' in -1
	replace to = 98 in -1
	replace from = 2 in -1
	label define to 98 "Imp Indirectos", add

	replace profile = profile / 1000000000
	tempfile eje1
	save `eje1'



	*********************************************************
	***                                                   ***
	*** Eje 2: Gastos operativos, financieros e impuestos ***
	***                                                   ***
	*********************************************************
	use XKC0113, clear
	append using XKC0131
	append using XKC0157
	append using XKC0139
	append using XKC0145

	collapse (sum) Gastos_Derechos_y_Enteros=Derechos ///
		Gastos_Gastos_Operativos=Programable ///
		Gastos_Gastos_Financieros=NoProgramable ///
		Gastos_Pensiones=Pensiones ///
		Gastos_Inversión=Inversion ///
		if anio == `anio', by(anio)

	replace Gastos_Gastos_Operativos = Gastos_Gastos_Operativos - Gastos_Pensiones - Gastos_Inversión

	replace Gastos_Derechos = Gastos_Derechos + `reduccionduc' 		// Reducción DUC
	replace Gastos_Derechos = Gastos_Derechos + `estimulosfiscales' // Estímulos fiscales
	replace Gastos_Derechos = Gastos_Derechos //+ `indirectos'		// IEPS e IVA

	tabstat Gastos_Derechos, s(sum) save
	local gastosGobiernoFederal = r(StatTotal)[1,1] - `reduccionduc' - `estimulosfiscales' + `indirectos'

	tempvar from to
	g `from' = "Pemex"
	reshape long Gastos_, i(`from') j(`to') string

	encode `to', g(to)
	encode `from', g(from)

	rename Gastos_ profile

	tabstat profile, s(sum) save
	local gastosPemex = r(StatTotal)[1,1]

	if `ingresosPemex' - `gastosPemex' > 0 {
		set obs `=_N+1'
		replace anio = `anio' in -1
		replace from = 1 in -1
		replace to = 99 in -1
		replace profile = `ingresosPemex' - `gastosPemex' in -1
		label define to 99 "Superávit", add
	}

	replace profile = profile / 1000000000
	tempfile eje2
	save `eje2'



	********************************************************
	***                                                  ***
	*** Eje 3: Aportaciones al gobierno federal y al FMP ***
	***                                                  ***
	********************************************************
	use `eje2', clear
	collapse (sum) profile if to == 1, by(to anio)
	rename to from 

	g to = 6
	label define to 6 "FMP", add
	label values to to

	tabstat profile, s(sum) save
	local DerechosEnteros = r(StatTotal)[1,1]

	replace profile = `fmp' / 1000000000

	set obs `=_N+1'
	replace anio = `anio' in -1
	replace from = 1 in -1
	replace to = 7 in -1
	label define to 7 "Gobierno Federal", add
	replace profile = `DerechosEnteros' - (`fmp' + `reduccionduc' + `estimulosfiscales')/1000000000 in -1

	set obs `=_N+1'
	replace anio = `anio' in -1
	replace from = 200 in -1
	replace to = 7 in -1
	replace profile = `indirectos' / 1000000000 in -1
	label define to 200 "Imp Indirectos", add

	set obs `=_N+1'
	replace anio = `anio' in -1
	replace from = 1 in -1
	replace to = 8 in -1
	replace profile = (`reduccionduc' + `estimulosfiscales')/1000000000 in -1
	label define to 8 "Pemex", add

	if `ingresosPemex' - `gastosPemex' > 0 {
		set obs `=_N+1'
		replace anio = `anio' in -1
		replace from = 99 in -1
		replace to = 100 in -1
		replace profile = (`ingresosPemex' - `gastosPemex')/1000000000 in -1
	}
	label define to 100 "Contribución neta", add

	tempfile eje3
	save `eje3'



	********************************/
	** Eje 4: Aportaciones del FMP **
	use `eje3', clear
	collapse (sum) profile if to == 6, by(to anio)
	rename to from 

	g to = 7
	label values to to
	*replace profile = `tesofe' / 1000000000

	/*set obs `=_N+1'
	replace anio = `anio' in -1
	replace from = 6 in -1
	replace to = 101 in -1
	replace profile = (`fmp' - `tesofe') / 1000000000 in -1
	label define to 101 "Otros fondos", add*/

	local deficit = 0
	if `ingresosPemex' - `gastosPemex' < 0 {
		local deficit = -(`ingresosPemex' - `gastosPemex')
	}
	label define to 201 "Pemex", add
	label values to to

	set obs `=_N+1'
	replace anio = `anio' in -1
	replace from = 7 in -1
	replace to = 100 in -1
	replace profile = (`gastosGobiernoFederal' - (`apoyospatrimoniales') - `deficit')/1000000000 in -1

	/*if `ingresosPemex' - `gastosPemex' < 0 {
		set obs `=_N+1'
		replace anio = `anio' in -1
		replace from = 7 in -1
		replace to = 201 in -1
		replace profile = -(`ingresosPemex' - `gastosPemex') / 1000000000 in -1
	}*/

	tempfile eje4
	save `eje4'



	**********************************************
	** Eje 5: Aportaciones del gobierno federal **
	use `eje4', clear
	collapse (sum) profile if to == 7, by(to anio)
	rename to from

	replace profile = `apoyospatrimoniales' + `deficit'				// Apoyos patrimoniales
	replace profile = profile / 1000000000

	g to = 201
	label values to to

	/*set obs `=_N+1'
	replace anio = `anio' in -1
	replace from = 99 in -1
	replace to = 100 in -1
	replace profile = (`ingresosPemex' - `gastosPemex') / 1000000000 in -1*/

	tempfile eje5
	save `eje5'


	noisily SankeySumLoop, anio(`anio') name(`anio') folder(SankeyPemex) a(`eje1') b(`eje2') c(`eje3') d(`eje4') e(`eje5')
}





***************************
** Primero, los ingresos **
***************************
//noisily LIF if divCIEP2 == 4, by(divPE) rows(1) min(0) anio(2024) $update desde(2000) title("Ingresos petroleros") update



***************************************************
** Segundo, las aportaciones al gobierno federal **
***************************************************

