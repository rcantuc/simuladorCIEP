***********************************
***                             ***
**#    SIMULADOR FISCAL CIEP    ***
***        ver: SIM.md          ***
***                             ***
***********************************
noisily run "/SIM/OUT/6/profile.do"                                   // PERFIL DE USUARIO
sysdir set PERSONAL "/SIM/OUT/6/"
cd `"`c(sysdir_personal)'"'


****************************/
**  0.2 Opciones globales  **
** Comentar o descomentar, según el caso. **
global id = "`c(username)'"                                                   // IDENTIFICADOR DEL USUARIO
global nographs "nographs"                                                    // SUPRIMIR GRAFICAS
global output "output"                                                        // OUTPUTS (WEB)

**  Rutas de archivos  **
capture mkdir `"`c(sysdir_personal)'/SIM/"'
capture mkdir `"`c(sysdir_personal)'/SIM/graphs"'
capture mkdir `"`c(sysdir_personal)'/users/"'
capture mkdir `"`c(sysdir_personal)'/users/$id/"'

**  Archivo output.txt (web)  **
if "$output" != "" {
	quietly log using `"`c(sysdir_personal)'/users/$id/output.txt"', replace text name(output)
	quietly log off output
}






***************************
***                     ***
**#    1. MARCO MACRO   ***
***                     ***
***************************

** 1.1 Población **
* (omitido) *


** 1.2 Economía **
** 1.2.1 Parámetros: Crecimiento anual del Producto Interno Bruto **
global pib2023 = 2.6893
global pib2024 = 2.6189
global pib2025 = 2.5097
global pib2026 = 2.4779
global pib2027 = 2.5
global pib2028 = 2.5
global pib2029 = 2.5002

** 1.2.2 Parámetros: Crecimiento anual del índice de precios implícitos **
global def2023 = 5.0
global def2024 = 4.8
global def2025 = 3.5
global def2026 = 3.5
global def2027 = 3.5
global def2028 = 3.5
global def2029 = 3.5

** 1.2.3 Parámetros: Crecimiento anual del índice nacional de precios al consumidor **
global inf2023 = 5.7
global inf2024 = 4.5
global inf2025 = 3.4
global inf2026 = 3.0
global inf2027 = 3.0
global inf2028 = 3.0
global inf2029 = 3.0

scalar tasaEfectiva = 6.7358


