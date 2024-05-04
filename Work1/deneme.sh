#!/bin/bash

# File paths
customers_file="clients.csv"
calls_file="calls.csv"

# Check if the necessary files exist, if not, create them
[[ ! -f $customers_file ]] && echo "ID;Name;Address;Email;VAT Number;Status" > $customers_file
[[ ! -f $calls_file ]] && echo "Customer ID;Number Dialed;Date;Duration" > $calls_file

# Utility to display formatted customer info
display_customer() {
    echo "Client No.: $1"
    echo "Name: $2"
    echo "Address: $3"
    echo "Email: $4"
    echo "NIF: $5"
    echo "Active: $6"
}

# Function to insert a new customer
insert_customer() {
    echo "Enter the Customer's VAT Number (NIF):"
    read vat_number
    # Check for existing customer
    existing_customer=$(grep ";$vat_number;" "$customers_file")
    if [[ $existing_customer ]]; then
        echo "The customer already exists in the database:"
        IFS=';' read -r id name address email vat_number status <<< "$existing_customer"
        display_customer $id $name $address $email $vat_number $status
        if [[ $status == "I" ]]; then
            echo "Do you want to activate it? (yes/no)"
            read activate
            if [[ $activate == "yes" ]]; then
                sed -i "s/$existing_customer/$(echo $existing_customer | sed 's/;I$/;A/')" "$customers_file"
                echo "Customer Activated!"
            fi
        fi
    else
        echo "Enter the Customer's Name:"
        read name
        echo "Enter Address:"
        read address
        echo "Enter Email:"
        read email
        echo "Enter the Customer's ID:"
        read customer_id
        echo "$customer_id;$name;$address;$email;$vat_number;A" >> "$customers_file"
        echo "Customer file entered!"
    fi
}

# Function to list all customers
list_customers() {
    echo "Listing all customers:"
    while IFS=';' read -r id name address email vat_number status
    do
        active_status="No"
        [[ $status == "A" ]] && active_status="Yes"
        display_customer $id $name $address $email $vat_number $active_status
    done < <(tail -n +2 "$customers_file")
}

# Function for billing
billing() {
    echo "Enter Customer Number:"
    read customer_id
    echo "Finding records for Customer ID: $customer_id"
    total_minutes=0
    total_calls=0
    echo "Invoice"
    while IFS=';' read -r id number dialed date duration
    do
        if [[ $id == $customer_id ]]; then
            echo "$date - $number - $duration minutes"
            total_minutes=$((total_minutes + duration))
            total_calls=$((total_calls + 1))
        fi
    done < <(grep "^$customer_id;" "$calls_file")
    echo "Total Calls > $total_calls"
    echo "Total Minutes > $total_minutes"
    echo "Amount payable > $(awk "BEGIN {printf \"%.2f\", $total_minutes*0.05}") Euros"
}

# Function for reports
reports() {
    echo "Reports Menu:"
    echo "1) By customer"
    echo "2) Calls by Date"
    echo "3) Back to main menu"
    read -p "Choose an option: " report_option
    case $report_option in
        1)
            billing # Reusing billing function for per-customer report
            ;;
        2)
            echo "Enter Date (DD-MM-YYYY):"
            read report_date
            echo "Calls on $report_date:"
            while IFS=';' read -r id number dialed date duration
            do
                if [[ $date == $report_date ]]; then
                    customer_info=$(grep "^$id;" "$customers_file")
                    name=$(echo $customer_info | cut -d ';' -f 2)
                    echo "$name - $number - $duration minutes"
                fi
            done < "$calls_file"
            ;;
        3)
            return
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Function to inactivate a customer
inactivate_customer() {
    echo "Enter the Customer Number:"
    read customer_id
    customer_info=$(grep "^$customer_id;" "$customers_file")
    if [[ $customer_info ]]; then
        sed -i "s/$customer_info/$(echo $customer_info | sed 's/;A$/;I/')" "$customers_file"
        echo "Customer Inactivated!"
    else
        echo "Customer not found."
    fi
}

# Main menu
while true; do
    echo "Choose an option:"
    echo "1) Insert new customer"
    echo "2) List All Customers"
    echo "3) Billing"
    echo "4) Reports"
    echo "5) Inactivate Customer"
    echo "6) Exit"
    read -p "Option: " option

    case $option in
        1)
            insert_customer
            ;;
        2)
            list_customers
            ;;
        3)
            billing
            ;;
        4)
            reports
            ;;
        5)
            inactivate_customer
            ;;
        6)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option, please choose again."
            ;;
    esac
done

