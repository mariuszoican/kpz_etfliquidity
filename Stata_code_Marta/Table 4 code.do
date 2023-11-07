// Table 4 - Fees and liquidity for competing ETFs
// -------------------------------------

// To do: 
// -1) Re-run each table as is -> put in Latex -> compare with submitted paper (2-way clustering vs not)
// -2) Re-run each table without standardising -> put in Latex -> conclude which version to use
// -3) Re-run each table as is with Talis's code






// Load data
// -------------------------------------
clear all
set more off

//local directory "D:\ResearchProjects\kpz_etfliquidity\"
local directory "U:\kpz_etfliquidity\data_Marta"
import delimited "`directory'\etf_panel_processed"


// // Label variables
// // ---------------------------------

egen time_existence_std=std(time_existence)
egen time_since_first_std=std(time_since_first)
egen log_aum_index_std=std(log_aum_index)
egen lend_byaum_bps_std=std(lend_byaum_bps)
egen marketing_fee_bps_std=std(marketing_fee_bps)
egen tr_error_bps_std=std(tr_error_bps)
egen perf_drag_bps_std=std(perf_drag_bps)
egen turnover_frac_std=std(turnover_frac)
egen other_expense_std=std(other_expenses)
egen fee_waiver_std=std(fee_waivers)
egen creation_fee_std=std(creation_fee)


label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
label variable time_existence_std "ETF age (quarters)"
label variable time_since_first_std "Time since first position"
label variable log_aum_index_std "Log index AUM"
label variable d_uit "Unit investment trust"
label variable lend_byaum_bps_std "Lending income (bps of AUM)"
label variable marketing_fee_bps_std "Marketing expense (bps)"
label variable stock_tweets "Name recognition (Twitter msg.)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"


//// REGRESSIONS MAIN HYPOTHESES
//// ---------------------------------------------------

gen tii_return=ratio_tii * logret_q_lag
**# Bookmark #1
gen profit=aum*mer_bps
gen log_pr=log(profit)

drop log_aum
gen log_aum=log(aum)

label variable ratio_tii "Tax-insensitive investors (TII)"
label variable logret_q_lag "Lagged ETF return"
label variable tii_return "TII $\times$ Lagged ETF return"
label variable mer_bps "MER"
label variable spread_bps_crsp "Relative spread"
label variable log_volume "Log dollar volume"
label variable log_pr "Log profit"
label variable mkt_share "Market share"
label variable log_aum "Log AUM"

reghdfe mer_bps highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_bps_crsp highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)









//WITHOUT STANDARDISING

label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
label variable time_existence "ETF age (quarters)"
label variable time_since_first "Time since first position"
label variable log_aum_index "Log index AUM"
label variable d_uit "Unit investment trust"
label variable lend_byaum_bps "Lending income (bps of AUM)"
label variable marketing_fee_bps "Marketing expense (bps)"
label variable stock_tweets "Name recognition (Twitter msg.)"
label variable tr_error_bps "Tracking error (bps)"
label variable perf_drag_bps "Performance drag (bps)"
label variable turnover_frac "ETF turnover"
label variable other_expenses "Other expenses"
label variable fee_waivers "Fee waivers"
label variable creation_fee "Creation fee"




reghdfe mer_bps highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR2.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe mkt_share highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_bps_crsp highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)







// Robustness (only for same-index ETFs, with std variables)

label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
label variable time_existence_std "ETF age (quarters)"
label variable time_since_first_std "Time since first position"
label variable log_aum_index_std "Log index AUM"
label variable d_uit "Unit investment trust"
label variable lend_byaum_bps_std "Lending income (bps of AUM)"
label variable marketing_fee_bps_std "Marketing expense (bps)"
label variable stock_tweets "Name recognition (Twitter msg.)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"

reghdfe mer_bps highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_bps_crsp highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)




// Robustness (only for same-index ETFs, without std variables)


label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
label variable time_existence "ETF age (quarters)"
label variable time_since_first "Time since first position"
label variable log_aum_index "Log index AUM"
label variable d_uit "Unit investment trust"
label variable lend_byaum_bps "Lending income (bps of AUM)"
label variable marketing_fee_bps "Marketing expense (bps)"
label variable stock_tweets "Name recognition (Twitter msg.)"
label variable tr_error_bps "Tracking error (bps)"
label variable perf_drag_bps "Performance drag (bps)"
label variable turnover_frac "ETF turnover"
label variable other_expenses "Other expenses"
label variable fee_waivers "Fee waivers"
label variable creation_fee "Creation fee"

reghdfe mer_bps highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust2.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_bps_crsp highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\main_table_RR_Robust2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)





//correlations
corr highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return



//correlations without std
corr highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit ratio_tii logret_q_lag tii_return