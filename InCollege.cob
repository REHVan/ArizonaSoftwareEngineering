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
           01 STRING-MESSAGE PIC X(80) VALUE SPACES.
           01 USER-NAME PIC X(80).
           01 IS-VALID PIC X VALUE 'N'.
               88 PASSWORD-VALID VALUE 'Y'.
               88 PASSWORD-INVALID VALUE 'N'.
           01 PASSWORD_isEight PIC X(1) VALUE 'N'.
           01 PASSWORD_notTwelve PIC X(1) VALUE 'N'.
           01 PASSWORD_hasDigit PIC X(1) VALUE 'N'.
           01 PASSWORD_hasNum PIC X(1) VALUE 'N'.
           01 PASSWORD_hasSpec PIC X(1) VALUE 'N'.
           01 PASSWORD_CHARACTER PIC X(1).
       PROCEDURE DIVISION.
           OPEN INPUT  INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE
           MOVE "Welcome to InCollege!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Log In" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Create New Account." TO LOG-MSG
           PERFORM WRITE-OUTPUT
           READ INPUT-FILE.
           STRING "Enter your choice: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SIZE
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
           IF USER-INPUT = "Log In"
               PERFORM LOGIN
           ELSE
               IF USER-INPUT = "Create New Account"
                   PERFORM CREATE-ACCOUNT.
       LOGIN.
           READ INPUT-FILE
           STRING "Please enter your username: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SPACE 
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
           MOVE USER-INPUT TO USER-NAME.
           READ INPUT-FILE
           STRING "Please enter your password: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SPACE 
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
           PERFORM PASSWORD-VALIDATION.
           MOVE "Logged in Successfully!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           PERFORM POST-LOGIN.
       CREATE-ACCOUNT.
           READ INPUT-FILE
           STRING "Please enter your username: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SPACE 
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
           MOVE USER-INPUT TO USER-NAME.
           PERFORM PASSWORD-VALIDATION.
           MOVE "Account Created Successfully!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           PERFORM POST-LOGIN.         

       POST-LOGIN.
           STRING "Welcome, " DELIMITED BY SIZE
                   USER-NAME DELIMITED BY SPACE
                   "!" 
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
           MOVE "1. Search for a job" TO LOG-MSG
           PERFORM WRITE-OUTPUT.
           MOVE "2. Find someone you know" TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           MOVE "3. Learn a new skill" TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           READ INPUT-FILE.
           STRING "Enter your choice: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SPACE
               INTO STRING-MESSAGE
           END-STRING.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
      *    TO DO: MAKE ACTUAL MENU
           CLOSE INPUT-FILE.
           CLOSE OUTPUT-FILE.
           STOP RUN.
       
      
       
       PASSWORD-VALIDATION.
           PERFORM UNTIL IS-VALID
              READ INPUT-FILE.
               MOVE 
               STRING "Please enter your password: " DELIMITED BY SIZE
                       USER-INPUT DELIMITED BY SPACE 
               INTO STRING-MESSAGE
               END-STRING.
               MOVE STRING-MESSAGE TO LOG-MSG.
               PERFORM WRITE-OUTPUT.
               INITIALIZE STRING-MESSAGE.

               IF USER-INPUT(8:1) NOT = SPACE
                   MOVE 1 TO PASSWORD_isEight.
               IF USER-INPUT(12:1) = SPACE.
                   MOVE 1 TO PASSWORD_notTwelve.
               
               PERFORM VARYING
                
      *    KAN-41/42: Dual output - display to console AND write to file
      *    TRIM ensures both outputs are identical (no trailing spaces)                               
       WRITE-OUTPUT.
           MOVE FUNCTION TRIM(LOG-MSG TRAILING) TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD.
