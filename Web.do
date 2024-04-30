***********************************
***                             ***
**#    SIMULADOR FISCAL CIEP    ***
***        ver: SIM.md          ***
***                             ***
***********************************
clear all
macro drop _all
capture log close _all
timer on 1


** 0.1 Rutas de archivos  **
if "`c(username)'" == "ricardo" ///                                   // iMac Ricardo
	sysdir set PERSONAL "/Users/ricardo/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/SimuladorCIEP/"
else if "`c(username)'" == "ciepmx" & "`c(console)'" == "" ///        // Servidor CIEP
	sysdir set PERSONAL "/home/ciepmx/CIEP Dropbox/Ricardo Cantú/SimuladoresCIEP/SimuladorCIEP/"
else ///														      // Web
	sysdir set PERSONAL "/SIM/OUT/6/"
cd `"`c(sysdir_personal)'"'


** 0.2 Opciones globales **
global id = "ciepmx"													// IDENTIFICADOR DEL USUARIO
global nographs "nographs"												// SUPRIMIR GRAFICAS
//global update "update"													// ACTUALIZAR ARCHIVOS


** 0.3 Crear carpetas **
capture mkdir `"`c(sysdir_personal)'/users/"'
capture mkdir `"`c(sysdir_personal)'/users/$id/"'


** 0.4 Archivo output.txt (web) **
global output "output"													// OUTPUTS (WEB)
if "$output" != "" {
	quietly log using `"`c(sysdir_personal)'/users/$id/output.txt"', replace text name(output)
	quietly log off output
}



***************************
***                     ***
**#    1. MARCO MACRO   ***
***                     ***
***************************
global paqueteEconomico "PE 2024"
scalar anioPE = 2024
scalar aniovp = 2024
scalar anioenigh = 2022


** 1.2 Economía **
** 1.2.1 Parámetros: Crecimiento anual del Producto Interno Bruto **
global pib2024 = 2.591
global pib2025 = 2.5007
global pib2026 = 2.4779
global pib2027 = 2.5
global pib2028 = 2.5
global pib2029 = 2.5002

** 1.2.2 Parámetros: Crecimiento anual del índice de precios implícitos **
global def2024 = 4.1
global def2025 = 3.9
global def2026 = 3.5
global def2027 = 3.5
global def2028 = 3.5
global def2029 = 3.5

** 1.2.3 Parámetros: Crecimiento anual del índice nacional de precios al consumidor **
global inf2024 = 3.8
global inf2025 = 3.3
global inf2026 = 3.0
global inf2027 = 3.0
global inf2028 = 3.0
global inf2029 = 3.0

** 1.2.4 Proyecciones: PIB, Deflactor e Inflación **
//noisily PIBDeflactor, anio(`=aniovp') geopib(2010) geodef(2010) $nographs $update


** 1.5 Perfiles fiscales **
capture confirm file "`c(sysdir_personal)'/SIM/perfiles`=anioPE'.dta"
if _rc != 0 | "`update'" == "update" ///
	noisily run `"`c(sysdir_personal)'/PerfilesSim.do"' `=anioPE'



*********************************/
***                            ***
**#    2. MÓDULOS SIMULADOR    ***
***                            ***
**********************************

** 2.8 Parámetros: ISR **/
** Inputs: Archivo "`c(sysdir_personal)'/SIM/perfiles`=anioPE'.dta" o "`c(sysdir_site)'/users/$pais/$id/households.dta"
** Outputs: Archivo "`c(sysdir_site)'/users/$pais/$id/households.dta" actualizado más scalars ISRAS, ISRPF, ISRPM y CUOTAS.
* Anexo 8 de la Resolución Miscelánea Fiscal para 2023 *
* Tarifa para el cálculo del impuesto correspondiente al ejericio 2023 (página 782) *
*             INFERIOR			SUPERIOR	CF		TASA
matrix ISR =  (0.01,			8952.49,		0.0,		1.92	\    /// 1
			8952.49    +.01,	75984.55,		171.88,		6.40	\    /// 2
			75984.55   +.01,	133536.07,		4461.94,	10.88	\    /// 3
			133536.07  +.01,	155229.80,		10723.55,	16.00	\    /// 4
			155229.80  +.01,	185852.57,		14194.54,	17.92	\    /// 5
			185852.57  +.01,	374837.88,		19682.13,	21.36	\    /// 6
			374837.88  +.01,	590795.99,		60049.40,	23.52	\    /// 7
			590795.99  +.01,	1127926.84,		110842.74,	30.00	\    /// 8
			1127926.84 +.01,	1503902.46,		271981.99,	32.00	\    /// 9
			1503902.46 +.01,	4511707.37,		392294.17,	34.00	\    /// 10
			4511707.37 +.01,	1E+12,			1414947.85,	35.00)	     //  11

