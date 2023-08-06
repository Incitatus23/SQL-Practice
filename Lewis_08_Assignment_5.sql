/*
    Name: Adam Lewis
    DTSC660: Data and Database Managment with SQL
    Module 5
    Assignment 5
*/

--------------------------------------------------------------------------------
/*				                 Banking DDL           		  		          */
--------------------------------------------------------------------------------

   
    CREATE TABLE branch (
        branch_name VARCHAR (40),
        branch_city VARCHAR (20),
        assets NUMERIC (15,2),
        CONSTRAINT branch_pkey PRIMARY KEY (branch_name)
    );

     CREATE TABLE customer (
        cust_ID VARCHAR (12),
        customer_name VARCHAR (30) NOT NULL,
        customer_street VARCHAR (30),
        customer_city VARCHAR (20),
        CONSTRAINT customer_pkey PRIMARY KEY (cust_ID)
    );
      CREATE TABLE loan (
        loan_number VARCHAR (12),
        branch_name VARCHAR (40),
        amount NUMERIC (15,2) CHECK (amount > 0.00),
        CONSTRAINT loan_pkey PRIMARY KEY (loan_number),
        CONSTRAINT loan_fkey FOREIGN KEY (branch_name) REFERENCES branch (branch_name)
       
    );
   
      CREATE TABLE borrower (
        cust_ID VARCHAR (12),
        loan_number VARCHAR (12),
        CONSTRAINT borrower_pkey PRIMARY KEY (cust_ID, loan_number),
        CONSTRAINT borrower_fkey_1 FOREIGN KEY (cust_ID) REFERENCES customer (cust_ID),
        CONSTRAINT borrower_fkey_2 FOREIGN KEY (loan_number) REFERENCES loan (loan_number)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    );

      CREATE TABLE account (
        account_number VARCHAR (12),
        branch_name VARCHAR (40),
        balance NUMERIC (15,2) DEFAULT 0.00,
        CONSTRAINT account_pkey PRIMARY KEY (account_number),
        CONSTRAINT account_fkey FOREIGN KEY (branch_name) REFERENCES branch (branch_name)
      
    );
    
       CREATE TABLE depositor (
         cust_ID VARCHAR (12),
         account_number VARCHAR (12),
         CONSTRAINT depositor_pkey PRIMARY KEY (cust_ID, account_number),
         CONSTRAINT depositor_fkey FOREIGN KEY (cust_ID) REFERENCES customer (cust_ID)
         ON DELETE CASCADE
         ON UPDATE CASCADE
         
    );
    
    
--------------------------------------------------------------------------------
/*				                  Question 1           		  		          */
--------------------------------------------------------------------------------

    CREATE OR REPLACE FUNCTION Lewis_08_monthlyPayment(prin_mort NUMERIC (11,2),
                                                       apr NUMERIC (7,6),
                                                       years INTEGER)
        RETURNS NUMERIC (11,2)
        LANGUAGE plpgsql
        AS
        $$
          DECLARE
            i NUMERIC (7,6) = apr/12;
            n INTEGER = years * 12;
            monthlyPayment NUMERIC (11,2);
        
          BEGIN
            SELECT prin_mort * (i + (i / (( 1+i)^n - 1 ))) INTO monthlyPayment;
        
            RETURN monthlyPayment;
        
          END;
       $$;
 
 SELECT Lewis_08_monthlyPayment(250000.00, 0.04125, 30);

