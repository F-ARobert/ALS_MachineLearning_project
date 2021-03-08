import pandas as pd
from sklearn.preprocessing import OneHotEncoder

data = pd.read_csv('raw_data.csv', delimiter=';')
data = data.set_index("ImgID")
print(data.head())
print(data.loc['6260SOL-D10'])
print(data.loc['6260SOL-D10'].shape)
shape = data.loc['6260SOL-D10'].shape
num_elements = shape[0]
print(num_elements)
data = data.drop('NMJ_id', axis=1)
print(data.head())
data = pd.get_dummies(data)
print(data.head())
data = data.groupby(level='ImgID').sum()
print(data.head())
data.to_csv('data.csv', index=True)