* Tabla del subsidio para el empleo aplicable a la tarifa del numeral 5 del rubro B (página 773) *
*             INFERIOR			SUPERIOR		SUBSIDIO
matrix	SE =  (0.01,			1768.96*12,		407.02*12		\    /// 1
			1768.96*12 +.01,	2653.38*12,		406.83*12		\    /// 2
			2653.38*12 +.01,	3472.84*12,		406.62*12		\    /// 3
			3472.84*12 +.01,	3537.87*12,		392.77*12		\    /// 4
			3537.87*12 +.01,	4446.15*12,		382.46*12		\    /// 5
			4446.15*12 +.01,	4717.18*12,		354.23*12		\    /// 6
			4717.18*12 +.01,	5335.42*12,		324.87*12		\    /// 7
			5335.42*12 +.01,	6224.67*12,		294.63*12		\    /// 8
			6224.67*12 +.01,	7113.90*12,		253.54*12		\    /// 9
			7113.90*12 +.01,	7382.33*12,		217.61*12		\    /// 10
			7382.33*12 +.01,	1E+12,			0)		 	     //  11


* Artículo 151, último párrafo (LISR) *
*            Ex. SS.MM.	Ex. 	% ing. gravable		% Informalidad PF	% Informalidad Salarios
matrix DED = (5,				15,					57.79, 				42.82)

* Artículo 9, primer párrafo (LISR) * 
*           Tasa ISR PM.	% Informalidad PM
matrix PM = (30,			21.59)


** 2.9 Parámetros: IMSS e ISSSTE **
* Informe al Ejecutivo Federal y al Congreso de la Unión la situación financiera y los riesgos del IMSS 2021-2022 *
* Anexo A, Cuadro A.4 *
matrix CSS_IMSS = ///
///		PATRONES	TRABAJADORES	GOBIERNO FEDERAL
		(5.42,		0.44,			3.21	\   /// Enfermedad y maternidad, asegurados (Tgmasg*)
		1.05,		0.37,			0.08	\   /// Enfermedad y maternidad, pensionados (Tgmpen*)
		1.75,		0.63,			0.13	\   /// Invalidez y vida (Tinvyvida*)
		1.83,		0.00,			0.00	\   /// Riesgos de trabajo (Triesgo*)
		1.00,		0.00,			0.00	\   /// Guarderias y prestaciones sociales (Tguard*)
		5.15,		1.12,			1.49	\   /// Retiro, cesantia en edad avanzada y vejez (Tcestyvej*)
		0.00,		0.00,			6.55)	    //  Cuota social -- hasta 25 UMA -- (TcuotaSocIMSS*)

* Informe Financiero Actuarial ISSSTE 2021 *
matrix CSS_ISSSTE = ///
///		PATRONES	TRABAJADORES	GOBIERNO FEDERAL
		(7.375,		2.750,			391.0	\   /// Seguro de salud, trabajadores en activo y familiares (Tfondomed* / TCuotaSocISSTEF)
		0.720,		0.625,			0.000	\   /// Seguro de salud, pensionados y familiares (Tpensjub*)
		0.750,		0.000,			0.000	\   /// Riesgo de trabajo
		0.625,		0.625,			0.000	\   /// Invalidez y vida
		0.500,		0.500,			0.000	\   /// Servicios sociales y culturales
		6.125,		2+3.175,		5.500	\   /// Retiro, cesantia en edad avanzada y vejez
		0.000,		5.000,			0.000	\   /// Vivienda
		0.000,		0.000,			13.9)		//  Cuota social

if "`cambioisrpf'" == "1" {
	noisily run "`c(sysdir_personal)'/ISR_Mod.do"
	scalar ISRAS  = ISR_AS_Mod
	scalar ISRPF  = ISR_PF_Mod
	scalar ISRPM  = ISR_PM_Mod
	scalar CUOTAS = CUOTAS_Mod
}


** 2.10 Parámetros: IVA **
* Inputs: Archivo "`c(sysdir_personal)'/SIM/perfiles`=anioPE'.dta" o "`c(sysdir_site)'/users/$pais/$id/households.dta"
* Outputs: Archivo "`c(sysdir_site)'/users/$pais/$id/households.dta" actualizado más scalar IVA.
matrix IVAT = (16 \     ///  1  Tasa general 
	1  \     ///  2  Alimentos, input[1]: Tasa Cero, [2]: Exento, [3]: Gravado
	2  \     ///  3  Alquiler, idem
	1  \     ///  4  Canasta basica, idem
	2  \     ///  5  Educacion, idem
	3  \     ///  6  Consumo fuera del hogar, idem
	3  \     ///  7  Mascotas, idem
	1  \     ///  8  Medicinas, idem
	1  \     ///  9  Toallas sanitarias, idem
	3  \     /// 10  Otros, idem
	2  \     /// 11  Transporte local, idem
	3  \     /// 12  Transporte foraneo, idem
	29.96)   //  13  Evasion e informalidad IVA, input[0-100]
