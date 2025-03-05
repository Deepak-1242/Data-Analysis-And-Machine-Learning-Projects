import streamlit as st
import pandas as pd
import joblib 
from sklearn.impute import SimpleImputer
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.pipeline import Pipeline


def load_model():
    return joblib.load("Car-Sales-Price-Prediction-Machine-Learning-Model.pkl")

def preprocess_input(data):
    categorical_features = ["Make","Colour"]
    numerical_features = ["Odometer (KM)","Doors"]

    categorical_transformer = OneHotEncoder(handle_unknown="ignore")
    numerical_transformer = SimpleImputer(strategy = "mean")

    train_data = joblib.load("./Csv Files/Train.csv")

    transformer = ColumnTransformer([("one_hot",categorical_transformer,categorical_features)],remainder = "passthrough")

    train_transform = transformer.fit_transform(train_data)

    transformed_data = transformer.transform(data)
    
    return transformed_data



def main():
    st.title("Car Price Prediction App")
    st.write("Enter car details below to predict the price ")
    model = load_model()
    make = st.selectbox("Car Make",["Honda","BMW","Toyota","Nissan"])
    colour = st.selectbox("Car Colour",["White","Blue","Red","Green"])
    odometer = st.number_input("Odometer (KM)", min_value=0, value=50000)
    doors = st.selectbox("Number of Doors", [2, 3, 4, 5])

    if st.button("Predict Price"):
        model = load_model()
        input_data = pd.DataFrame(data = [[make,colour,odometer,doors]],
                                     columns=["Make","Colour","Doors","Odometer (KM)"])

        preprocessed_data = preprocess_input(input_data)
        predicted_price = model.predict(preprocessed_data)

        st.success(f"Estimated Car Price: ${predicted_price[0]:,.2f}")
        
        st.success(preprocessed_data[12])
    


if __name__ =="__main__":
    main()
        






    