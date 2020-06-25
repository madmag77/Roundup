# Roundup by Artem Goncharov

This app is an implementation of the Roundup functionality. 

## How to run the app
Just open the project in xCode and press Ctrl-R (no pods install, no code generation have been used)

## How it works
Once the App is started it:
1. Checks if more than a week passed from the last roundup (persisted locally, so can be hacked by reinstalling the app)
2. Checks all accounts of the user (right now user is being defined by his token) and chooses the first account in the list
3. Checks the list of all saving goals and shoose the first one
4. Fetches all transactions in a week and calculates a roundup amount
5. User then can transfer the above mentioned roundup amount from the account (2) to the saving goal (3) by tapping on the only button
6. Stores the roundup transfer date locally

## Assumptions
1. All transactions in an account have same currency (same as in the account itself)
2. All saving goals in an account inherit its currency
3. User doesn't want to include in round up the internal transactions and not yet settled transactions

## Limitations
1. An account, a saving goal and a week are being chosen automatically to save dev time
2. In case of any error user needs to restart the app
3. No login procedure - user is being determine by token

## Implementation specifics
1. No third party libs are being used
2. System design is something in between of MVI and MVP
3. Unit tests for the most crucial parts - Roundup Calculator and Business logic (not all of branches are covered because of time pressure)
4. Unit tests of Asynchronous Bussiness logic have been done in a synchronous way (no increase of testing time)

## If I have more time I would
1. Add more unit tests for Business logic and a little for Presenter
2. Split big functions in Business logic and presenter
3. Add choice of account, saving goal and week for the user

P.S. Sorry, no commit history...