** 1.3 Perfiles **
capture confirm file "`c(sysdir_personal)'/SIM/`=anioenigh'/perfiles`=anioPE'.dta"
if _rc != 0 ///
	noisily run `"`c(sysdir_personal)'/PerfilesSim.do"' `=anioPE'



*********************************/
***                            ***
**#    2. MÓDULOS SIMULADOR    ***
***                            ***
**********************************
******************************
** 2.1 Parámetros: Ingresos **
scalar ISRAS       =   3.666 // *(1+ r(EISRAS)*(${pib2023}-${pib2023_0})/100)) 		// ISR (asalariados)
scalar ISRPF       =   0.232 // *(1+ r(EISRPF)*(${pib2023}-${pib2023_0})/100)) 		// ISR (personas f{c i'}sicas)
scalar CUOTAS      =   1.567 // *(1+ r(ECUOTAS)*(${pib2023}-${pib2023_0})/100)) 	// Cuotas (IMSS)

scalar FMP         =   0.888 // *(1+ r(EFMP)*(${pib2023}-${pib2023_0})/100)) 		// Fondo Mexicano del Petróleo
scalar PEMEX       =   2.179 // *(1+ r(EPEMEX)*(${pib2023}-${pib2023_0})/100)) 		// Organismos y empresas (Pemex)
scalar CFE         =   1.309 // *(1+ r(ECFE)*(${pib2023}-${pib2023_0})/100)) 		// Organismos y empresas (CFE)
scalar IMSS        =   0.124 // *(1+ r(EIMSS)*(${pib2023}-${pib2023_0})/100)) 		// Organismos y empresas (IMSS)
scalar ISSSTE      =   0.156 // *(1+ r(EISSSTE)*(${pib2023}-${pib2023_0})/100)) 	// Organismos y empresas (ISSSTE)

scalar ISRPM       =   4.036 // *(1+ r(EISRPM)*(${pib2023}-${pib2023_0})/100)) 		// ISR (personas morales)
scalar OTROSK      =   1.036 // *(1+ r(EOTROSK)*(${pib2023}-${pib2023_0})/100)) 	// Productos, derechos, aprovech.

scalar IVA         =   3.895 // *(1+ r(EIVA)*(${pib2023}-${pib2023_0})/100)) 		// IVA
scalar ISAN        =   0.057 // *(1+ r(EISAN)*(${pib2023}-${pib2023_0})/100)) 		// ISAN
scalar IEPSNP      =   0.678 // *(1+ r(EIEPSNP)*(${pib2023}-${pib2023_0})/100))		// IEPS (no petrolero)
scalar IEPSP       =   1.336 // IEPS (petrolero): 0.662
scalar IMPORT      =   0.299 // *(1+ r(EIMPORT)*(${pib2023}-${pib2023_0})/100))		// Importaciones


*******************************
** 2.2 Parámetros: Educación **
scalar iniciaA     =     417 //    Inicial

scalar basica      =   28107 //    Educación b{c a'}sica
scalar medsup      =   27811 //    Educación media superior
scalar superi      =   39927 //    Educación superior
scalar posgra      =   65408 //    Posgrado
scalar eduadu      =   39492 //    Educación para adultos
scalar otrose      =    1737 //    Otros gastos educativos

scalar invere      =     827 //    Inversión en educación

scalar cultur      =     153 //    Cultura, deportes y recreación
scalar invest      =     393 //    Ciencia y tecnología


***************************
** 2.3 Parámetros: Salud **
scalar ssa         =     107 //    SSalud
scalar imssbien    =    5560 //    IMSS-Bienestar
scalar imss        =    8573 //    IMSS (salud)
scalar issste      =    9873 //    ISSSTE (salud)
scalar pemex       =   31176 //    Pemex (salud)
scalar issfam      =   20070 //    ISSFAM (salud)

scalar invers      =     255 //    Inversión en salud


*******************************
** 2.4 Parámetros: Pensiones **
scalar pam         =    9286 //    Pensión Bienestar
scalar penimss     =  279557 //    Pensión IMSS
scalar penisss     =  362409 //    Pensión ISSSTE
scalar penpeme     =  822902 //    Pensión Pemex
scalar penotro     = 3629857 //    Pensión CFE, LFC, ISSFAM, Ferronales


*****************************
** 2.5 Parámetros: Energía **
scalar gascfe      =    2884 //    Gasto en CFE
scalar gaspemex    =    1035 //    Gasto en Pemex
scalar gassener    =     638 //    Gasto en SENER

scalar gasinverf   =    3692 //    Gasto en inversión (energía)

scalar gascosdeue  =    1349 //    Gasto en costo de la deuda (energía)


**********************************
** 2.6 Parámetros: Otros gastos **
scalar gasinfra    =    4263 //    Gasto en Otras Inversiones
scalar gasotros    =    4750 //    Otros gastos
scalar gasfeder    =   10185 //    Participaciones y Otras aportaciones
scalar gascosto    =    8539 //    Gasto en Costo de la deuda


***********************************
** 2.7 Parámetros: Transferencas **
scalar IngBas      =       0 //    Ingreso b{c a'}sico
scalar ingbasico18 =       1 //    1: Incluye menores de 18 anios, 0: no
scalar ingbasico65 =       1 //    1: Incluye mayores de 65 anios, 0: no

scalar gasmadres   =     472 //    Apoyo a madres trabajadoras
scalar gascuidados =    1722 //    Gasto en cuidados


*************************
** 2.8 Parámetros: ISR **
** Inputs: Archivo "`c(sysdir_personal)'/SIM/perfiles`=anioPE'.dta" o "`c(sysdir_site)'/users/$pais/$id/households.dta"
** Outputs: Archivo "`c(sysdir_site)'/users/$pais/$id/households.dta" actualizado más scalars ISRAS, ISRPF, ISRPM y CUOTAS.
* Anexo 8 de la Resolución Miscelánea Fiscal para 2023 *
* Tarifa para el cálculo del impuesto correspondiente al ejericio 2023 (página 782) *
*             INFERIOR			SUPERIOR	CF		TASA
matrix ISR =  (0.01,			8952.49,	0.0,		1.92	\    /// 1
			8952.49    +.01,	75984.55,	171.88,		6.40	\    /// 2
			75984.55   +.01,	133536.07,	4461.94,	10.88	\    /// 3
			133536.07  +.01,	155229.80,	10723.55,	16.00	\    /// 4
			155229.80  +.01,	185852.57,	14194.54,	17.92	\    /// 5
			185852.57  +.01,	374837.88,	19682.13,	21.36	\    /// 6
			374837.88  +.01,	590795.99,	60049.40,	23.52	\    /// 7
			590795.99  +.01,	1127926.84,	110842.74,	30.00	\    /// 8
			1127926.84 +.01,	1503902.46,	271981.99,	32.00	\    /// 9
			1503902.46 +.01,	3511707.37,	392294.17,	34.00	\    /// 10
			3511707.37 +.01,	1E+12,		1414947.85,	35.00)	     //  11

