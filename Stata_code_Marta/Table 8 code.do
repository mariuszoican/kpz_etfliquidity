/// Table 8 - Determinants of ETF competition
// -------------------------------------



// Load data
// -------------------------------------
clear all
set more off

local directory "U:\kpz_etfliquidity\data_Marta"
import delimited "`directory'\probit_data_processed"

gen log_aum=log(aum_index)
egen spread_index_std=std(spread_index)
egen ratio_tii_std=std(ratio_tii)
egen ratio_tra_std=std(ratio_tra)
gen major_brand_index=1-d_ownindex
gen numhold_000=num_hold_index/1000

label variable competition "Competition"
label variable log_aum "Log AUM index"
label variable top3_issuer "Top-3 ETF issuer"
label variable major_brand_index "Major brand index"
label variable numhold_000 "Number constituents (000s)"
label variable spread_index_std "Relative spread"
label variable ratio_tii_std "Tax-insensitive investors (% AUM)"
label variable ratio_tra_std "Transient investors (% AUM)"


// // Marius's regressions (with standardized variables)
// // ---------------------------------


probit competition log_aum, vce(robust)
outreg2 using "`directory'\output\probit.tex", replace tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*) 

probit competition log_aum top3_issuer major_brand_index, vce(robust)
outreg2 using "`directory'\output\probit.tex", append tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*)

probit competition log_aum top3_issuer major_brand_index numhold_000, vce(robust)
outreg2 using "`directory'\output\probit.tex", append tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*)

probit competition log_aum top3_issuer major_brand_index numhold_000 spread_index_std, vce(robust)
outreg2 using "`directory'\output\probit.tex", append tex tstat e(r2_p) label  dec(2) tdec(2) eqdrop(/) keep(*)

probit competition log_aum ratio_tra_std top3_issuer major_brand_index numhold_000 spread_index_std , vce(robust)
outreg2 using "`directory'\output\probit.tex", append tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*)

probit competition log_aum ratio_tra_std ratio_tii_std top3_issuer major_brand_index numhold_000 spread_index_std , vce(robust)
outreg2 using "`directory'\output\probit.tex", append tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*)




label variable competition "Competition"
label variable log_aum "Log AUM index"
label variable top3_issuer "Top-3 ETF issuer"
label variable major_brand_index "Major brand index"
label variable numhold_000 "Number constituents (000s)"
label variable spread_index "Relative spread"
label variable ratio_tii "Tax-insensitive investors (% AUM)"
label variable ratio_tra "Transient investors (% AUM)"


// // Without standardized variables)
// // ---------------------------------


probit competition log_aum, vce(robust)
outreg2 using "`directory'\output\probit2.tex", replace tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*) 

probit competition log_aum top3_issuer major_brand_index, vce(robust)
outreg2 using "`directory'\output\probit2.tex", append tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*)

probit competition log_aum top3_issuer major_brand_index numhold_000, vce(robust)
outreg2 using "`directory'\output\probit2.tex", append tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*)

probit competition log_aum top3_issuer major_brand_index numhold_000 spread_index, vce(robust)
outreg2 using "`directory'\output\probit2.tex", append tex tstat e(r2_p) label  dec(2) tdec(2) eqdrop(/) keep(*)

probit competition log_aum ratio_tra top3_issuer major_brand_index numhold_000 spread_index , vce(robust)
outreg2 using "`directory'\output\probit2.tex", append tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*)

probit competition log_aum ratio_tra ratio_tii top3_issuer major_brand_index numhold_000 spread_index , vce(robust)
outreg2 using "`directory'\output\probit2.tex", append tex tstat e(r2_p)  label  dec(2) tdec(2) eqdrop(/) keep(*)
