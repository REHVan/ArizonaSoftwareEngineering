       IDENTIFICATION DIVISION.
       PROGRAM-ID. InCollege.
       AUTHOR. Rafael Hernandez Vantuyl, Andy Ho, Steven Huynh.
       AUTHOR. Joanna Johnson, Lynberg Jean.
       DATE-WRITTEN. September 4th, 2026.
      *    Environment division is required for files
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    Create variable called INPUT-FILE and assigns it to the
      *    Input file
      *    ORGANIZATION = line sequential means each line ends with
      *    a newline character, similar to other languages
           SELECT INPUT-FILE
           ASSIGN TO "InCollege-Input.txt"
           ORGANIZATION IS LINE SEQUENTIAL.
           
       DATA DIVISION.
       FILE SECTION.
      *    File descriptor and record required for file processing
      *    Record defines layout of the input.
      *    We have our input file as just a singular user input per line
      *    So we create a variable that fits all choices a user can make
       FD INPUT-FILE.
           01 INPUT-RECORD.
               05 USER-INPUT PIC X(50).
       WORKING-STORAGE SECTION.
           01 EOF PIC X(1) VALUE 'N'.
       PROCEDURE DIVISION.
      *    Start of program, opens file and displays menu
           OPEN INPUT INPUT-FILE
           DISPLAY "Welcome to InCollege!".
           DISPLAY "Log In".
           DISPLAY "Create New Account.".
           DISPLAY "Enter your choice: " WITH NO ADVANCING.
      *    Each instance of the reading verb will read one of what our
      *    organization is. In our case, each use of read will read
      *    one line from our file.
           READ INPUT-FILE.
           
      *    Check if user inputted to login or create new account
      *    PERFORM is very similar to function call. will jump to 
      *    LOGIN and CREATE function depending on input
      *    Note that execution will return here when function finishes.
           IF USER-INPUT = "Log In"
               DISPLAY USER-INPUT
               PERFORM LOGIN

           ELSE
               IF USER-INPUT = "Create New Account"
                   DISPLAY USER-INPUT
                   PERFORM CREATE-ACCOUNT.
       LOGIN.
      *    This print statement is just for debugging
           DISPLAY "LOGIN PART".
           DISPLAY "Please enter your username: " WITH NO ADVANCING.
           READ INPUT-FILE.
           DISPLAY USER-INPUT.
           DISPLAY "Please enter your password: " WITH NO ADVANCING.
           READ INPUT-FILE.
           DISPLAY USER-INPUT.
      *    TODO Check if user exists
           DISPLAY "Logged in Successfully!"
      *    Transition into post login.
           CLOSE INPUT-FILE.
           STOP RUN.

       CREATE-ACCOUNT.
           DISPLAY "CREATE ACCOUNT PART".
           DISPLAY "Please enter your username: " WITH NO ADVANCING.
           READ INPUT-FILE.
           DISPLAY USER-INPUT.
      *    To do: password validation    
           DISPLAY "Please enter your password: " WITH NO ADVANCING.
           READ INPUT-FILE.
           DISPLAY USER-INPUT.
           DISPLAY "Account Created!"
      *    Transition into post login.
           CLOSE INPUT-FILE.
           STOP RUN.
