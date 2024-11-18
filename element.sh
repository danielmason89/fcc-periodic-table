#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
INPUT=$1

if [[ -z $INPUT ]]; then
  echo "Please provide an element as an argument."
else
  # Determine if the input is a number
  if [[ $INPUT =~ ^[0-9]+$ ]]; then
    DATA=$($PSQL "SELECT elements.atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius
                  FROM elements
                  INNER JOIN properties ON elements.atomic_number = properties.atomic_number
                  INNER JOIN types ON properties.type_id = types.type_id
                  WHERE elements.atomic_number = $INPUT")
  else
    # Check if input is a symbol or a name
    if [[ ${#INPUT} -le 2 ]]; then
      DATA=$($PSQL "SELECT elements.atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius
                    FROM elements
                    INNER JOIN properties ON elements.atomic_number = properties.atomic_number
                    INNER JOIN types ON properties.type_id = types.type_id
                    WHERE symbol = '$INPUT'")
    else
      DATA=$($PSQL "SELECT elements.atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius
                    FROM elements
                    INNER JOIN properties ON elements.atomic_number = properties.atomic_number
                    INNER JOIN types ON properties.type_id = types.type_id
                    WHERE name = '$INPUT'")
    fi
  fi

  # If no data is found
  if [[ -z $DATA ]]; then
    echo "I could not find that element in the database."
  else
    # Parse and format output
    echo "$DATA" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR TYPE BAR MASS BAR MELTING BAR BOILING; do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi
