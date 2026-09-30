      * Send Connection Request copybook
      * Validates and stores pending connection requests

       SEND-CONNECTION-REQUEST.
      *    KAN-135: block sending to yourself
           IF FUNCTION TRIM(USER-NAME) =
               FUNCTION TRIM(FOUND-USER-USERNAME)
               MOVE "You cannot send a connection request to yourself."
                   TO LOG-MSG
               PERFORM WRITE-OUTPUT
               EXIT PARAGRAPH
           END-IF.

           SET REVERSE-REQUEST-NOT-FOUND TO TRUE.
           MOVE 'N' TO PENDING-REQUEST-EOF.
           MOVE 'N' TO ALREADY-SENT-REQUEST.
           SET NOT-CONNECTED TO TRUE.

           OPEN INPUT PENDING-REQUEST-FILE.

      *    A missing file means there are no pending requests yet
           IF PENDING-REQUEST-FILE-NOT-FOUND
               SET REVERSE-REQUEST-NOT-FOUND TO TRUE
           ELSE
               PERFORM UNTIL PENDING-REQUEST-EOF = 'Y'
                   READ PENDING-REQUEST-FILE
                       AT END
                           MOVE 'Y' TO PENDING-REQUEST-EOF
                       NOT AT END
                           MOVE PENDING-REQUEST-FILE-RECORD
                               TO PENDING-REQUEST-RECORD
      *                    KAN-136: target already sent us a request
                           IF REQUEST-STATUS = "CONNECTED" 
                               AND ((FUNCTION TRIM(REQUEST-SENDER) =
                               FUNCTION TRIM(FOUND-USER-USERNAME)
                               AND FUNCTION TRIM(REQUEST-RECIPIENT) =
                               FUNCTION TRIM(USER-NAME))

                               OR (FUNCTION TRIM (REQUEST-SENDER) = 
                               FUNCTION TRIM (USER-NAME) AND
                               FUNCTION TRIM(REQUEST-RECIPIENT) =
                               FUNCTION TRIM (FOUND-USER-USERNAME)))
                               SET ALREADY-CONNECTED TO TRUE
                            END-IF
                           IF REQUEST-STATUS = "PENDING"
                           AND FUNCTION TRIM(REQUEST-SENDER) =
                               FUNCTION TRIM(FOUND-USER-USERNAME)
                               AND FUNCTION TRIM(REQUEST-RECIPIENT) =
                               FUNCTION TRIM(USER-NAME)
                               SET REVERSE-REQUEST-EXISTS TO TRUE
                               MOVE 'Y' TO PENDING-REQUEST-EOF
                           END-IF
      *                    KAN-135: we already sent them a request
                           IF REQUEST-STATUS = "PENDING"
                           AND FUNCTION TRIM(REQUEST-SENDER) =
                               FUNCTION TRIM(USER-NAME)
                               AND FUNCTION TRIM(REQUEST-RECIPIENT) =
                               FUNCTION TRIM(FOUND-USER-USERNAME)
                               MOVE 'Y' TO ALREADY-SENT-REQUEST
                               MOVE 'Y' TO PENDING-REQUEST-EOF
                           END-IF
                   END-READ
               END-PERFORM

               CLOSE PENDING-REQUEST-FILE
           END-IF.

           IF REVERSE-REQUEST-EXISTS
               MOVE "This user already sent you a pending request."
                   TO LOG-MSG
               PERFORM WRITE-OUTPUT
           ELSE IF ALREADY-SENT-REQUEST = 'Y'
               MOVE "You already sent this user a connection request."
                   TO LOG-MSG
               PERFORM WRITE-OUTPUT
           ELSE IF ALREADY-CONNECTED
               MOVE "You are already connected with this person."
                   TO LOG-MSG
               PERFORM WRITE-OUTPUT
           ELSE
               MOVE USER-NAME TO REQUEST-SENDER
               MOVE FOUND-USER-USERNAME TO REQUEST-RECIPIENT
               MOVE "PENDING" TO REQUEST-STATUS
               MOVE PENDING-REQUEST-RECORD
                   TO PENDING-REQUEST-FILE-RECORD

               IF PENDING-REQUEST-FILE-NOT-FOUND
                   OPEN OUTPUT PENDING-REQUEST-FILE
               ELSE
                   OPEN EXTEND PENDING-REQUEST-FILE
               END-IF

               WRITE PENDING-REQUEST-FILE-RECORD
               CLOSE PENDING-REQUEST-FILE

               INITIALIZE STRING-MESSAGE
               STRING "Connection request sent to "
                   DELIMITED BY SIZE
                   FUNCTION TRIM(FOUND-USER-NAME)
                   DELIMITED BY SIZE
                   "." DELIMITED BY SIZE
                   INTO STRING-MESSAGE
               END-STRING
               MOVE STRING-MESSAGE TO LOG-MSG
               PERFORM WRITE-OUTPUT
           END-IF.