* Tabla del subsidio para el empleo aplicable a la tarifa del numeral 5 del rubro B (página 773) *
*             INFERIOR		SUPERIOR	SUBSIDIO
matrix	SE =  (0.01,		1768.96,	407.02		\    /// 1
			1768.96 +.01,	2653.38,	406.83		\    /// 2
			2653.38 +.01,	3472.84,	406.62		\    /// 3
			3472.84 +.01,	3537.87,	392.77		\    /// 4
			3537.87 +.01,	4446.15,	382.46		\    /// 5
			4446.15 +.01,	4717.18,	354.23		\    /// 6
			4717.18 +.01,	5335.42,	324.87		\    /// 7
			5335.42 +.01,	6224.67,	294.63		\    /// 8
			6224.67 +.01,	7113.90,	253.54		\    /// 9
			7113.90 +.01,	7382.33,	217.61		\    /// 10
			7382.33 +.01,   1E+12,		0)		 	     //  11

* Artículo 151, último párrafo (LISR) *
*            Ex. SS.MM.	Ex. 	% ing. gravable		% Informalidad PF	% Informalidad Salarios
matrix DED = (5,				15,					70.62, 				89.07)

* Artículo 9, primer párrafo (LISR) * 
*           Tasa ISR PM.	% Informalidad PM
matrix PM = (30,			28.08)


***********************************
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
	noisily run "`c(sysdir_personal)'/ISRPF_Mod.do"
	scalar ISRAS  = ISR_AS_Mod
	scalar ISRPF  = ISR_PF_Mod
}

if "`cambioisrpm'" == "1" {
	noisily run "`c(sysdir_personal)'/ISRPM_Mod.do"
	scalar ISRPM  = ISR_PM_Mod
}

if "`cambioisrpf'" == "1" {
	noisily run "`c(sysdir_personal)'/CUTOAS_Mod.do"
	scalar CUOTAS = CUOTAS_Mod
}


**************************
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


***************************
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


*********************************/
** 2.12 Integración de módulos ***
noisily TasasEfectivas, anio(`=anioPE')
noisily GastoPC, aniope(`=anioPE') aniovp(2024)





*****************************/
***                        ***
**#    3. CICLO DE VIDA    ***
***                        ***
******************************
capture use `"`c(sysdir_personal)'/users/$id/ingresos.dta"', clear
capture merge 1:1 (folioviv foliohog numren) using "`c(sysdir_personal)'/users/$id/gastos.dta", nogen replace update
if _rc != 0 {
	use "`c(sysdir_personal)'/SIM/perfiles`=anioPE'.dta", clear
}


**************************************
** 3.1 (+) Impuestos y aportaciones **
capture drop ImpuestosAportaciones
egen ImpuestosAportaciones = rsum(ISRAS ISRPF CUOTAS ISRPM IVA IEPSNP IEPSP ISAN IMPORT) //OTROSK
label var ImpuestosAportaciones "impuestos y aportaciones"


**************************************
** 3.2 (-) Impuestos y aportaciones **
capture drop Transferencias
egen Transferencias = rsum(Pension Educación Salud IngBasico Pensión_AM Otras_inversiones)
label var Transferencias "transferencias públicas"


********************************
** 3.3 (=) Aportaciones netas **
capture drop AportacionesNetas
g AportacionesNetas = ImpuestosAportaciones - Transferencias
label var AportacionesNetas "aportaciones netas"
noisily Simulador AportacionesNetas [fw=factor], reboot aniovp(2024) aniope(`=anioPE') $nographs //boot(20)


************************************
** 3.4 (*) Cuentas generacionales **
//noisily CuentasGeneracionales AportacionesNetas, anio(`=anioPE') discount(7)



** (*) Sankey **
foreach k in decil grupoedad sexo /*rural escol*/ {
	noisily run "`c(sysdir_personal)'/SankeySF.do" `k' `=aniovp'
}





********************************************/
***                                       ***
**#    4. PARTE IV: DEUDA + FISCAL GAP    ***
***                                       ***
*********************************************
** Inputs: Archivo "`c(sysdir_site)'/users/$pais/$id/households.dta", SHRFSP, PEFs y LIFs.
** Outputs: Sostenibilidad de la deuda y brecha fiscal hasta 2030.
noisily FiscalGap, anio(`=anioPE') end(2030) aniomin(2016) $nographs desde(2016) discount(10) //update //anio(`=aniovp')





***************************/
****                    ****
****    Touchdown!!!    ****
****                    ****
****************************
if "$textbook" == "textbook" {
	noisily scalarlatex, logname(tasasEfectivas)
}
if "$output" == "output" {
	run "`c(sysdir_personal)'/output.do"
}
timer off 1
timer list 1
noisily di _newline(2) in g _dup(20) ":" "  " in y "TOUCH-DOWN!!!  " round(`=r(t1)/r(nt1)',.1) in g " segs  " _dup(20) ":"
