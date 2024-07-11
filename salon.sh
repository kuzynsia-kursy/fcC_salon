#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Salon Appointment Scheduler ~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  
  # display available services
  echo -e "Hello! Here are the available services:\n"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "To exit please enter 'Exit'"

  # ask for service to schedule
  echo -e "\nWhat service would you like to schedule?"
  read SERVICE_ID_SELECTED

  # redirect to correct path
  case $SERVICE_ID_SELECTED in
    1) SCHEDULE_APPOINTMENT ;;
    2) SCHEDULE_APPOINTMENT ;;
    3) SCHEDULE_APPOINTMENT ;;
    "Exit") EXIT ;;
    "exit") EXIT ;;
    "EXIT") EXIT ;;
    *) MAIN_MENU "Please enter a valid option" ;;
    esac
}

SCHEDULE_APPOINTMENT() {
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g')
  echo -e "\nYou have chosen $SERVICE_NAME_FORMATTED to book"

  # get customer info
  echo -e "\nWhat if your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  fi

  # when customer exists in db
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # ask about time of service
  echo -e "\nWhat time would you like to start?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  # finish script
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

  EXIT

}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU