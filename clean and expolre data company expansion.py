import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt
import seaborn as sns 
startups=pd.read_excel('startup-expansion.xlsx')
startups.info()
startups[['Marketing Spend','Revenue']].describe().round(2)
startups['City'].nunique()
startups['City'].unique()
startups['State'].unique()
startups['State'].value_counts()
startups['Sales Region'].unique()
startups['Sales Region'].value_counts()
startups['Sales Region'].nunique()
startups.isna().sum()
startups.duplicated().sum()
startups.sample(10)
startups['Sales Region'].value_counts()
startups['Sales Region'].value_counts().plot.bar()
startups.groupby('New Expansion').groups
startups[startups['New Expansion']=='Old'].groupby('City').max()['Revenue'].nlargest(10)
startups[startups['New Expansion']=='New'].groupby('City').max()['Revenue'].nlargest(10)
#calculate ROI 
round((startups['Revenue'] / startups['Marketing Spend'])*100)
#calculate ROI 
round((startups['Revenue'] / startups['Marketing Spend'])*100)
startups['Profit']=startups['Revenue'] - startups['Marketing Spend']
startups['ROMS']=round((startups['Profit']/startups['Marketing Spend'])*100,2)
startups['ROMS%']=startups['Marketing Spend']/100
startups['ROMS']/startups['Marketing Spend']
startups.to_csv('startups-expansions-modified.csv')