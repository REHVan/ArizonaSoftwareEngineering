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
               05 USER-NAME PIC X(50).
       WORKING-STORAGE SECTION.
       PROCEDURE DIVISION.
           DISPLAY "Welcome to InCollege!".
           DISPLAY "Log In".
           DISPLAY "Create New Account.".
           DISPLAY "Enter your choice: " WITH NO ADVANCING.
       STOP RUN.