if "`cambioiva'" == "1" {
	noisily run "`c(sysdir_personal)'/IVA_Mod.do"
	scalar IVA = IVA_Mod
}


** 2.11 Parámetros: IEPS **
* Inputs: Archivo "`c(sysdir_personal)'/SIM/perfiles`=anioPE'.dta" o "`c(sysdir_site)'/users/$pais/$id/households.dta"
* Outputs: Archivo "`c(sysdir_site)'/users/$pais/$id/households.dta" actualizado más scalar IEPS.
* Fuente: Ley del IEPS, Artículo 2.
*              Ad valorem		Específico
matrix IEPST = (26.5	,		0 			\ /// Cerveza y alcohol 14
				30.0	,		0 			\ /// Alcohol 14+ a 20
				53.0	,		0 			\ /// Alcohol 20+
				160.0	,		0.6166		\ /// Tabaco y cigarros
				30.0	,		0 			\ /// Juegos y sorteos
				3.0		,		0 			\ /// Telecomunicaciones
				25.0	,		0 			\ /// Bebidas energéticas
				0		,		1.5737		\ /// Bebidas saborizadas
				8.0		,		0 			\ /// Alto contenido calórico
				0		,		10.7037		\ /// Combustibles: gas licuado de petróleo (promedio propano y butano)
				0		,		21.1956		\ /// Combustibles (petróleo)
				0		,		19.8607		\ /// Combustibles (diésel)
				0		,		43.4269		\ /// Combustibles (carbón)
				0		,		21.1956		\ /// Combustibles (combustible para calentar)
				0		,		6.1752		\ /// Gasolina: magna
				0		,		5.2146		\ /// Gasolina: premium
				0		,		6.7865		) // Gasolina: diésel


** 2.12 Integración de módulos ***
noisily TasasEfectivas, anio(`=anioPE')
noisily GastoPC, aniope(`=anioPE') aniovp(`=aniovp')



*****************************/
***                        ***
**#    3. CICLO DE VIDA    ***
***                        ***
******************************
use `"`c(sysdir_personal)'/users/$id/ingresos.dta"', clear
merge 1:1 (folioviv foliohog numren) using "`c(sysdir_personal)'/users/$id/gastos.dta", nogen
capture merge 1:1 (folioviv foliohog numren) using "`c(sysdir_personal)'/users/$id/isr_mod.dta", nogen replace update
capture merge 1:1 (folioviv foliohog numren) using "`c(sysdir_personal)'/users/$id/iva_mod.dta", nogen replace update


** 3.1 (+) Impuestos y aportaciones **
capture drop ImpuestosAportaciones
egen ImpuestosAportaciones = rsum(ISRAS ISRPF CUOTAS ISRPM OTROSK IVA IEPSNP IEPSP ISAN IMPORT)
label var ImpuestosAportaciones "impuestos y aportaciones"


** 3.2 (-) Impuestos y aportaciones **
capture drop Transferencias
egen Transferencias = rsum(Educación Pensiones Educación Salud IngBasico Pensión_AM Otras_inversiones) // 
label var Transferencias "transferencias públicas"


