#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import matplotlib.pylab as plt
import seaborn as sns
plt.style.use('ggplot')
pd.set_option('max_columns', 200)


# In[3]:


# Data set taken from https://www.kaggle.com/datasets/robikscube/rollercoaster-database
# Import Data Set
df = pd.read_csv('C:\\Users\\seven\\Downloads\\coaster_db.csv')


# In[4]:


# See how many rows and columns are in data set
df.shape


# In[8]:


# Cursory look at how the data is laid out
df.head(5)


# In[9]:


# View list of columns
df.columns


# In[11]:


# Check what type of columns they are
df.dtypes


# In[12]:


# Get information on the numeric data
df.describe()


# In[22]:


# Data Cleaning
# Added complete column set, then commented out uneeded columns and reran, then reassigned dataframe
df = df[['coaster_name', 
    #'Length', 'Speed', 
    'Location', 'Status', 
    #'Opening date',
    #'Type', 
    'Manufacturer', 
    #'Height restriction', 'Model', 'Height',
    #'Inversions', 'Lift/launch system', 'Cost', 'Trains', 'Park section',
    #'Duration', 'Capacity', 'G-force', 'Designer', 'Max vertical angle',
    #'Drop', 'Soft opening date', 'Fast Lane available', 'Replaced',
    #'Track layout', 'Fastrack available', 'Soft opening date.1',
    #'Closing date', 
    #'Opened', 
    #'Replaced by', 'Website',
    #'Flash Pass Available', 'Must transfer from wheelchair', 'Theme',
    #'Single rider line available', 'Restraint Style',
    #'Flash Pass available', 'Acceleration', 'Restraints', 'Name',
    'year_introduced', 'latitude', 'longitude', 'Type_Main',
    'opening_date_clean', 
    #'speed1', 'speed2', 'speed1_value', 'speed1_unit',
    'speed_mph', 
    #'height_value', 'height_unit', 
    'height_ft',
    'Inversions_clean', 'Gforce_clean']].copy()
# Also could have used df.drop(['selected_columns'], axis = 1), etc to get same result


# In[23]:


# Verify data frame has been reduced
df.shape
# It is (1087,13)


# In[24]:


# Re-review column types
df.dtypes


# In[26]:


# Change opening_date_clean from object to datetime64 column
df['opening_date_clean'] = pd.to_datetime(df['opening_date_clean'])


# In[61]:


# Rename Columns and rewrite data frame
df = df.rename(columns ={'coaster_name':'Coaster Name',
                   'year_introduced':'Year Introduced',
                   'opening_date_clean':'Opening Date',
                   'speed_mph':'Speed (mph)',
                   'height_ft':'Height (feet)',
                   'Inversions_clean':'Inversions',
                   'Gforce_clean':'GForce'})


# In[62]:


#verify Changes
df.head()


# In[63]:


# Check for Null Values (NaN)
df.isna().sum()
# Will clean if Null Values affect data visualizations


# In[64]:


# Check for Duplicates
df.duplicated()
# Looks good, but running .loc to be sure


# In[65]:


# Confirmed no duplicates
df.loc[df.duplicated()]


# In[66]:


# Check for repeats
df.loc[df.duplicated(subset=['Coaster Name'])].head(5)


# In[74]:


# Checking first row returend for what the duplicate looks like
df.query('Location == "Crystal Beach Park"')
# Different Year Introduced entries


# In[75]:


# Referencing Columns again
df.columns


# In[81]:


# Looking up rows that are NOT duplicates (97 duplicate rows, 990 unique rows (1087 total rows))
# Save as data frame
# df.loc[df.duplicated(subset=['Coaster Name','Location','Opening Date'])]
df = df.loc[~df.duplicated(subset=['Coaster Name','Location','Opening Date'])]


# In[84]:


# Duplicate rows deleted and data frame saved
df = df.loc[~df.duplicated(subset=['Coaster Name','Location','Opening Date'])] \
    .reset_index(drop=True).copy()


# In[85]:


# Verifying
df.shape


# In[86]:


# Building Data Visuals
df['Year Introduced'].value_counts()


# In[87]:


# I don't need every year, just the top 10 years where the most roller coasters were debuted.
df['Year Introduced'].value_counts() \
    .head(10)


# In[105]:


# Make a Bar Chart of Top 10 Years Roller Coasters were Introduced
ax = df['Year Introduced'].value_counts() \
    .head(10) \
    .plot(kind ='bar', title = 'Top 10 Years Coasters Introduced')
ax.set_xlabel('Year of Release')
ax.set_ylabel('Amount')
plt.show()


# In[104]:


# Make a Histogram showing Speed metrics
df['Speed (mph)'].plot(kind = 'hist',
                        bins = 20,
                        title = 'Roller Coaster Speed (mph)')
ax.set_xlabel('Speed (mph)')
plt.show()


# In[103]:


# Make a Density Plot showing same metrics as above
df['Speed (mph)'].plot(kind = 'kde',
                       title = 'Roller Coaster Speed (mph)')
ax.set_xlabel('Speed (mph)')
plt.show()


# In[102]:


# Make a Scatter Plot showing relation to Height and Speed of Roller Coaster
df.plot(kind = 'scatter',
        x = 'Speed (mph)',
        y = 'Height (feet)',
        title = 'Coaster Speed vs. Height')
plt.show()


# In[112]:


# Make a Scatterplot with a Legend
ax = sns.scatterplot(x = 'Speed (mph)',
                     y = 'Height (feet)',
                     hue = 'Year Introduced',
                     data = df)
ax.set_title('Coaster Speed vs. Height')
plt.show()


# In[113]:


# Make a Pairplot
sns.pairplot(df,
             vars = ['Year Introduced', 'Speed (mph)', 'Height (feet)', 'Inversions', 'GForce'],
             hue = 'Type_Main')
plt.show()
# Threw future warning due to Nulls being in data frame


# In[114]:


# Finally, where are the locations with the fastest Roller Coasters (minimum of 10)?
ax = df.query('Location != "Other"') \
     .groupby('Location')['Speed (mph)'] \
     .agg(['mean','count']) \
     .query('count >= 10') \
     .sort_values('mean')['mean'] \
     .plot(kind = 'barh', figsize = (12,5), title = 'Average Roller Coaster Speed by Location')
ax.set_xlabel('Average Coaster Speed')
plt.show()


# In[ ]:




