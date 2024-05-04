#!/bin/bash

clie="clients.csv"
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

insertNewCustomer() {
	echo "Enter VAT Number: "
	read numberVat
	
	isExisting=$(grep  ";$numberVat;" "$clients")
	if [[ $isExisting  ]]; then
		echo "The Customer already exists!"
		read id name address email vatNumber status <<< "$isExisting"
		displayCustomer $id $name $address $email $vatNumber $status
		if [[ $status == "I"  ]]; then
			echo "Do you want to activate customer? (y/n)"
			read reply
			if [[ $reply=="yes" || $reply=="y" ]]; then
				sed -i.bak "${id}s/;I/;A/" clients.csv
                		echo "Customer Activated!"
			fi
		fi
	else
		echo "Enter Customer Name: "
		read name
		echo "Enter Address: "
		read address
		echo "Enter Mail: "
		read mail
		id=$(sed -n '$p' "$clients" | cut -c1)
		((id+=1))
		echo -e "$id;$name;$address;$mail;$numberVat;A" >> clients.csv
		echo "Customer Registered."
	fi
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

report() {
	echo "1) Report By Customer"
	echo "2) Report By Calls Date"
	echo "3) Back to Main Menu"
	read -p "Choose an option: " reportOption
	
	case $reportOption in
		1)
		    ;;
		2)
		    echo "Enter Date (DD-MM-YYYY):"
		    read reportDate
		    echo "Calls at $reportDate:"
		    while read id number date duration
		    do
			if [[ $date == $reportDate  ]]; then
			    customer_info=$(grep "^$id;" clients.csv)
                    	    name=$(echo $customer_info | cut -d ';' -f 2)
                            echo "$name - $number - $duration minutes"
			fi
		    done < "$calls"
		    ;;
		3)
		    return
		    ;;
		4)
		    echo "Invalid option!"
		    ;;
	esac
}	


inactivateCustomer() {
	echo "Enter ID of Customer: "
	read id
	getCustomer=$(grep "$id;" "$clients")
	if [[ $getCustomer  ]]; then
		sed -i.bak "${id}s/;A/;I/" clients.csv
        	echo "Customer Inactivated!"
	else 
		echo "Customer not found!"
	fi
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
	    insertNewCustomer
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
	    report
	    ;;
	5)
	    clear
	    inactivateCustomer
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