** 3.3 (=) Aportaciones netas **
capture drop AportacionesNetas
g AportacionesNetas = ImpuestosAportaciones - Transferencias
label var AportacionesNetas "aportaciones netas"
noisily Perfiles AportacionesNetas [fw=factor], reboot aniovp(2024) aniope(`=anioPE') $nographs //boot(20)


** 3.4 (*) Cuentas generacionales **
//noisily CuentasGeneracionales AportacionesNetas, anio(`=anioPE') discount(7)


** 3.5 (*) Sankey del sistema fiscal **
foreach k in decil grupoedad {
	noisily run "`c(sysdir_personal)'/SankeySF.do" `k' `=aniovp'
}



********************************************/
***                                       ***
**#    4. PARTE IV: DEUDA + FISCAL GAP    ***
***                                       ***
*********************************************
scalar shrfsp2024 = 50.2
scalar shrfspInterno2024 = 38.8
scalar shrfspExterno2024 = 11.4
scalar rfsp2024 = -5.9
scalar rfspPIDIREGAS2024 = -0.1
scalar rfspIPAB2024 = -0.1
scalar rfspFONADIN2024 = -0.1
scalar rfspDeudores2024 = 0.0
scalar rfspBanca2024 = -0.1
scalar rfspAdecuaciones2024 = -0.6
scalar rfspBalance2024 = -5.0
scalar tipoDeCambio2024 = 17.6
scalar balprimario2024 = 1.2
scalar costodeudaInterno2024 = 3.6
scalar costodeudaExterno2024 = 3.6

scalar shrfsp2025 = 50.2
scalar shrfspInterno2025 = 39.0
scalar shrfspExterno2025 = 11.2
scalar rfsp2025 = -2.6
scalar rfspPIDIREGAS2025 = -0.1
scalar rfspIPAB2025 = -0.1
scalar rfspFONADIN2025 = 0.0
scalar rfspDeudores2025 = 0.0
scalar rfspBanca2025 = 0.0
scalar rfspAdecuaciones2025 = -0.2
scalar rfspBalance2025 = -2.1
scalar tipoDeCambio2025 = 17.9
scalar balprimario2025 = -0.9
scalar costodeudaInterno2025 = 3.4
scalar costodeudaExterno2025 = 3.4

scalar shrfsp2026 = 49.4
scalar shrfspInterno2026 = 38.0
scalar shrfspExterno2026 = 10.9
scalar rfsp2026 = -2.7
scalar rfspPIDIREGAS2026 = -0.1
scalar rfspIPAB2026 = -0.1
scalar rfspFONADIN2026 = 0.0
scalar rfspDeudores2026 = 0.0
scalar rfspBanca2026 = 0.0
scalar rfspAdecuaciones2026 = -0.3
scalar rfspBalance2026 = -2.5
scalar tipoDeCambio2026 = 18.1
scalar balprimario2026 = -0.5
scalar costodeudaInterno2026 = 2.7
scalar costodeudaExterno2026 = 2.7

scalar shrfsp2027 = 48.8
scalar shrfspInterno2027 = 38.3
scalar shrfspExterno2027 = 10.6
scalar rfsp2027 = -2.7
scalar rfspPIDIREGAS2027 = -0.1
scalar rfspIPAB2027 = -0.1
scalar rfspFONADIN2027 = 0.0
scalar rfspDeudores2027 = 0.1
scalar rfspBanca2027 = 0.0
scalar rfspAdecuaciones2027 = -0.4
scalar rfspBalance2027 = -2.2
scalar tipoDeCambio2027 = 18.2
scalar balprimario2027 = -0.3
scalar costodeudaInterno2027 = 2.5
scalar costodeudaExterno2027 = 2.5

scalar shrfsp2028 = 48.8
scalar shrfspInterno2028 = 38.6
scalar shrfspExterno2028 = 10.3
scalar rfsp2028 = -2.7
scalar rfspPIDIREGAS2028 = -0.1
scalar rfspIPAB2028 = -0.1
scalar rfspFONADIN2028 = 0.1
scalar rfspDeudores2028 = 0.0
scalar rfspBanca2028 = 0.0
scalar rfspAdecuaciones2028 = -0.3
scalar rfspBalance2028 = -2.2
scalar tipoDeCambio2028 = 18.4
scalar balprimario2028 = -0.3
scalar costodeudaInterno2028 = 2.5
scalar costodeudaExterno2028 = 2.5

scalar shrfsp2029 = 48.8
scalar shrfspInterno2029 = 38.9
scalar shrfspExterno2029 = 10.0
scalar rfsp2029 = -2.7
scalar rfspPIDIREGAS2029 = -0.1
scalar rfspIPAB2029 = -0.1
scalar rfspFONADIN2029 = 0.0
scalar rfspDeudores2029 = 0.0
scalar rfspBanca2029 = 0.0
scalar rfspAdecuaciones2029 = -0.3
scalar rfspBalance2029 = -2.2
scalar tipoDeCambio2029 = 18.6
scalar balprimario2029 = -0.3
scalar costodeudaInterno2029 = 2.5
scalar costodeudaExterno2029 = 2.5

** Inputs: Archivo "`c(sysdir_site)'/users/$pais/$id/households.dta", SHRFSP, PEFs y LIFs.
** Outputs: Sostenibilidad de la deuda y brecha fiscal hasta 2030.
** 4.2 Proyecciones: Saldo Histórico de los Requerimientos Financieros del Sector Público **/
//noisily SHRFSP, ultanio(2001) anio(`=anioPE') $update
noisily FiscalGap, anio(`=anioPE') end(2030) aniomin(2016) $nographs desde(2016) discount(10) //update //anio(`=aniovp')



***************************/
****                    ****
****    Touchdown!!!    ****
****                    ****
****************************
if "$output" == "output" {
	run "`c(sysdir_personal)'/output.do"
}
timer off 1
timer list 1
noisily di _newline(2) in g _dup(20) ":" "  " in y "TOUCH-DOWN!!!  " round(`=r(t1)/r(nt1)',.1) in g " segs  " _dup(20) ":"
