// project:			Climate Change and Labor Reallocation: Evidence from Six Decades of the Indian Census
// author:			Liu-Shamdasani-Taraz
// program: 		lst-sa-table_3.do
// task:			generate Table 3
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

* Rename long-difference variables 
	rename *1191_8161 diff_*	

* Define locals 
	local dvar1 		"tot_al_p_lfshare"
	local dvar2 		"tot_nonagri_p_lfshare"
	local dvar3 		"urban_pop_share"
	local dvar4 		"mig_sadt_share_mru"
	local ivar1 		"diff_LA0_9t_kr"
	local ivar3 		"diff_LA0_9p_kr"
	local ilab1			"T"
	local ilab3			"P"

/* 
STEP THREE
MAKE TABLE
*/
	local c "1"
	foreach d in 1 2 3 4 {
	* District clustering
		reg diff_l`dvar`d'' `ivar1' `ivar3' i.region_id if l`dvar`d''_bal==1 & year==1961, cluster(district_id)
		local obs_d`d'_c`c' = string(e(N),"%9.0fc")
		foreach i in 1 3 {
			local b_xt_d`d'_c`c'_i`i' = 	string(_b[`ivar`i''], "%9.4fc")
			local se_xt_d`d'_c`c'_i`i' = 	string(_se[`ivar`i''], "%9.4fc")
			local t_xt_d`d'_c`c'_i`i' =		_b[`ivar`i'']/_se[`ivar`i'']
			local p1_xt_d`d'_c`c'_i`i' =	cond(abs(`t_xt_d`d'_c`c'_i`i'')>invnormal(0.95), "*", "")
			local p2_xt_d`d'_c`c'_i`i' =	cond(abs(`t_xt_d`d'_c`c'_i`i'')>invnormal(0.975), "*", "")
			local p3_xt_d`d'_c`c'_i`i' =	cond(abs(`t_xt_d`d'_c`c'_i`i'')>invnormal(0.995), "*", "")
			local p_xt_d`d'_c`c'_i`i'	 	`p1_xt_d`d'_c`c'_i`i''`p2_xt_d`d'_c`c'_i`i''`p3_xt_d`d'_c`c'_i`i''
		}	
   	* Spatial clustering
		acreg diff_l`dvar`d'' `ivar1' `ivar3' i.region_id if l`dvar`d''_bal==1 & year==1961, latitude(latitude) longitude(longitude) dist(500) spatial
		foreach i in 1 3 {
			local b_co_d`d'_c`c'_i`i' = 	string(_b[`ivar`i''], "%9.4fc")
			local se_co_d`d'_c`c'_i`i' = 	string(_se[`ivar`i''], "%9.4fc")
			local t_co_d`d'_c`c'_i`i' =		_b[`ivar`i'']/_se[`ivar`i'']
			local p1_co_d`d'_c`c'_i`i' =	cond(abs(`t_co_d`d'_c`c'_i`i'')>invnormal(0.95), "*", "")
			local p2_co_d`d'_c`c'_i`i' =	cond(abs(`t_co_d`d'_c`c'_i`i'')>invnormal(0.975), "*", "")
			local p3_co_d`d'_c`c'_i`i' =	cond(abs(`t_co_d`d'_c`c'_i`i'')>invnormal(0.995), "*", "")
			local p_co_d`d'_c`c'_i`i' 	 	`p1_co_d`d'_c`c'_i`i''`p2_co_d`d'_c`c'_i`i''`p3_co_d`d'_c`c'_i`i''
		} 
	}	

* Define output location
	cap file close reg_output
	local file "Figures/lst-table_3.tex"

* Table header
	file open reg_output using "`file'", write replace
	foreach mc in 1 2 3 4 {				
		file write reg_output " &\multicolumn{1}{c}{(`mc')} " 
	}
	file write reg_output " \\ "  _n 			
	file write reg_output "\hline" _n

* Table core 
	foreach i in 1 3 {
		file write reg_output "`ilab`i''"
		foreach d in 1 2 3 4 {
			foreach c in 1 {
				file write reg_output " & `b_xt_d`d'_c`c'_i`i'' "
			}
		}
		file write reg_output " \\ " _n
		foreach d in 1 2 3 4 {
			foreach c in 1 {
				file write reg_output " & (`se_xt_d`d'_c`c'_i`i'')`p_xt_d`d'_c`c'_i`i'' "						
			}
		}
		file write reg_output " \\ " _n

		foreach d in 1 2 3 4 {
			foreach c in 1 {
				file write reg_output " & [`se_co_d`d'_c`c'_i`i'']`p_co_d`d'_c`c'_i`i'' "					
			}
		}
		file write reg_output " \\ " _n       
		file write reg_output "[1em]" _n
	}

* Table footer 
	file write reg_output "\hline" _n 
	file write reg_output "Region FE & Y & Y & Y & Y \\" _n 
	file write reg_output "Observations "
	foreach d in 1 2 3 4 {
		foreach c in 1 {
			file write reg_output " & `obs_d`d'_c`c'' "
		}
	}			
	file write reg_output " \\ " _n
	file close reg_output 					

	
	
/* 
STEP FOUR
P-VALUE IN TEXT: COMPARING PANEL AND LONG-DIFF ESTIMATES
*/	
	foreach d in 1 2 {
	* Run panel FE regression (for comparison purposes)
		reg l`dvar`d'' LA0_9t_kr LA0_9p_kr i.year i.region_id#c.year i.district_id if l`dvar`d''_bal==1
		eststo reg1

	* Run long-diff regression: 30 year: 1981 to 2011 and test equality of coefficients against panel version
		reg diff_l`dvar`d'' diff_LA0_9t_kr diff_LA0_9p_kr i.region_id if l`dvar`d''_bal==1 & year==1961
		eststo reg2
		suest reg1 reg2, cluster(district_id)
		test [reg1_mean]LA0_9t_kr=[reg2_mean]diff_LA0_9t_kr
		estadd scalar pval = r(p)
	}
