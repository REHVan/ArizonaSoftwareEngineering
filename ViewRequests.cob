      * Pending connection request data structure
      * Stores the username of the sender and recipient
       01 PENDING-REQUEST-RECORD.
           05 REQUEST-SENDER    PIC X(80).
           05 REQUEST-RECIPIENT PIC X(80).
           05 REQUEST-STATUS PIC X(20).
           