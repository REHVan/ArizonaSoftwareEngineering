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
           
      *    Existing accounts file
           SELECT ACCOUNTS-FILE
           ASSIGN TO "InCollege-Accounts.txt"
           ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
      *    File descriptions for input output and existing account files
       FILE SECTION.
       FD INPUT-FILE.
      *    Input file 
           01 INPUT-RECORD.
               05 USER-INPUT PIC X(80).
       FD OUTPUT-FILE.
           01 OUTPUT-RECORD PIC X(80).
       
       FD ACCOUNTS-FILE.
           01 ACCOUNTS-RECORD.
               05 ACCOUNT-USER PIC X(11).
               05 ACCOUNT-SEPARATOR PIC X(1).
               05 ACCOUNT-PASS PIC X(12).
       WORKING-STORAGE SECTION.
           01 ACCOUNTS-EOF     PIC X(1) VALUE 'N'.
           01 LOG-MSG PIC X(80) VALUE SPACES.
           01 STRING-MESSAGE PIC X(80) VALUE SPACES.
           01 USER-NAME PIC X(80).
           01 NUM-ACCOUNTS PIC 9(1).

      *    Password checkers
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
      *    Open input and output files at the start
           OPEN INPUT INPUT-FILE.
           OPEN OUTPUT OUTPUT-FILE.
       MAIN.
      *    Title, will be presented again if num accounts > 5 AND
      *    if user tries to create 6th account
           MOVE "Welcome to InCollege!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Log In" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           MOVE "Create New Account." TO LOG-MSG
           PERFORM WRITE-OUTPUT
      *    Every read of the input file will have a checker for EOF
      *    Will terminate program and close files if EOF reached early
           READ INPUT-FILE
               AT END 
                   MOVE "Input ended prematurely" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE OUTPUT-FILE
                   STOP RUN.
      *    Keeps choices and input on one line.
           STRING "Enter your choice: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SIZE
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
      *    Reset for use of one variable per time we have a selection
           INITIALIZE STRING-MESSAGE.
      *    Jump to login or create new depending on user action
           IF USER-INPUT = "Log In"
               PERFORM LOGIN
           ELSE
               IF USER-INPUT = "Create New Account"
                   PERFORM CREATE-ACCOUNT.

      *    TODO: IMPELEMENT LOGIN VALIDATION
       LOGIN.
           READ INPUT-FILE
               AT END 
                   MOVE "Input ended prematurely" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE OUTPUT-FILE
                   STOP RUN.
           STRING "Please enter your username: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SPACE 
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
           MOVE USER-INPUT TO USER-NAME.
           READ INPUT-FILE
               AT END 
                   MOVE "Input ended prematurely" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE OUTPUT-FILE
                   STOP RUN.
           STRING "Please enter your password: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SPACE 
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
      *     PERFORM PASSWORD-VALIDATION.
           MOVE "Logged in Successfully!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           PERFORM POST-LOGIN.
       CREATE-ACCOUNT.
           PERFORM ACCOUNT-LIMIT-CHECK.
           OPEN EXTEND ACCOUNTS-FILE.
           READ INPUT-FILE
               AT END 
                   MOVE "Input ended prematurely" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE OUTPUT-FILE
                   STOP RUN.
           MOVE USER-INPUT TO USER-NAME.
           STRING "Please enter your username: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SPACE 
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
           MOVE USER-INPUT TO ACCOUNT-USER.
           MOVE SPACE TO ACCOUNT-SEPARATOR.
      *    PERFORM PASSWORD-VALIDATION.
           READ INPUT-FILE
               AT END 
                   MOVE "Input ended prematurely" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE OUTPUT-FILE
                   STOP RUN.
           STRING "Please enter your password: " DELIMITED BY SIZE
                   USER-INPUT DELIMITED BY SPACE 
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
           MOVE USER-INPUT TO ACCOUNT-PASS.
           MOVE "Account Created Successfully!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           WRITE ACCOUNTS-RECORD.
           PERFORM POST-LOGIN.         

       
       ACCOUNT-LIMIT-CHECK.
      *    Opens existing files and runs through the file
      *    Adds 1 to NUM-ACCOUNTS per read
           OPEN INPUT ACCOUNTS-FILE
           PERFORM UNTIL ACCOUNTS-EOF = 'Y'
               READ ACCOUNTS-FILE
                   AT END
                       MOVE 'Y' TO ACCOUNTS-EOF
                   NOT AT END
                       ADD 1 TO NUM-ACCOUNTS
               END-READ
           END-PERFORM.
      *    Check num-accounts after read, if = 5, print message and send
      *    user back to main 
      *    Else continue execution back to CREATE-ACCOUNT
           IF NUM-ACCOUNTS = 5
               MOVE "All permitted accounts have been created, please co
      -        "me back later." TO LOG-MSG
               PERFORM WRITE-OUTPUT
               CLOSE ACCOUNTS-FILE
               PERFORM MAIN
           END-IF.
           CLOSE ACCOUNTS-FILE.
       POST-LOGIN.
           STRING "Welcome, " DELIMITED BY SIZE
                   USER-NAME DELIMITED BY SPACE
                   "!" 
             INTO STRING-MESSAGE
           END-STRING.
           MOVE STRING-MESSAGE TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           INITIALIZE STRING-MESSAGE.
           PERFORM MENU-SELECT.
      
       MENU-SELECT.
      *    User selects category in menu, will bring user back to menu
      *    Until user logs out (4)
           PERFORM UNTIL USER-INPUT = '4'
               READ INPUT-FILE
               AT END
                   MOVE "Input ended prematurely" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE OUTPUT-FILE
                   STOP RUN
               MOVE "1. Search for a job" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "2. Find someone you know" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "3. Learn a new skill" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "4. Logout" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               STRING "Enter your choice: " DELIMITED BY SIZE
                       USER-INPUT DELIMITED BY SPACE
                   INTO STRING-MESSAGE
               END-STRING
               MOVE STRING-MESSAGE TO LOG-MSG
               PERFORM WRITE-OUTPUT
               INITIALIZE STRING-MESSAGE
               EVALUATE USER-INPUT
                   WHEN 1
                       MOVE "Job search is under construction." 
                       TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                   WHEN 2
                       MOVE "Find someone you know is under construction
      -                "." TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                   WHEN 3
                       PERFORM SKILL-MENU
               END-EVALUATE
           END-PERFORM.
      *    Execution reaches here when user enters 4, code terminates
           MOVE "Logging out" TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
           CLOSE INPUT-FILE.
           CLOSE OUTPUT-FILE.
           STOP RUN.
       
       SKILL-MENU.
      *    Shows user list of skills to learn, each option other than
      *    Go back will display message, menu will keep appearing until
      *    User enters Go Back, where execution will continue back in
      *    Menu select.
           PERFORM UNTIL USER-INPUT = "Go Back"
               READ INPUT-FILE
               AT END 
                   MOVE "Input ended prematurely" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE OUTPUT-FILE
                   STOP RUN
               MOVE "Learn a New Skill:" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "Communication" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "Coding" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "Teamwork" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "Leadership" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "Critical Thinking" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "Go Back" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               STRING "Enter your choice: " DELIMITED BY SIZE
                       USER-INPUT DELIMITED BY SIZE
                   INTO STRING-MESSAGE
               END-STRING
               MOVE STRING-MESSAGE TO LOG-MSG
               PERFORM WRITE-OUTPUT
               INITIALIZE STRING-MESSAGE
               EVALUATE USER-INPUT
                   WHEN "Communication"
                       MOVE "Communication skill is under construction."
                       TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                   WHEN "Coding"
                       MOVE "Coding skill is under construction."
                       TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                   WHEN "Teamwork"
                       MOVE "Teamwork skill is under construction."
                       TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                   WHEN "Leadership"
                       MOVE "Leadership skill is under construction."
                       TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                   WHEN "Critical Thinking"
                       MOVE "Critical Thinking skill is under constructi
      -                 "on." TO LOG-MSG
                       PERFORM WRITE-OUTPUT
               END-EVALUATE
           END-PERFORM.
      
                
      *    KAN-41/42: Dual output - display to console AND write to file
      *    TRIM ensures both outputs are identical (no trailing spaces)                               
       WRITE-OUTPUT.
           MOVE FUNCTION TRIM(LOG-MSG TRAILING) TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD.
