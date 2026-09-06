       IDENTIFICATION DIVISION.
       PROGRAM-ID. InCollege.
       AUTHOR. Rafael Hernandez Vantuyl, Andy Ho, Steven Huynh.
       AUTHOR. Joanna Johnson, Lynberg Jean.
       DATE-WRITTEN. September 4th, 2026.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE
           ASSIGN TO "InCollege-Input.txt"
           ORGANIZATION IS LINE SEQUENTIAL.
           
       DATA DIVISION.
       FILE SECTION.
       FD INPUT-FILE.
           01 INPUT-RECORD.
               05 USER-INPUT PIC X(50).
       WORKING-STORAGE SECTION.
           01 EOF PIC X(1) VALUE 'N'.
       PROCEDURE DIVISION.
           OPEN INPUT INPUT-FILE
           DISPLAY "Welcome to InCollege!".
           DISPLAY "Log In".
           DISPLAY "Create New Account.".
           DISPLAY "Enter your choice: " WITH NO ADVANCING.

           READ INPUT-FILE.
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
