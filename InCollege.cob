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
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS INPUT-FILE-STATUS.
      *    Output log file for dual output
           SELECT OUTPUT-FILE
           ASSIGN TO "InCollege-Output.txt"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS OUTPUT-FILE-STATUS.

      *    Existing accounts file
           SELECT ACCOUNTS-FILE
           ASSIGN TO "InCollege-Accounts.txt"
           ORGANIZATION IS LINE SEQUENTIAL.

           SELECT PROFILE-FILE
           ASSIGN TO USER-DATA
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS PROFILE-FILE-STATUS.
       DATA DIVISION.
      *    File descriptions for input output and existing account files
       FILE SECTION.
       FD INPUT-FILE.
      *    Input file 
           01 INPUT-RECORD.
               05 USER-INPUT PIC X(200).
       FD OUTPUT-FILE.
           01 OUTPUT-RECORD PIC X(300).
       
       FD ACCOUNTS-FILE.
           01 ACCOUNTS-RECORD.
               05 ACCOUNT-USER PIC X(80).
               05 ACCOUNT-SEPARATOR PIC X(1).
               05 ACCOUNT-PASS PIC X(12).
       FD PROFILE-FILE.
           01 PROFILE-RECORD PIC X(300).
          
       WORKING-STORAGE SECTION.
           01 ACCOUNTS-EOF     PIC X(1) VALUE 'N'.
           01 MENU-EOF         PIC X(1) VALUE 'N'.
           01 PROFILE-EOF      PIC X(1) VALUE 'N'.
           01 INPUT-FILE-STATUS PIC XX.
               88 INPUT-NOT-FOUND VALUE "35".
           01 OUTPUT-FILE-STATUS PIC XX.
               88 OUTPUT-NOT-FOUND VALUE "35".
           
           01 PROFILE-FILE-STATUS PIC XX.
               88 PROFILE-FOUND VALUE "00".
               88 PROFILE-NOT-FOUND VALUE "35".
           01 USER-DATA PIC X(80).
      *    Login Validation flags
           01 LOGIN-STATUS PIC X(1) VALUE 'N'.
               88 LOGIN-VALID-TRUE VALUE 'Y'.
               88 LOGIN-VALID-FALSE VALUE 'N'.
      *    Username validation flags
           01 PROFILE-PROMPT PIC X(100).
           
           01 PROFILE-PREFIX PIC X(80).
           01 PROFILE-STRING PIC X(80).
      *    File that hold user profile
           01 PROFILE-FIRSTNAME PIC X(80).
           01 PROFILE-LASTNAME PIC X(80).
      *    Required university and major fields
           01 PROFILE-UNIVERSITY PIC X(80).
           01 PROFILE-MAJOR PIC X(80).
           01 GRADUATION-YEAR PIC 9(4).
           01 ABOUT-ME PIC X(200).
      *    Up to three work experience entries per profile
           01 EXPERIENCE-TABLE.
               05 EXPERIENCE-ENTRY OCCURS 3 TIMES.
                   10 EXP-TITLE PIC X(80).
                   10 EXP-COMPANY PIC X(80).
                   10 EXP-DATES PIC X(80).
                   10 EXP-DESC PIC X(100).
           01 EXP-COUNT PIC 9 VALUE 0.
           01 EXP-INDEX PIC 9 VALUE 0.
           01 EXP-DONE PIC X(1) VALUE 'N'.
      *    Up to three education entries per profile
           01 EDUCATION-TABLE.
               05 EDUCATION-ENTRY OCCURS 3 TIMES.
                   10 EDU-DEGREE PIC X(80).
                   10 EDU-SCHOOL PIC X(80).
                   10 EDU-YEARS PIC X(80).
           01 EDU-COUNT PIC 9 VALUE 0.
           01 EDU-INDEX PIC 9 VALUE 0.
           01 EDU-DONE PIC X(1) VALUE 'N'.
           01 USERNAME-STATUS PIC X(1) VALUE 'N'.
               88 USERNAME-UNIQUE-TRUE VALUE 'Y'.
               88 USERNAME-UNIQUE-FALSE VALUE 'N'.
      
           01 USERNAME-BLANK PIC X(1) VALUE 'N'.
               88 USERNAME-BLANK-TRUE VALUE 'Y'.
               88 USERNAME-BLANK-FALSE VALUE 'N'.

           01 USERNAME-SPACE PIC X(1) VALUE 'N'.
               88 USERNAME-SPACE-TRUE VALUE 'Y'.
               88 USERNAME-SPACE-FALSE VALUE 'N'.
      *    A Variable to preserve unqiuely identified usernames
           01 NEW-USERNAME PIC X(80).
           01 USERNAME-CHARACTER-INDEX PIC 99 VALUE 0.
           01 USERNAME-LENGTH PIC 99.
           01 LOG-MSG PIC X(300) VALUE SPACES.
           01 PROFILE-LOG PIC X(300) VALUE SPACES.
           01 STRING-MESSAGE PIC X(300) VALUE SPACES.
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
           
           01 HAS-FILE PIC X(1) VALUE 'N'.
       PROCEDURE DIVISION.
      *    Open input and output files at the start
           OPEN INPUT INPUT-FILE
           IF INPUT-NOT-FOUND THEN
               STOP RUN
           END-IF.
           OPEN OUTPUT OUTPUT-FILE 
           IF OUTPUT-NOT-FOUND THEN
               STOP RUN
           END-IF.

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
           PERFORM UNTIL USERNAME-UNIQUE-TRUE AND USERNAME-BLANK-FALSE
           AND USERNAME-SPACE-FALSE
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
               EVALUATE TRUE
                   WHEN USERNAME-BLANK-TRUE
                       MOVE "Username cannot be blank, please try again"
                       TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                   WHEN USERNAME-SPACE-TRUE
                       MOVE "Username cannot have spaces, please try aga
      -                 "in." TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                   WHEN USERNAME-UNIQUE-FALSE
                       MOVE "Username already exists, please try again" 
                       TO LOG-MSG
                       PERFORM WRITE-OUTPUT
               END-EVALUATE
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
           SET USERNAME-BLANK-FALSE TO TRUE.
           SET USERNAME-SPACE-FALSE TO TRUE.
      *    Make sure to reset EOF flag before reading file
           MOVE 'N' TO ACCOUNTS-EOF.
      *    Open accounts file and compare user input
           OPEN INPUT ACCOUNTS-FILE.
           
           IF NEW-USERNAME = SPACES
               SET USERNAME-BLANK-TRUE TO TRUE
           END-IF.
           
           COMPUTE USERNAME-LENGTH = FUNCTION LENGTH (FUNCTION TRIM
                                                     (NEW-USERNAME))
           PERFORM VARYING USERNAME-CHARACTER-INDEX FROM 1 BY 1
           UNTIL USERNAME-CHARACTER-INDEX > USERNAME-LENGTH
               IF NEW-USERNAME(USERNAME-CHARACTER-INDEX:1) = SPACE
                   SET USERNAME-SPACE-TRUE TO TRUE
               END-IF
           END-PERFORM.
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
      *    Validates password on length, uppercase, digit, special

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
      *    If the character is not a space, it is part of the password
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
           STRING "user-data/" DELIMITED BY SIZE
                   USER-NAME DELIMITED BY SPACE
                  ".txt" DELIMITED BY SIZE
             INTO USER-DATA
           END-STRING.
           MOVE USER-DATA TO LOG-MSG
           PERFORM MENU-SELECT.
      
       MENU-SELECT.
           
      *    User selects category in menu, will bring user back to menu
      *    There is no logout option, the menu repeats until the input
      *    file runs out, which ends the program without an error
           PERFORM UNTIL MENU-EOF = 'Y'
      *    Menu is shown before the read so it still appears when the
      *    input file runs out at this prompt
               OPEN INPUT PROFILE-FILE
               IF PROFILE-FILE-STATUS = "35"
                   MOVE "1. Create My Profile" TO LOG-MSG
               ELSE
                   MOVE "1. Edit My Profile" TO LOG-MSG
                   MOVE 'Y' TO HAS-FILE
               END-IF
               CLOSE PROFILE-FILE
               PERFORM WRITE-OUTPUT
               MOVE "2. View My Profile" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "3. Search for a job" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "4. Find someone you know" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               MOVE "5. Learn a New Skill" TO LOG-MSG
               PERFORM WRITE-OUTPUT
               READ INPUT-FILE
               AT END
      *    Input running out here is a normal exit, so show the prompt
      *    and stop instead of printing "Input ended prematurely"
                   MOVE 'Y' TO MENU-EOF
                   MOVE "Enter your choice:" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               NOT AT END
                   INITIALIZE STRING-MESSAGE
                   STRING "Enter your choice: " DELIMITED BY SIZE
                           USER-INPUT DELIMITED BY SPACE 
                           INTO STRING-MESSAGE
                   END-STRING
                   MOVE STRING-MESSAGE TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   INITIALIZE STRING-MESSAGE
                   PERFORM MENU-CHOICE
               END-READ
           END-PERFORM.
      *    Execution reaches here when the input file runs out
           MOVE "Logging out.." TO LOG-MSG
           PERFORM WRITE-OUTPUT.
           CLOSE INPUT-FILE.
           CLOSE OUTPUT-FILE.
           STOP RUN.
           
       MENU-CHOICE.
           EVALUATE USER-INPUT
               WHEN "1"
                   IF HAS-FILE = 'Y'
                       PERFORM CREATE-EDIT-PROFILE
                   ELSE
                       OPEN OUTPUT PROFILE-FILE
                       CLOSE PROFILE-FILE
                       PERFORM CREATE-EDIT-PROFILE
                   END-IF
               WHEN "2"
                   PERFORM VIEW-PROFILE
               WHEN "3"
                   MOVE "Job search is under construction." TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               WHEN "4"
                   MOVE "Find someone you know is under construction." 
                   TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               WHEN "5"
                   PERFORM SKILL-MENU
               WHEN OTHER
                   MOVE "Unknown Option" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE
                   CLOSE OUTPUT-FILE
                   STOP RUN
           END-EVALUATE.
       CREATE-EDIT-PROFILE.
      *    Create and edit ask the same questions, only the header
      *    changes, so both paths run the same prompt paragraphs
           IF HAS-FILE = 'N'
               MOVE "--- Create Profile ---" TO LOG-MSG
           ELSE
               MOVE "--- Edit Profile ---" TO LOG-MSG
           END-IF.
           PERFORM WRITE-OUTPUT.
           OPEN OUTPUT PROFILE-FILE.
      *    Each paragraph prompts, validates, then writes its own
      *    line to the profile file in the order the sample shows
           PERFORM PROFILE-NAME
           PERFORM PROFILE-UNIVERSITY-MAJOR
           PERFORM PROFILE-GRADUATION
           PERFORM PROFILE-ABOUT-ME
           PERFORM PROFILE-EXPERIENCE
           PERFORM PROFILE-EDUCATION
           CLOSE PROFILE-FILE.
           MOVE "Profile saved successfully!" TO LOG-MSG.
           PERFORM WRITE-OUTPUT.

       GET-INPUT.
           READ INPUT-FILE
               AT END 
                   MOVE "Input ended prematurely" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
      *            If input during profile creation ends early
      *            clear profile file, this ensures the profile is only
      *            written once all fields are entered and does not get
      *            cut off unexpectedly
                   CLOSE PROFILE-FILE
                   OPEN OUTPUT PROFILE-FILE

                   CLOSE INPUT-FILE OUTPUT-FILE PROFILE-FILE
                   STOP RUN
               NOT AT END
                   INITIALIZE STRING-MESSAGE
                   STRING FUNCTION TRIM(PROFILE-PROMPT) 
                       DELIMITED BY SIZE
                       " " DELIMITED BY SIZE
                       USER-INPUT DELIMITED BY SIZE
                     INTO STRING-MESSAGE
                   END-STRING
                   MOVE STRING-MESSAGE TO LOG-MSG
               END-READ.

       PROFILE-NAME.
      *    First and last name are both required, so keep
      *    prompting until something other than spaces is entered
           MOVE SPACES TO PROFILE-FIRSTNAME.
           PERFORM UNTIL PROFILE-FIRSTNAME NOT = SPACES
               MOVE "Enter First Name:" TO PROFILE-PROMPT
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "First Name is required" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               ELSE
                   MOVE USER-INPUT TO PROFILE-FIRSTNAME
               END-IF
           END-PERFORM.

           MOVE SPACES TO PROFILE-LASTNAME.
           PERFORM UNTIL PROFILE-LASTNAME NOT = SPACES
               MOVE "Enter Last Name:" TO PROFILE-PROMPT
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "Last Name is required" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               ELSE
                   MOVE USER-INPUT TO PROFILE-LASTNAME
               END-IF
           END-PERFORM.

      *    The sample profile shows one Name line, not two, so the
      *    two fields are joined before being written
           INITIALIZE PROFILE-LOG.
           STRING "Name: " DELIMITED BY SIZE
                   FUNCTION TRIM(PROFILE-FIRSTNAME) DELIMITED BY SIZE
                   " " DELIMITED BY SIZE
                   FUNCTION TRIM(PROFILE-LASTNAME) DELIMITED BY SIZE
             INTO PROFILE-LOG
           END-STRING.
           PERFORM WRITE-PROFILE.

       PROFILE-UNIVERSITY-MAJOR.
      *    University and major are both required
           MOVE SPACES TO PROFILE-UNIVERSITY.
           PERFORM UNTIL PROFILE-UNIVERSITY NOT = SPACES
               MOVE "Enter University/College Attended:"
                 TO PROFILE-PROMPT
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "University/College is required" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               ELSE
                   MOVE USER-INPUT TO PROFILE-UNIVERSITY
               END-IF
           END-PERFORM.

           INITIALIZE PROFILE-LOG.
           STRING "University: " DELIMITED BY SIZE
                   FUNCTION TRIM(PROFILE-UNIVERSITY) DELIMITED BY SIZE
             INTO PROFILE-LOG
           END-STRING.
           PERFORM WRITE-PROFILE.
           
           MOVE SPACES TO PROFILE-MAJOR.
           PERFORM UNTIL PROFILE-MAJOR NOT = SPACES
               MOVE "Enter Major:" TO PROFILE-PROMPT
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "Major is required" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               ELSE
                   MOVE USER-INPUT TO PROFILE-MAJOR
               END-IF
           END-PERFORM.

           INITIALIZE PROFILE-LOG.
           STRING "Major: " DELIMITED BY SIZE
                   FUNCTION TRIM(PROFILE-MAJOR) DELIMITED BY SIZE
             INTO PROFILE-LOG
           END-STRING.
           PERFORM WRITE-PROFILE.
      
       PROFILE-GRADUATION.
      *    Graduation Field is required
      *    Makes sure the loop runs at least once
           MOVE ZEROS TO GRADUATION-YEAR.
      *    Because graduation year is only numeric, only check if it is
      *    in valid range
           PERFORM UNTIL GRADUATION-YEAR > 2025 
                         AND GRADUATION-YEAR < 2034
               MOVE "Enter Graduation Year (YYYY):" TO PROFILE-PROMPT
               PERFORM GET-INPUT
               IF FUNCTION TRIM(USER-INPUT) IS NUMERIC
                   MOVE USER-INPUT TO GRADUATION-YEAR
               ELSE
                   MOVE ZEROS TO GRADUATION-YEAR
               END-IF
               PERFORM WRITE-OUTPUT
               EVALUATE TRUE
                WHEN GRADUATION-YEAR = 0000
                   MOVE "Graduation Year must be numeric" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                WHEN GRADUATION-YEAR < 2026 OR GRADUATION-YEAR > 2033
                   MOVE "Invalid Year. Please enter a year in between 20
      -            "26 and 2033." TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-EVALUATE
           END-PERFORM.

      *    Reaching here means graduation year is valid
           INITIALIZE PROFILE-LOG.
           STRING "Graduation Year: " DELIMITED BY SIZE
                  GRADUATION-YEAR DELIMITED BY SIZE
              INTO PROFILE-LOG
           END-STRING.
           PERFORM WRITE-PROFILE.
           
       PROFILE-ABOUT-ME.
      *    Optional field, a blank line skips it and writes nothing
           MOVE SPACES TO ABOUT-ME.
           MOVE "Enter About Me (optional, max 200 chars, enter blank li
      -    "ne to skip):" TO PROFILE-PROMPT.
           PERFORM GET-INPUT.
           PERFORM WRITE-OUTPUT.
           IF USER-INPUT NOT = SPACES
               MOVE USER-INPUT TO ABOUT-ME
               INITIALIZE PROFILE-LOG
               STRING "About Me: " DELIMITED BY SIZE
                       FUNCTION TRIM(ABOUT-ME) DELIMITED BY SIZE
                 INTO PROFILE-LOG
               END-STRING
               PERFORM WRITE-PROFILE
           END-IF.

       PROFILE-EXPERIENCE.
      *    Optional, up to three entries. DONE ends the list early and
      *    the loop also stops on its own once three are entered
           MOVE 0 TO EXP-COUNT.
           MOVE 'N' TO EXP-DONE.
           PERFORM UNTIL EXP-DONE = 'Y' OR EXP-COUNT = 3
               MOVE "Add Experience? (optional, max 3 entries, Enter 'DO
      -         "NE' to finish. ): " TO PROFILE-PROMPT
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               EVALUATE TRUE
                WHEN FUNCTION TRIM (USER-INPUT) = "DONE"
                   MOVE 'Y' TO EXP-DONE
                WHEN USER-INPUT = SPACES
                   ADD 1 TO EXP-COUNT
                   PERFORM EXPERIENCE-ENTRY-INPUT
                WHEN OTHER
                   MOVE "Invalid Choice, Please enter a blank or DONE"
                   TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-EVALUATE
           END-PERFORM.
           IF EXP-COUNT > 0
               PERFORM WRITE-EXPERIENCE
           END-IF.
           IF EXP-COUNT = 3
               MOVE "Cannot enter anymore experiences." TO LOG-MSG
               PERFORM WRITE-OUTPUT
           END-IF.

       EXPERIENCE-ENTRY-INPUT.
      *    Title, company and dates are required parts of the entry. The
      *    description is optional and a blank line leaves it empty
           INITIALIZE PROFILE-PROMPT.
           MOVE SPACES TO USER-INPUT.
           PERFORM UNTIL USER-INPUT NOT = SPACES
               STRING "Experience #" DELIMITED BY SIZE
                       EXP-COUNT DELIMITED BY SIZE
                       " - Title:" DELIMITED BY SIZE
               INTO PROFILE-PROMPT
               END-STRING
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "Title field is required." TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM.
           
           MOVE USER-INPUT TO EXP-TITLE(EXP-COUNT).

           INITIALIZE PROFILE-PROMPT.
           MOVE SPACES TO USER-INPUT.
           PERFORM UNTIL USER-INPUT NOT = SPACES
               STRING "Experience #" DELIMITED BY SIZE
                       EXP-COUNT DELIMITED BY SIZE
                       " - Company/Organization:" DELIMITED BY SIZE
               INTO PROFILE-PROMPT
               END-STRING
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "Company/Organization field is required." 
                   TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM.
           
           MOVE USER-INPUT TO EXP-COMPANY(EXP-COUNT).

           INITIALIZE PROFILE-PROMPT.
           MOVE SPACES TO USER-INPUT.
           PERFORM UNTIL USER-INPUT NOT = SPACES
               STRING "Experience #" DELIMITED BY SIZE
                       EXP-COUNT DELIMITED BY SIZE
                   " - Dates (e.g., Summer 2024):" DELIMITED BY SIZE
                  INTO PROFILE-PROMPT
               END-STRING
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "Date field is required." TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM.
           
           MOVE USER-INPUT TO EXP-DATES(EXP-COUNT).

           INITIALIZE PROFILE-PROMPT.
           STRING "Experience #" DELIMITED BY SIZE
                   EXP-COUNT DELIMITED BY SIZE
                   " - Description (optional, max 100 chars, blank to "
                   DELIMITED BY SIZE
                   "skip):" DELIMITED BY SIZE
             INTO PROFILE-PROMPT
           END-STRING.
           PERFORM GET-INPUT.
           PERFORM WRITE-OUTPUT.
           MOVE USER-INPUT TO EXP-DESC(EXP-COUNT).

       WRITE-EXPERIENCE.
      *    Writes the header once, then one indented block per entry.
      *    A blank description is left out of the saved profile
           INITIALIZE PROFILE-LOG.
           MOVE "Experience:" TO PROFILE-LOG.
           PERFORM WRITE-PROFILE.
           PERFORM VARYING EXP-INDEX FROM 1 BY 1
               UNTIL EXP-INDEX > EXP-COUNT
               INITIALIZE PROFILE-LOG
               STRING " Title: " DELIMITED BY SIZE
                       FUNCTION TRIM(EXP-TITLE(EXP-INDEX))
                       DELIMITED BY SIZE
                 INTO PROFILE-LOG
               END-STRING
               PERFORM WRITE-PROFILE
               INITIALIZE PROFILE-LOG
               STRING " Company: " DELIMITED BY SIZE
                       FUNCTION TRIM(EXP-COMPANY(EXP-INDEX))
                       DELIMITED BY SIZE
                 INTO PROFILE-LOG
               END-STRING
               PERFORM WRITE-PROFILE
               INITIALIZE PROFILE-LOG
               STRING " Dates: " DELIMITED BY SIZE
                       FUNCTION TRIM(EXP-DATES(EXP-INDEX))
                       DELIMITED BY SIZE
                 INTO PROFILE-LOG
               END-STRING
               PERFORM WRITE-PROFILE
               IF EXP-DESC(EXP-INDEX) NOT = SPACES
                   INITIALIZE PROFILE-LOG
                   STRING " Description: " DELIMITED BY SIZE
                           FUNCTION TRIM(EXP-DESC(EXP-INDEX))
                           DELIMITED BY SIZE
                     INTO PROFILE-LOG
                   END-STRING
                   PERFORM WRITE-PROFILE
               END-IF
           END-PERFORM.

       PROFILE-EDUCATION.
      *    Optional, up to three entries. DONE ends the list early and
      *    the loop also stops on its own once three are entered
           MOVE 0 TO EDU-COUNT.
           MOVE 'N' TO EDU-DONE.
           PERFORM UNTIL EDU-DONE = 'Y' OR EDU-COUNT = 3
               MOVE "Add Education (optional, max 3 entries. Enter 'DONE
      -        "' to finish):" TO PROFILE-PROMPT
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               EVALUATE TRUE
                WHEN FUNCTION TRIM (USER-INPUT) = "DONE"
                   MOVE 'Y' TO EDU-DONE
                WHEN USER-INPUT = SPACES
                       ADD 1 TO EDU-COUNT
                       PERFORM EDUCATION-ENTRY-INPUT
                WHEN OTHER
                 MOVE "Invalid Choice, Please enter a blank or DONE"
                 TO LOG-MSG
                 PERFORM WRITE-OUTPUT
               END-EVALUATE
           END-PERFORM.
           IF EDU-COUNT > 0
               PERFORM WRITE-EDUCATION
           END-IF.
           IF EDU-COUNT = 3
               MOVE "Education limit reached. Please edit profile if you
      -         "wish to change any." TO LOG-MSG
               PERFORM WRITE-OUTPUT
           END-IF.

       EDUCATION-ENTRY-INPUT.
      *    Collects one entry, numbered by how many are stored so far
           MOVE SPACES TO USER-INPUT.
           INITIALIZE PROFILE-PROMPT.
           PERFORM UNTIL USER-INPUT NOT = SPACES
               STRING "Education #" DELIMITED BY SIZE
                       EDU-COUNT DELIMITED BY SIZE
                       " - Degree:" DELIMITED BY SIZE
                INTO PROFILE-PROMPT
               END-STRING
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "Degree Field must not be blank." TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM.
           MOVE USER-INPUT TO EDU-DEGREE(EDU-COUNT).
           
           MOVE SPACES TO USER-INPUT.
           INITIALIZE PROFILE-PROMPT.
           PERFORM UNTIL USER-INPUT NOT = SPACES 
               STRING "Education #" DELIMITED BY SIZE
                       EDU-COUNT DELIMITED BY SIZE
                       " - University/College:" DELIMITED BY SIZE
                 INTO PROFILE-PROMPT
               END-STRING
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "Univeristy/College Field must not be blank." 
                   TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM.

           MOVE USER-INPUT TO EDU-SCHOOL(EDU-COUNT).
           
           MOVE SPACES TO USER-INPUT
           INITIALIZE PROFILE-PROMPT.
           PERFORM UNTIL USER-INPUT NOT = SPACES
               STRING "Education #" DELIMITED BY SIZE
                       EDU-COUNT DELIMITED BY SIZE
                       " - Years Attended (e.g., 2023-2025):"
                       DELIMITED BY SIZE
                 INTO PROFILE-PROMPT
               END-STRING
               PERFORM GET-INPUT
               PERFORM WRITE-OUTPUT
               IF USER-INPUT = SPACES
                   MOVE "Years Attended field must not be blank." 
                   TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM.

           MOVE USER-INPUT TO EDU-YEARS(EDU-COUNT).

       WRITE-EDUCATION.
      *    Writes the header once, then one indented block per entry
           INITIALIZE PROFILE-LOG.
           MOVE "Education:" TO PROFILE-LOG.
           PERFORM WRITE-PROFILE.
           PERFORM VARYING EDU-INDEX FROM 1 BY 1
               UNTIL EDU-INDEX > EDU-COUNT
               INITIALIZE PROFILE-LOG
               STRING " Degree: " DELIMITED BY SIZE
                       FUNCTION TRIM(EDU-DEGREE(EDU-INDEX))
                       DELIMITED BY SIZE
                 INTO PROFILE-LOG
               END-STRING
               PERFORM WRITE-PROFILE
               INITIALIZE PROFILE-LOG
               STRING " University: " DELIMITED BY SIZE
                       FUNCTION TRIM(EDU-SCHOOL(EDU-INDEX))
                       DELIMITED BY SIZE
                 INTO PROFILE-LOG
               END-STRING
               PERFORM WRITE-PROFILE
               INITIALIZE PROFILE-LOG
               STRING " Years: " DELIMITED BY SIZE
                       FUNCTION TRIM(EDU-YEARS(EDU-INDEX))
                       DELIMITED BY SIZE
                 INTO PROFILE-LOG
               END-STRING
               PERFORM WRITE-PROFILE
           END-PERFORM.

       VIEW-PROFILE.
      *    Displays every line stored in the user's profile file

      *    First checks if user tries to open a folder that does
      *    not exist
           MOVE 'N' TO PROFILE-EOF.
           OPEN INPUT PROFILE-FILE
           IF PROFILE-FILE-STATUS = "35"
               MOVE "Your profile does not exist. Please create profile"
               TO LOG-MSG
               CLOSE PROFILE-FILE
               PERFORM WRITE-OUTPUT
               EXIT PARAGRAPH
           END-IF.
      *    Next check is if the file does exist, but is empty
           READ PROFILE-FILE
               AT END
                   MOVE "Your profile is empty. Please complete profile"
                   TO LOG-MSG
                   CLOSE PROFILE-FILE
                   PERFORM WRITE-OUTPUT
                   EXIT PARAGRAPH
           END-READ.
           CLOSE PROFILE-FILE

           MOVE "--- Your Profile ---" TO LOG-MSG
           PERFORM WRITE-OUTPUT.
           OPEN INPUT PROFILE-FILE.
           PERFORM UNTIL PROFILE-EOF = 'Y'
               READ PROFILE-FILE
                   AT END
                       MOVE 'Y' TO PROFILE-EOF
                       CLOSE PROFILE-FILE
                   NOT AT END
                       MOVE PROFILE-RECORD TO LOG-MSG
                       PERFORM WRITE-OUTPUT
                END-READ
           END-PERFORM.
           MOVE "--------------------" TO LOG-MSG.
           PERFORM WRITE-OUTPUT.
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
               PERFORM SKILL-CHOICE
           END-PERFORM.
      
       SKILL-CHOICE.
           EVALUATE USER-INPUT
               WHEN "Communication"
                   MOVE "Communication skill is under construction."
                   TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               WHEN "Coding"
                   MOVE "Coding skill is under construction." TO LOG-MSG
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
                   MOVE "Critical Thinking skill is under construction."
                   TO LOG-MSG
                   PERFORM WRITE-OUTPUT
               WHEN NOT "Go Back"
                   MOVE "Unknown Option" TO LOG-MSG
                   PERFORM WRITE-OUTPUT
                   CLOSE INPUT-FILE
                   CLOSE OUTPUT-FILE
                   STOP RUN
           END-EVALUATE.
                
      *    Dual output - display to console AND write to file
      *    The file WRITE drops trailing spaces, so DISPLAY
      *    trims them too so screen and file lines are byte-identical
       WRITE-OUTPUT.
           MOVE FUNCTION TRIM(LOG-MSG TRAILING) TO OUTPUT-RECORD
           DISPLAY FUNCTION TRIM(OUTPUT-RECORD TRAILING)
           WRITE OUTPUT-RECORD.
       
       WRITE-PROFILE.
           MOVE FUNCTION TRIM(PROFILE-LOG TRAILING)
               TO PROFILE-RECORD
           WRITE PROFILE-RECORD.
           