--------------------------------------------------------------------------------
/*				                  Question 2           		  		          */
--------------------------------------------------------------------------------

    ------------------------------- Part (a) ------------------------------
       (SELECT customer.cust_ID, customer_name
        FROM customer INNER JOIN borrower ON customer.cust_ID = borrower.cust_ID
        WHERE loan_number IS NOT NULL)
            INTERSECT
        (SELECT customer.cust_ID, customer_name
         FROM customer FULL OUTER JOIN depositor ON customer.cust_ID = depositor.cust_ID
         WHERE account_number IS NULL);
       
        

    ------------------------------- Part (b) ------------------------------
        SELECT cust_ID, customer_name
        FROM customer
        WHERE customer_street LIKE(SELECT customer_street
                                   FROM customer
                                   WHERE cust_ID = '12345') 
         AND  customer_city   LIKE(SELECT customer_city
                                   FROM customer
                                   WHERE cust_ID = '12345');

    ------------------------------- Part (c) ------------------------------
        SELECT branch.branch_name
        FROM branch
            INNER JOIN account ON branch.branch_name = account.branch_name
            INNER JOIN depositor ON account.account_number = depositor.account_number
            INNER JOIN customer ON depositor.cust_ID = customer.cust_ID
        WHERE customer_city = 'Harrison'
        GROUP BY branch.branch_name
        HAVING COUNT (customer.cust_ID) >= 1;

    ------------------------------- Part (d) ------------------------------
        SELECT DISTINCT cust_ID
        FROM depositor 
        WHERE NOT EXISTS (
            (SELECT branch_name
             FROM branch
             WHERE branch_city = 'Brooklyn')
                 EXCEPT
             (SELECT account.branch_name
              FROM DEPOSITOR as D, account 
              WHERE D.account_number = account.account_number AND
                    depositor.cust_ID = D.cust_ID));

--------------------------------------------------------------------------------
/*				                  Question 3           		  		          */
--------------------------------------------------------------------------------

   
    CREATE OR REPLACE FUNCTION Lewis_08_bankTriggerFunction()
       RETURNS TRIGGER 
       LANGUAGE plpgsql
       AS
       $$   
         BEGIN
           DELETE FROM depositor
           WHERE depositor.cust_ID IN (SELECT depositor.cust_ID
                                         FROM depositor
                                         WHERE depositor.account_number = OLD.account_number)
           AND NOT EXISTS              (SELECT account.account_number
                                          FROM account
                                          WHERE account.account_number = OLD.account_number);
                                     
           RETURN OLD;   
             
          END;
                                                                  
         $$;
 
 CREATE TRIGGER Lewis_O8_bankTrigger
 AFTER DELETE ON account
 FOR EACH ROW
 EXECUTE PROCEDURE Lewis_08_bankTriggerFunction();

--------------------------------------------------------------------------------
/*				                  Question 4           		  		          */
--------------------------------------------------------------------------------
  
   CREATE TABLE instructor_course_nums (
     ID VARCHAR (12),
     name VARCHAR (30),
     tot_course INTEGER
   );
    
    CREATE OR REPLACE PROCEDURE Lewis_08_insCourseNumsProc(IN IN_ID VARCHAR(12))
       LANGUAGE plpgsql
       AS
       $$
         DECLARE 
         course_count INTEGER = 0;
         instructor_name VARCHAR (30) = '';
         BEGIN
           SELECT COUNT(*) INTO course_count
           FROM teaches INNER JOIN instructor ON instructor.ID = teaches.ID
           WHERE teaches.ID = Lewis_08_insCourseNumsProc.IN_ID
           AND instructor.ID =Lewis_08_insCourseNumsProc.IN_ID;
           
           SELECT instructor.name INTO instructor_name
           FROM instructor INNER JOIN teaches ON teaches.ID = instructor.ID
           WHERE teaches.ID = Lewis_08_insCourseNumsProc.IN_ID
           AND instructor.ID =Lewis_08_insCourseNumsProc.IN_ID;
           
           IF EXISTS 
            (SELECT ID 
             FROM instructor_course_nums
             WHERE ID = Lewis_08_insCourseNumsProc.IN_ID)
           THEN
             UPDATE instructor_course_nums
             SET tot_course = course_count 
             WHERE ID = Lewis_08_insCourseNumsProc.IN_ID;
           
           ELSE
             INSERT INTO instructor_course_nums (ID, name, tot_course)
             VALUES (Lewis_08_insCourseNumsProc.IN_ID, instructor_name , course_count);
           END IF;
          END; 
        $$
           
  CALL Lewis_08_insCourseNumsProc ('11111');
  

         