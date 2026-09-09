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
               05 ACCOUNT-USER PIC X(80).
               05 ACCOUNT-SEPARATOR PIC X(1).
               05 ACCOUNT-PASS PIC X(12).
       WORKING-STORAGE SECTION.
           01 ACCOUNTS-EOF     PIC X(1) VALUE 'N'.

      *    Login Validation flags
           01 LOGIN-STATUS PIC X(1) VALUE 'N'.
               88 LOGIN-VALID-TRUE VALUE 'Y'.
               88 LOGIN-VALID-FALSE VALUE 'N'.
      *    Username validation flags
           01 USERNAME-STATUS PIC X(1) VALUE 'N'.
               88 USERNAME-UNIQUE-TRUE VALUE 'Y'.
               88 USERNAME-UNIQUE-FALSE VALUE 'N'.
      
      *    A Variable to preserve unqiuely identified usernames
           01 NEW-USERNAME PIC X(80).

           01 LOG-MSG PIC X(80) VALUE SPACES.
           01 STRING-MESSAGE PIC X(80) VALUE SPACES.
           01 USER-NAME PIC X(80).
           01 NUM-ACCOUNTS PIC 9(1).

      *    Password validation flags
           01 IS-VALID PIC X VALUE 'N'.
               88 PASSWORD-VALID VALUE 'Y'.
               88 PASSWORD-INVALID VALUE 'N'.
           01 PASSWORD-CHARACTER PIC X(1).
           01 PASSWORD-CHARACTER-INDEX PIC 99 VALUE 0.
           01 PASSWORD-CHARACTER-LENGTH PIC 99 VALUE 0.
           01 PASSWORD-LENGTH-VALID PIC X(1) VALUE 'N'.
           01 PASSWORD-HAS-UPPERCASE PIC X(1) VALUE 'N'.
           01 PASSWORD-HAS-DIGIT PIC X(1) VALUE 'N'.
           01 PASSWORD-HAS-SPECIAL PIC X(1) VALUE 'N'.
        
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
           EVALUATE USER-INPUT
               WHEN "Log In"
                   PERFORM LOGIN
               WHEN "Create New Account"
                   PERFORM CREATE-ACCOUNT
               WHEN OTHER
                   MOVE "Unknown Option" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE
                   CLOSE OUTPUT-FILE
                   STOP RUN
           END-EVALUATE.

       LOGIN.
      *    Opens existing accounts file and runs through the file
      *    Assume LOGIN-VALID is false until proven true
           SET LOGIN-VALID-FALSE TO TRUE.
      *    Keep trying to log in until user validates credentials
           PERFORM UNTIL LOGIN-VALID-TRUE
               READ INPUT-FILE
                   AT END 
                       MOVE "Input ended prematurely" TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                       CLOSE INPUT-FILE OUTPUT-FILE
                       STOP RUN
               END-READ
               STRING "Please enter your username: " DELIMITED BY SIZE
                       USER-INPUT DELIMITED BY SPACE 
                 INTO STRING-MESSAGE
               END-STRING
               MOVE STRING-MESSAGE TO LOG-MSG
               PERFORM WRITE-OUTPUT
               INITIALIZE STRING-MESSAGE
               MOVE USER-INPUT TO USER-NAME
               READ INPUT-FILE
                   AT END 
                       MOVE "Input ended prematurely" TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                       CLOSE INPUT-FILE OUTPUT-FILE
                       STOP RUN
               END-READ
               STRING "Please enter your password: " DELIMITED BY SIZE
                       USER-INPUT DELIMITED BY SPACE 
                 INTO STRING-MESSAGE
               END-STRING
               MOVE STRING-MESSAGE TO LOG-MSG
               PERFORM WRITE-OUTPUT
               INITIALIZE STRING-MESSAGE

      *    Validate login before going to post-login menu
               PERFORM LOGIN-VALIDATION

      *    If no matching account was found, display message and repeat
               IF LOGIN-VALID-FALSE
                   MOVE "Incorrect username/password, please try again" 
                       TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM.

           MOVE "You have successfully logged in" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           PERFORM POST-LOGIN.

       LOGIN-VALIDATION.
      *    Opens existing accounts file and runs through the file
      *    If username and password match, login is valid
      *    Assume LOGIN-VALID is false until proven true
           SET LOGIN-VALID-FALSE TO TRUE.
      *    Make sure to reset EOF flag before reading file
           MOVE 'N' TO ACCOUNTS-EOF.
      *    Open accounts file and compare user input
           OPEN INPUT ACCOUNTS-FILE.

      *    Search continues until EOF is reached or login is valid
           PERFORM UNTIL ACCOUNTS-EOF = 'Y' 
               OR LOGIN-VALID-TRUE
               READ ACCOUNTS-FILE
      *    If EOF is reached, set flag to exit loop
                   AT END
                       MOVE 'Y' TO ACCOUNTS-EOF
      *    If not EOF, check if username and password match
                   NOT AT END
                       IF USER-NAME = ACCOUNT-USER 
                           AND USER-INPUT = ACCOUNT-PASS
                           SET LOGIN-VALID-TRUE TO TRUE
                       END-IF
               END-READ
           END-PERFORM.
           CLOSE ACCOUNTS-FILE.
       CREATE-ACCOUNT.
           PERFORM ACCOUNT-LIMIT-CHECK.
      *    Assume username is NOT unique until proven true
           SET USERNAME-UNIQUE-FALSE TO TRUE.
      *    Keep trying to create a new account until username is unique
           PERFORM UNTIL USERNAME-UNIQUE-TRUE
               READ INPUT-FILE
                   AT END 
                       MOVE "Input ended prematurely" TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                       CLOSE INPUT-FILE OUTPUT-FILE
                       STOP RUN
               END-READ
      *    Preserves username
               MOVE USER-INPUT TO NEW-USERNAME
               MOVE USER-INPUT TO USER-NAME
               STRING "Please create your username: " DELIMITED BY SIZE
                       USER-INPUT DELIMITED BY SPACE 
                 INTO STRING-MESSAGE
               END-STRING
               MOVE STRING-MESSAGE TO LOG-MSG
               PERFORM WRITE-OUTPUT
               INITIALIZE STRING-MESSAGE

      *    Check if username is unique
           PERFORM USERNAME-VALIDATION
      *    If username is not unique, display message and repeat
               IF USERNAME-UNIQUE-FALSE
                   MOVE "Username already exists, please try again" 
                       TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM.

      *    If username is unique, proceed and store unqiue ID
           MOVE NEW-USERNAME TO ACCOUNT-USER.
           MOVE SPACE TO ACCOUNT-SEPARATOR.
      *    username is unique, continueing adding account
           OPEN EXTEND ACCOUNTS-FILE.

      *    REPEAT PASSWORD-VALIDATION UNTIL PASSWORD IS VALID
           MOVE 'N' TO IS-VALID.
           PERFORM UNTIL PASSWORD-VALID
               READ INPUT-FILE
                   AT END 
                       MOVE "Input ended prematurely" TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                       CLOSE INPUT-FILE OUTPUT-FILE ACCOUNTS-FILE
                       STOP RUN
                   END-READ
               STRING "Please create your password: " DELIMITED BY SIZE
                       USER-INPUT DELIMITED BY SPACE 
                 INTO STRING-MESSAGE
               END-STRING
               MOVE STRING-MESSAGE TO LOG-MSG
               PERFORM WRITE-OUTPUT
               INITIALIZE STRING-MESSAGE
               PERFORM PASSWORD-VALIDATION
      *    If password is invalid, display message and repeat
               IF PASSWORD-INVALID
                   MOVE "Password is invalid. Please try again." 
                   TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM.
           MOVE USER-INPUT TO ACCOUNT-PASS.
           MOVE "Account Created Successfully!" TO LOG-MSG
           PERFORM WRITE-OUTPUT
           WRITE ACCOUNTS-RECORD.
           CLOSE ACCOUNTS-FILE.
           PERFORM POST-LOGIN.
       
       USERNAME-VALIDATION.
      *    Assume a unique username until proven otherwise
           SET USERNAME-UNIQUE-TRUE TO TRUE.
      *    Make sure to reset EOF flag before reading file
           MOVE 'N' TO ACCOUNTS-EOF.
      *    Open accounts file and compare user input
           OPEN INPUT ACCOUNTS-FILE.
      *    Search existing usernames
           PERFORM UNTIL ACCOUNTS-EOF = 'Y' 
               OR USERNAME-UNIQUE-FALSE
               READ ACCOUNTS-FILE
                   AT END
                       MOVE 'Y' TO ACCOUNTS-EOF
                   NOT AT END
                       IF NEW-USERNAME = ACCOUNT-USER 
                           SET USERNAME-UNIQUE-FALSE TO TRUE
                       END-IF
               END-READ
           END-PERFORM.
           CLOSE ACCOUNTS-FILE.

       PASSWORD-VALIDATION.
      *    Validates password based on length, uppercase, digit, and special 

      *    Reset all validation flags before checking a password
           MOVE 'N' TO IS-VALID.
           MOVE 'N' TO PASSWORD-LENGTH-VALID.
           MOVE 'N' TO PASSWORD-HAS-UPPERCASE.
           MOVE 'N' TO PASSWORD-HAS-DIGIT.
           MOVE 'N' TO PASSWORD-HAS-SPECIAL.
           MOVE 0 to PASSWORD-CHARACTER-LENGTH.

      *    Index through at most 80 chars
           PERFORM VARYING PASSWORD-CHARACTER-INDEX FROM 1 BY 1
               UNTIL PASSWORD-CHARACTER-INDEX > 80
      *    If the character is not a space, then it's part of the password
               IF USER-INPUT(PASSWORD-CHARACTER-INDEX:1) NOT = SPACE
      *    Save final position to find password length, then exit loop
                   MOVE PASSWORD-CHARACTER-INDEX 
                       TO PASSWORD-CHARACTER-LENGTH
      *    Exit perform if space detected as password cannot have space
               ELSE
                   EXIT PERFORM
               END-IF
           END-PERFORM.

      *    CHECK VALID PASSWORD LENGTH
           MOVE 'N' TO PASSWORD-LENGTH-VALID
      *    If the password length is between 8 and 12 chars, it's valid
           IF PASSWORD-CHARACTER-LENGTH >= 8 
               AND PASSWORD-CHARACTER-LENGTH <= 12
               MOVE 'Y' TO PASSWORD-LENGTH-VALID
           END-IF

      *    CHECK PASSWORD FOR UPPERCASE, DIGIT, AND SPECIAL CHARACTER
           MOVE 'N' TO PASSWORD-HAS-UPPERCASE
           MOVE 'N' TO PASSWORD-HAS-DIGIT
           MOVE 'N' TO PASSWORD-HAS-SPECIAL

      *    Move index until reaching password length
           PERFORM VARYING PASSWORD-CHARACTER-INDEX FROM 1 BY 1
               UNTIL PASSWORD-CHARACTER-INDEX > 
                   PASSWORD-CHARACTER-LENGTH

               MOVE USER-INPUT(PASSWORD-CHARACTER-INDEX:1)
                   TO PASSWORD-CHARACTER
               
      *        Check if a character is uppercase
               IF PASSWORD-CHARACTER >= 'A' 
                   AND PASSWORD-CHARACTER <= 'Z'
                   MOVE 'Y' TO PASSWORD-HAS-UPPERCASE
               END-IF

      *        Check if a character is a digit
               IF PASSWORD-CHARACTER >= '0' 
                   AND PASSWORD-CHARACTER <= '9'
                   MOVE 'Y' TO PASSWORD-HAS-DIGIT
               END-IF

      *        Check if a character is a special character
                IF PASSWORD-CHARACTER IS NOT ALPHABETIC
                   AND PASSWORD-CHARACTER IS NOT NUMERIC
                     MOVE 'Y' TO PASSWORD-HAS-SPECIAL
                END-IF
           END-PERFORM

      *    If all password requirements are met, the password is valid:
      *    - Length between 8 and 12 characters
      *    - Contains at least one uppercase letter
      *    - Contains at least one digit
      *    - Contains at least one special character
              IF PASSWORD-LENGTH-VALID = 'Y' 
                AND PASSWORD-HAS-UPPERCASE = 'Y' 
                AND PASSWORD-HAS-DIGIT = 'Y' 
                AND PASSWORD-HAS-SPECIAL = 'Y'
                AND USER-INPUT NOT = SPACES
                MOVE 'Y' TO IS-VALID
              END-IF.

       ACCOUNT-LIMIT-CHECK.
      *    Opens existing files and runs through the file

           MOVE 'N' TO ACCOUNTS-EOF.
           MOVE 0 TO NUM-ACCOUNTS.

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
           CLOSE ACCOUNTS-FILE.
      *    Check num-accounts after read, if = 5, print message and send
      *    user back to main 
      *    Else continue execution back to CREATE-ACCOUNT
           IF NUM-ACCOUNTS >= 5
               MOVE "All permitted accounts have been created, please co
      -        "me back later." TO LOG-MSG
               PERFORM WRITE-OUTPUT
               PERFORM MAIN
           END-IF.
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
               END-READ
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
                   WHEN NOT 4
                       MOVE "Unknown Option" TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                       CLOSE INPUT-FILE
                       CLOSE OUTPUT-FILE
                       STOP RUN
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
               END-READ
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
                   WHEN NOT "Go Back"
                       MOVE "Unknown Option" TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                       CLOSE INPUT-FILE
                       CLOSE OUTPUT-FILE
                       STOP RUN
               END-EVALUATE
           END-PERFORM.
      
                
      *    KAN-41/42: Dual output - display to console AND write to file
      *    TRIM ensures both outputs are identical (no trailing spaces)                               
       WRITE-OUTPUT.
           MOVE FUNCTION TRIM(LOG-MSG TRAILING) TO OUTPUT-RECORD
           DISPLAY OUTPUT-RECORD
           WRITE OUTPUT-RECORD.
