#!/bin/bash

clients=clients.csv
calls=calls.csv
OLDIFS=$IFS
IFS=';'

displayCustomer() {
	echo "Client ID: $1"
	echo "Name: $2"
	echo "Address: $3"
	echo "Email: $4"
	echo "VAT: $5"
	echo "Status: $6"
}

listAllCustomers() {
	echo "List of All Customers:"
	while read id name address email vatNumber status
	do
	    active="No"
	    [[ $status == "A" ]] && active="Yes"
            displayCustomer $id $name $address $email $vatNumber $status
	    echo "-------------------------------"
	done < "$clients"
}

while true; do
 echo "Choose an Option:"
 echo "1) Insert New Costumer"
 echo "2) List All Customers"
 echo "3) Invoiding"
 echo "4) Reports"
 echo "5) Inactiveta Customer"
 echo "6) Exit"
 read -p "Option: " option

 case $option in
	1)
	    clear
	    ;;
	2)
	    clear
	    listAllCustomers 
            ;;
	3)  
	    clear
	    ;;
        4)
	    clear
	    ;;
	5)
	    clear
	    ;;
	6)
	    echo "Exiting."
	    break
	    ;;
	*)
	    clear
	    echo "Invalid selection, please choose again."
	    ;;
 esac

done
