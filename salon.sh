#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
#Service Menu
MAIN_MENU(){
  # echo message
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi

  # Get Services
  SERVICES=$($PSQL "SELECT * FROM SERVICES")

  # Print Services
  echo "$SERVICES" | while read ID BAR SERVICE
  do
    echo "$ID) $SERVICE"
  done

  # input services
  read SERVICE_ID_SELECTED
  #check if valid
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # IF NUMBER
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ ! -z $SERVICE_NAME ]]
    then
      #GET PHONE NUMBER
      echo -e "What's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      
      # Check if in database
      if [[ -z $CUSTOMER_NAME ]]
      then # Customer not in database
        echo -e "\nI don't have a record for that phone number, what's your name?"

        #insert into database
        read CUSTOMER_NAME
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi

      # Get Service Time
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."



    else # NOT VALID SERVICE REDO
      MAIN_MENU "I could not find that service. What would you like today?"
    fi
  else # IF NOT NUMBER REDO
    MAIN_MENU "I could not find that service. What would you like today?"
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?"
