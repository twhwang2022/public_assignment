// project:			Climate Change and Labor Reallocation: Evidence from Six Decades of the Indian Census
// author:			Liu-Shamdasani-Taraz
// program: 		lst-sa-table_2.do
// task:			generate Table 2
// modifed by Taewon Hwang

/* 
STEP ONE
OPEN DATA
*/

global terminal: env projects
cd "$terminal/public_assignment"
use lst_analysis_PCA288.dta, clear	

ssc install ranktest, replace
ssc install acreg, replace
ssc install estout, replace
ssc install reg2hdfe, replace
ssc install shp2dta, replace
ssc install tmpdir, replace
ssc install geoinpoly, replace
ssc install spmap, replace


/* 
STEP TWO
GET DATA READY FOR TABLE
*/				

* Xtset data
	xtset district_id year

* Define locals 
	local dvar1 		"tot_al_p_lfshare"
	local dvar2 		"tot_nonagri_p_lfshare"
	local dvar3 		"urban_pop_share"
	local dvar4 		"mig_sadt_share_mru"
	local ivar1 		"LA0_9t_kr"
	local ivar3 		"LA0_9p_kr"
	local ilab1			"T"
	local ilab3			"P"
		
/* 
STEP THREE
MAKE TABLE
*/	

* Region-year trends
	local c "1"
	foreach d in 1 2 3 4 {
	* xtreg
		xtreg l`dvar`d'' LA0_9t_kr LA0_9p_kr i.year i.region_id#c.year if l`dvar`d''_bal==1, fe cluster(district_id)
		local obs_d`d'_c`c' = string(e(N),"%9.0fc")
		foreach i in 1 3 {
			local b_xt_d`d'_c`c'_i`i' = 	string(_b[`ivar`i''], "%9.3fc")
			local se_xt_d`d'_c`c'_i`i' = 	string(_se[`ivar`i''], "%9.3fc")
			local t_xt_d`d'_c`c'_i`i' =		_b[`ivar`i'']/_se[`ivar`i'']
			local p1_xt_d`d'_c`c'_i`i' =	cond(abs(`t_xt_d`d'_c`c'_i`i'')>invnormal(0.95), "*", "")
			local p2_xt_d`d'_c`c'_i`i' =	cond(abs(`t_xt_d`d'_c`c'_i`i'')>invnormal(0.975), "*", "")
			local p3_xt_d`d'_c`c'_i`i' =	cond(abs(`t_xt_d`d'_c`c'_i`i'')>invnormal(0.995), "*", "")
			local p_xt_d`d'_c`c'_i`i'	 	`p1_xt_d`d'_c`c'_i`i''`p2_xt_d`d'_c`c'_i`i''`p3_xt_d`d'_c`c'_i`i''
		}			
	* conley
		reg2hdfespatial l`dvar`d'' LA0_9t_kr LA0_9p_kr yearFE* _IregXyear_* if l`dvar`d''_bal==1, timevar(round) panelvar(district_id) lat(latitude) lon(longitude) distcutoff(500) lagcutoff(6)
		foreach i in 1 3 {
			local b_co_d`d'_c`c'_i`i' = 	string(_b[`ivar`i''], "%9.3fc")
			local se_co_d`d'_c`c'_i`i' = 	string(_se[`ivar`i''], "%9.3fc")
			local t_co_d`d'_c`c'_i`i' =		_b[`ivar`i'']/_se[`ivar`i'']
			local p1_co_d`d'_c`c'_i`i' =	cond(abs(`t_co_d`d'_c`c'_i`i'')>invnormal(0.95), "*", "")
			local p2_co_d`d'_c`c'_i`i' =	cond(abs(`t_co_d`d'_c`c'_i`i'')>invnormal(0.975), "*", "")
			local p3_co_d`d'_c`c'_i`i' =	cond(abs(`t_co_d`d'_c`c'_i`i'')>invnormal(0.995), "*", "")
			local p_co_d`d'_c`c'_i`i' 	 	`p1_co_d`d'_c`c'_i`i''`p2_co_d`d'_c`c'_i`i''`p3_co_d`d'_c`c'_i`i''
		} 
	}
	
* Region by decade FE
	local c "2"
	foreach d in 1 2 3 4 {
	* xtreg
		xtreg l`dvar`d'' LA0_9t_kr LA0_9p_kr i.region_year if l`dvar`d''_bal==1, fe cluster(district_id)
		local obs_d`d'_c`c' = string(e(N),"%9.0fc")
		foreach i in 1 3 {
			local b_xt_d`d'_c`c'_i`i' = 	string(_b[`ivar`i''], "%9.3fc")
			local se_xt_d`d'_c`c'_i`i' = 	string(_se[`ivar`i''], "%9.3fc")
			local t_xt_d`d'_c`c'_i`i' =		_b[`ivar`i'']/_se[`ivar`i'']
			local p1_xt_d`d'_c`c'_i`i' =	cond(abs(`t_xt_d`d'_c`c'_i`i'')>invnormal(0.95), "*", "")
			local p2_xt_d`d'_c`c'_i`i' =	cond(abs(`t_xt_d`d'_c`c'_i`i'')>invnormal(0.975), "*", "")
			local p3_xt_d`d'_c`c'_i`i' =	cond(abs(`t_xt_d`d'_c`c'_i`i'')>invnormal(0.995), "*", "")
			local p_xt_d`d'_c`c'_i`i'  		`p1_xt_d`d'_c`c'_i`i''`p2_xt_d`d'_c`c'_i`i''`p3_xt_d`d'_c`c'_i`i''
		}
	* conley
		reg2hdfespatial l`dvar`d'' LA0_9t_kr LA0_9p_kr regionyear* if l`dvar`d''_bal==1, timevar(round) panelvar(district_id) lat(latitude) lon(longitude) distcutoff(500) lagcutoff(6)
		foreach i in 1 3 {
			local b_co_d`d'_c`c'_i`i' = 	string(_b[`ivar`i''], "%9.3fc")
			local se_co_d`d'_c`c'_i`i' = 	string(_se[`ivar`i''], "%9.3fc")
			local t_co_d`d'_c`c'_i`i' =		_b[`ivar`i'']/_se[`ivar`i'']
			local p1_co_d`d'_c`c'_i`i' =	cond(abs(`t_co_d`d'_c`c'_i`i'')>invnormal(0.95), "*", "")
			local p2_co_d`d'_c`c'_i`i' =	cond(abs(`t_co_d`d'_c`c'_i`i'')>invnormal(0.975), "*", "")
			local p3_co_d`d'_c`c'_i`i' =	cond(abs(`t_co_d`d'_c`c'_i`i'')>invnormal(0.995), "*", "")
			local p_co_d`d'_c`c'_i`i'  		`p1_co_d`d'_c`c'_i`i''`p2_co_d`d'_c`c'_i`i''`p3_co_d`d'_c`c'_i`i''
		}
	}

* Define output location  
	cap file close reg_output
	local file "Figures/lst-table_2.tex"

* Table header
	file open reg_output using "`file'", write replace
	foreach mc in 1 2 3 4 5 6 7 8 {				
		file write reg_output " &\multicolumn{1}{c}{(`mc')} " 
	}
	file write reg_output " \\ "  _n 			
	file write reg_output "\hline" _n

* Table core 
	foreach i in 1 3 {
		file write reg_output "`ilab`i''"
		foreach d in 1 2 3 4 {
			foreach c in 1 2 {
				file write reg_output " & `b_xt_d`d'_c`c'_i`i'' "
			}
		}
		file write reg_output " \\ " _n
		foreach d in 1 2 3 4 {
			foreach c in 1 2 {
				file write reg_output " & (`se_xt_d`d'_c`c'_i`i'')`p_xt_d`d'_c`c'_i`i'' "						
			}
		}
		file write reg_output " \\ " _n
		foreach d in 1 2 3 4 {
			foreach c in 1 2 {
				file write reg_output " & [`se_co_d`d'_c`c'_i`i'']`p_co_d`d'_c`c'_i`i'' "					
			}
		}
		file write reg_output " \\ " _n       
		file write reg_output "[1em]" _n
	}

* Table footer 
	file write reg_output "\hline" _n 
	file write reg_output "Region-year trends & Y & N  & Y & N & Y & N & Y & N \\" _n 
	file write reg_output "Region-year FE & N & Y & N & Y & N & Y & N & Y \\" _n 
	file write reg_output "Observations "
	foreach d in 1 2 3 4 {
		foreach c in 1 2 {
			file write reg_output " & `obs_d`d'_c`c'' "
		}
	}			
	file write reg_output " \\ " _n
	file close reg_output 					

	
	
/* 
STEP FOUR
ESTIMATES IN TEXT: TEMPERATURE-ONLY SPECIFICATION
*/

* Region-year trends
	local c "1"
	foreach d in 1 2 3 4 {
	* xtreg
		xtreg l`dvar`d'' LA0_9t_kr  i.year i.region_id#c.year if l`dvar`d''_bal==1, fe cluster(district_id)
	}
	
* Region by decade FE
	local c "2"
	foreach d in 1 2 3 4 {
	* xtreg
		xtreg l`dvar`d'' LA0_9t_kr  i.region_year if l`dvar`d''_bal==1, fe cluster(district_id)
	}
