import pandas as pd
import numpy as np
import datetime as dt
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib import cm, rcParams
from matplotlib import rc, font_manager
import matplotlib.patches as  mpatches
import matplotlib.gridspec as gridspec
import statsmodels.formula.api as smf # load the econometrics package
import warnings
warnings.filterwarnings('ignore')
from scipy.stats.mstats import winsorize
import seaborn as sns
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()

plt.rcParams.update({
    "text.usetex": True,
    "font.family": "sans-serif",
    "font.sans-serif": ["Helvetica"]})

sizeOfFont = 18
ticks_font = font_manager.FontProperties(size=sizeOfFont)


def settings_plot(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    return ax

# load manager panel
# --------------------------
manager_data=pd.read_csv("../data/manager_panel.csv.gz",index_col=0)


# Load ETF panel and apply Broman-Shum (2018) filters
# ----------------------------------------------------
etf_panel=pd.read_csv("../data/etf_panel_raw.csv")
# keep ETFs with at least 10 quarters of data, and exclude the first 2 quarters of an ETF existence
# (Broman-Shum, 2018)

# convert inception day for ETF
etf_panel['inception']=etf_panel['inception'].apply(lambda x: dt.datetime.strptime(x, "%d/%m/%Y"))
# compute inception quarter and conver it to decimal format
etf_panel['inception_q']=etf_panel['inception'].dt.year*10+etf_panel['inception'].dt.quarter
etf_panel['quarter_decimal']=etf_panel['quarter'].apply(lambda x: int(x/10)+(x%10-1)/4)
etf_panel['inc_quarter_decimal']=etf_panel['inception_q'].apply(lambda x: int(x/10)+(x%10-1)/4)
# compute the time that ETF existed
etf_panel['time_existence']=etf_panel['quarter_decimal']-etf_panel['inc_quarter_decimal']
etf_panel=etf_panel[etf_panel.time_existence>0.5] # FILTER: drop first 0.5 years of existence
etf_panel['quarters_in_sample']=etf_panel.groupby('ticker')['quarter'].transform('count')
etf_panel=etf_panel[etf_panel.quarters_in_sample>=10] # FILTER: keep ETFs with at least 10 quarters in sample

# Keep only the top 2 ETFs by AUM in each index-quarter
def rank_group(df,k,in_column,out_column):
    df[out_column] = df[in_column].rank(method='dense', ascending=False) <= k
    return df
etf_panel=etf_panel.groupby(['index_id','quarter']).apply(lambda x: rank_group(x,2,'aum','top2aum'))
etf_panel=etf_panel[etf_panel.top2aum]
del etf_panel['top2aum']


# get list of ETF tickers
list_ETF_tickers=etf_panel.ticker.drop_duplicates().tolist()
# number of ETFs active in a quarter for an index
etf_panel['etf_per_index']=etf_panel.groupby(['index_id','quarter'])['ticker'].transform('count')

# label the high-fee ETF in each index-quarter
etf_panel['uniquevals']=etf_panel.groupby(['index_id','quarter'])['mer_bps'].transform('nunique')
etf_panel['rank_fee']=etf_panel.groupby(['index_id','quarter'])['mer_bps'].rank(method='dense')
etf_panel['rank_fee']=np.where(etf_panel['uniquevals']==2, etf_panel['rank_fee'],np.nan)
etf_panel['highfee']=np.where(etf_panel['rank_fee']==2,1,
                                np.where(etf_panel['rank_fee']==1,0,np.nan))
etf_panel['highfee']=np.where(etf_panel['etf_per_index']==2, 1*etf_panel['highfee'], np.nan)

# add a dummy if ETF is focused on US equities
index_us=pd.read_csv("../data/indices_uslabel.csv")
etf_panel=etf_panel.merge(index_us,on='index_id',how='left') # dummy is index is US-focused

# load 13-F based duration measure and aggregate across managers (Cremers and Pareek, 2016)
# -----------------------------------------------------------------------------------------
d13furg=pd.read_csv("../data/duration_13F.csv.gz",index_col=0)
d13furg['dollar_pos']=d13furg['shares']*d13furg['prc_crsp']

# compute duration measure
def weighted_avg(x): # function to weigh duration by dollar positions
    return np.average(x['duration'],weights=x['dollar_pos'])

manager_dur=d13furg.groupby(['mgrno','mgrname']).apply(weighted_avg)
manager_dur=manager_dur.reset_index()
manager_dur=manager_dur.rename(columns={0:'mgr_duration'})

d13furg=d13furg.merge(manager_dur,on=['mgrno','mgrname'])


d13furg=d13furg[d13furg.ticker.isin(list_ETF_tickers)] 

cols_mgr=['mgrno','quarter','horizon_perma','type','tax_extend']
d13furg=d13furg.merge(manager_data[cols_mgr],on=['mgrno','quarter'],how='left')
# Follow Broman-Shum (2018) and keep only quasi-indexers and transient investors
d13furg=d13furg[d13furg.horizon_perma.isin(['QIX','TRA'])]

# FILTER: drop rows where institutional ownership > shares outstanding
d13furg['inst_shares']=d13furg.groupby(['ticker','quarter'])['shares'].transform(sum)
d13furg['weight_shares']=d13furg['shares']/d13furg['inst_shares']
d13furg['weight_shares_out']=d13furg['shares']/(1000*d13furg['shrout2'])
d13furg['share_ownership']=d13furg['inst_shares']/(1000*d13furg['shrout2'])
d13furg=d13furg[d13furg.share_ownership<1]

# FILTER: drop managers that existed for less than 2 years in our sample
unique_mgr_qtr=d13furg.drop_duplicates(subset=['mgrno','quarter'])
unique_mgr_qtr['quarter_count']=unique_mgr_qtr.groupby(['mgrno']).cumcount()
unique_mgr_qtr=unique_mgr_qtr[['mgrno','quarter','quarter_count']]
d13furg=d13furg.merge(unique_mgr_qtr, on=['mgrno','quarter'],how='left')
d13furg['quarter_count']=d13furg['quarter_count'].fillna(0)
d13furg=d13furg[d13furg.quarter_count>=8]

# CONTROLS: Compute for each manager-ETF, the time since first investment
d13furg['quarter_decimal']=d13furg['quarter'].apply(lambda x: int(x/10)+(x%10-1)/4)
# first quarter of investment for that investor
d13furg['first_quarter_inv']=d13furg.groupby(['mgrno','ticker'])['quarter_decimal'].transform('first')
d13furg['time_since_first_inv']=d13furg['quarter_decimal']-d13furg['first_quarter_inv']

# Aggregate duration measures into panel

# duration
etf_duration = d13furg.groupby(['ticker',
                                'quarter']).apply(lambda x: 
                                 (x['mgr_duration']*x['shares']).sum()/x['shares'].sum()).reset_index()
etf_duration=etf_duration.rename(columns={0:'mgr_duration'})

# duration for Tax-Insensitive Investors (TII)
etf_duration_tii = d13furg[d13furg.tax_extend=='TII'].groupby(['ticker',
                                'quarter']).apply(lambda x: 
                                 (x['mgr_duration']*x['shares']).sum()/x['shares'].sum()).reset_index()
etf_duration_tii=etf_duration_tii.rename(columns={0:'mgr_duration_tii'})

# duration for Tax-Sensitive Investors (TSI)
etf_duration_tsi = d13furg[d13furg.tax_extend=='TSI'].groupby(['ticker',
                                'quarter']).apply(lambda x: 
                                 (x['mgr_duration']*x['shares']).sum()/x['shares'].sum()).reset_index()
etf_duration_tsi=etf_duration_tsi.rename(columns={0:'mgr_duration_tsi'})

# average time since first investment
etf_time_since_first = d13furg.groupby(['ticker',
                                'quarter']).apply(lambda x: 
                                 (x['time_since_first_inv']*x['shares']).sum()/x['shares'].sum()).reset_index()
etf_time_since_first=etf_time_since_first.rename(columns={0:'time_since_first'})

# put dataframes together
etf_duration=etf_duration.merge(etf_duration_tii,on=['ticker','quarter'],how='left')
etf_duration=etf_duration.merge(etf_duration_tsi,on=['ticker','quarter'],how='left')
etf_duration=etf_duration.merge(etf_time_since_first,on=['ticker','quarter'],how='left')

# Compute share of AUM held by tax-insensitive investors (TII)
# --------------------------------------------------------------------

tax_sensitivity=d13furg.groupby(['ticker','quarter',
                                 'tax_extend']).agg({'shares':sum}).reset_index()
tax_sensitivity['total_shares_sample']=tax_sensitivity.groupby(['ticker','quarter',
                                                                ])['shares'].transform(sum)
tax_sensitivity['ratio_tii']=tax_sensitivity['shares']/tax_sensitivity['total_shares_sample']*100
tax_sensitivity=tax_sensitivity[tax_sensitivity.tax_extend=='TII']
tax_sensitivity=tax_sensitivity[['ticker','quarter','ratio_tii']]

# compute share of AUM held by transient investors (according to Bushee classification)
# --------------------------------------------------------------------

transient=d13furg.groupby(['ticker','quarter','horizon_perma']).agg({'shares':sum}).reset_index()
transient['total_shares_sample']=transient.groupby(['ticker','quarter',
                                                                ])['shares'].transform(sum)
transient['ratio_tra']=transient['shares']/(transient['total_shares_sample'])
transient=transient[transient.horizon_perma=='TRA']
transient=transient[['ticker','quarter','ratio_tra']]

# put together manager-specific measures
etf_measures=etf_duration.merge(tax_sensitivity,on=['ticker','quarter'],
                                 how='outer').merge(transient,on=['ticker','quarter'],how='outer')

# merge into main ETF panel
etf_panel=etf_panel.merge(etf_measures,on=['ticker','quarter'],how='left')

# load StockTwits data
stock_twits=pd.read_csv("../data/stocktwits_etf.csv",index_col=0)
stock_twits['date']=stock_twits['date'].apply(lambda x: dt.datetime.strptime(x,"%Y-%m-%d"))
stock_twits['quarter']=stock_twits['date'].dt.year*10+stock_twits['date'].dt.quarter
stock_twits_q=stock_twits.groupby(['ticker','quarter']).mean()[['number_of_msgs','sum_of_replies',
                                                                'sum_of_likes']].reset_index()
# stock_twits_q['stock_tweets']=(stock_twits_q['number_of_msgs']+stock_twits_q['sum_of_replies']+
#                                  stock_twits_q['sum_of_likes']).apply(lambda x: np.log(x))
stock_twits_q=stock_twits_q.rename(columns={'number_of_msgs':'stock_tweets'})

standardize = lambda x: (x - x.mean()) / x.std()
stock_twits_q['stock_tweets']=scaler.fit_transform(stock_twits_q[['stock_tweets']])
#stock_twits_q['stock_tweets']=winsorize(stock_twits_q['stock_tweets'], limits=(0,0.01))


etf_panel['aum_index']=etf_panel.groupby(['index_id','quarter'])['aum'].transform(sum)
etf_panel['log_aum_index']=etf_panel['aum_index'].map(np.log)
etf_panel=etf_panel.merge(stock_twits_q, on=['ticker','quarter'],how='left')
etf_panel['stock_tweets']=etf_panel['stock_tweets'].fillna(0)

etf_panel['qduration']=pd.qcut(etf_panel['mgr_duration'], q=5, labels=False)+1

etf_graph=etf_panel[(etf_panel.etf_per_index==2)].dropna(subset=['highfee']).copy()

etf_graph.to_csv("../data/etf_panel_processed.csv")


from linearmodels.panel import PanelOLS
etf_graph=etf_graph.set_index(['index_id','quarter'])
etf_graph=etf_graph.dropna()
inv_dur_reg=PanelOLS.from_formula('''mgr_duration ~ 1 + EntityEffects + TimeEffects + stock_tweets + log_aum_index + lend_byAUM_bps + 
                                  marketing_fee_bps + tr_error_bps + perf_drag_bps + d_UIT + time_existence + time_since_first''',data=etf_graph).fit()
etf_graph['dur_resid']=inv_dur_reg.resids
etf_graph['qduration']=pd.qcut(etf_graph['dur_resid'], q=5, labels=False)+1


d13furg=d13furg.merge(etf_graph.reset_index()[['ticker',
                                                     'quarter','highfee']],on=['ticker','quarter'],how='left')



sns.kdeplot(data=d13furg, x='mgr_duration', hue='horizon_perma', common_norm=False)