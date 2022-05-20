import pandas as pd

def get_historical_elect():
    # read excel file
    excel_file = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fplocal_cs361/thornton_data/Thornton Utilities 2019.xlsx"
    df = pd.read_excel(excel_file, usecols="A:D", skiprows=2)

    # convert and save electrical data in another csv 
    kwh_to_joules = 3.6e6
    df_elect = pd.DataFrame(list(df["Electricity (kWh)"] * kwh_to_joules))

    # save to csv 
    csv_dir_path = "/Users/julietnwagwuume-ezeoke/My Drive/CS361_Optim/_fp_cs361/hist_data"
    df_elect.to_csv(f"{csv_dir_path}/elect.csv")   


def main():
    get_historical_elect()



if __name__ == "__main__":
    main()
