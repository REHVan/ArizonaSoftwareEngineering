       IDENTIFICATION DIVISION.
       PROGRAM-ID. InCollege.
       AUTHOR. Rafael Hernandez Vantuyl, Andy Ho, Steven Huynh.
       AUTHOR. Joanna Johnson, Lynberg Jean.
       DATE-WRITTEN. September 4th, 2026.
      *    Environment division is required for files
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    Input file
           SELECT INPUT-FILE
           ASSIGN TO "InCollege-Input.txt"
           ORGANIZATION IS LINE SEQUENTIAL.
      *    Output log file (KAN-41/42: dual output)
           SELECT OUTPUT-FILE
           ASSIGN TO "InCollege-Output.txt"
           ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD INPUT-FILE.
           01 INPUT-RECORD.
               05 USER-INPUT PIC X(50).
       FD OUTPUT-FILE.
           01 OUTPUT-RECORD PIC X(80).
       WORKING-STORAGE SECTION.
           01 EOF     PIC X(1) VALUE 'N'.
           01 LOG-MSG PIC X(80) VALUE SPACES.

       PROCEDURE DIVISION.
           OPEN INPUT  INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE
           MOVE "Welcome to InCollege!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Log In" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Create New Account." TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Enter your choice: " TO LOG-MSG
           PERFORM WRITE-OUTPUT
           READ INPUT-FILE.

           IF USER-INPUT = "Log In"
               MOVE USER-INPUT TO LOG-MSG
               PERFORM WRITE-OUTPUT
               PERFORM LOGIN
           ELSE
               IF USER-INPUT = "Create New Account"
                   MOVE USER-INPUT TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   PERFORM CREATE-ACCOUNT.

       LOGIN.
           MOVE "LOGIN PART" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Please enter your username: " TO LOG-MSG
           PERFORM WRITE-OUTPUT
           READ INPUT-FILE.
           MOVE USER-INPUT TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Please enter your password: " TO LOG-MSG
           PERFORM WRITE-OUTPUT
           READ INPUT-FILE.
           MOVE USER-INPUT TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Logged in Successfully!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE
           STOP RUN.

       CREATE-ACCOUNT.
           MOVE "CREATE ACCOUNT PART" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Please enter your username: " TO LOG-MSG
           PERFORM WRITE-OUTPUT
           READ INPUT-FILE.
           MOVE USER-INPUT TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Please enter your password: " TO LOG-MSG
           PERFORM WRITE-OUTPUT
           READ INPUT-FILE.
           MOVE USER-INPUT TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Account Created!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE
           STOP RUN.

      *    KAN-41/42: Dual output - display to console AND write to file
      *    TRIM ensures both outputs are identical (no trailing spaces)
       WRITE-OUTPUT.
           MOVE FUNCTION TRIM(LOG-MSG TRAILING) TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD.
