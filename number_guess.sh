#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUM=$(( RANDOM % 1000 ))
echo $RANDOM_NUM

echo Enter your username:
read UN

# get username
USERNAME=$($PSQL "SELECT username FROM games WHERE username='$UN'")

# if username is not found
if [[ -z $USERNAME ]]
then
  echo -e "\nWelcome, $UN! It looks like this is your first time here."

  # insert username to database
  INSERT_USERNAME=$($PSQL "INSERT INTO games(username) VALUES('$UN')")

  # get new username
  USERNAME=$($PSQL "SELECT username FROM games WHERE username='$UN'") 

# if username exists
else
  # get user info
  USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM games WHERE username='$USERNAME'")
  
  # display user info
  echo $USER_INFO | while IFS="|" read USERN NGAMES BEST
  do
    echo -e "\nWelcome back, $USERN! You have played $NGAMES games, and your best game took $BEST guesses."
  done
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read NUM
GUESS_COUNT=0

# while num is not  an integer
while [[ ! $NUM =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read NUM
done
  

# while guess is incorrect
while [[ $NUM != $RANDOM_NUM  ]]
do
  GUESS_COUNT=$(( $GUESS_COUNT + 1 ))

  # if guess is larger 
  if [[ $NUM > $RANDOM_NUM ]]
  then
    echo -e "\nIt's lower than that, guess again:"

  # if guess is lower
  else
    echo -e "\nIt's higher than that, guess again:"
  fi

  # get new num
  read NUM
done

if [[ $NUM == $RANDOM_NUM ]] 
then
  GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
  echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUM. Nice job!"

  # update games_played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username='$USERNAME'")
  GAMES_PLAYED_NEW=$(( $GAMES_PLAYED + 1 ))
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE games SET games_played=$GAMES_PLAYED_NEW WHERE username='$USERNAME'")

  # if best_game is 0 or lower than previous
  BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username='$USERNAME'")
  if [[ $BEST_GAME == 0 || $GUESS_COUNT < $BEST_GAME ]]
  then
    # update best_game
    UPDATE_BEST_GAME=$($PSQL "UPDATE games SET best_game=$GUESS_COUNT WHERE username='$USERNAME'")
  fi
fi
